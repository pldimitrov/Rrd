#maps a data.frame with maximum rrd.cacheSize rows to each RRA
rrd.cache = new.env(hash = TRUE)
#stores the first timestamp of each RRA
rrd.first = new.env(hash = TRUE)
#determines the number of rows to fetch on a cache-miss
rrd.cacheBlock = 50
rrd.cacheSize = 1000


getVal <- function(filename, cf, step, timestamp) {
    key  = paste(as.character(filename), as.character(cf), as.character(step), sep = "")

    #no cache entry for this RRA
    if (is.null(rrd.cache[[key]])) {

	if (!file.exists(filename) || !is.character(cf) || !is.numeric(step) || !is.numeric(timestamp)) {
	    stop("usage: getVal(filename, cf, step, timestamp)")
	}

	#getting first timestamp for this RRA
	rrd.first[[key]] <- .Call("getFirst", filename, cf, step)
	if(is.null(rrd.first[[key]])) {
	    stop("rra not matched")

	}


	tmpDF <- importRRD(filename, cf, max(rrd.first[[key]], timestamp - rrd.cacheBlock*step), timestamp + rrd.cacheBlock*step, step)
	if (is.null(tmpDF)) {
	    stop("could not find timestamp in RRA or memory allocation error");

	}
	rrd.cache[[key]] <- tmpDF

	#checking if the requested timestamp can be in this RRA
	if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
	    stop("step is wrong")
	}

    }

    else {
	lastTimestamp = tail(rrd.cache[[key]], n = 1)[1, 1]

	if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
	    stop("step is wrong")
	}

	#avoid getting more than rrd.cacheSize rows per RRA
	if ( ((lastTimestamp - timestamp)/step > rrd.cacheSize) ||  ((timestamp - rrd.cache[[key]][1, 1])/step > rrd.cacheSize) ) {
	    tmpDF <- importRRD(filename, cf, max(rrd.first[[key]],  timestamp - rrd.cacheBlock*step), timestamp + rrd.cacheBlock*step, step)
	    if (is.null(tmpDF)) {
		stop("could not find timestamp in RRA or memory allocation error");

	    }
	    rrd.cache[[key]] <- tmpDF;
	}
	else {
	    #if requested timestamp is lower than the first in cache
	    if (timestamp < rrd.cache[[key]][1, 1]) {
		tmpDF = importRRD(filename, cf, max(rrd.first[[key]],  timestamp - rrd.cacheBlock*step), rrd.cache[[key]][1, 1] - step, step)
		if (is.null(tmpDF)) {
		    stop("could not find timestamp in RRA or memory allocation error");

		}
		rrd.cache[[key]]  <- rbind(tmpDF, rrd.cache[[key]])

	    }

	    #if requested timestamp is higher than the last in cache
	    if (timestamp > lastTimestamp) {
		tmpDF = importRRD(filename, cf, lastTimestamp, timestamp + rrd.cacheBlock*step, step)
		if (is.null(tmpDF)) {
		    stop("could not find timestamp in RRA or memory allocation error");

		}
		rrd.cache[[key]] <- rbind(rrd.cache[[key]], tmpDF)
	    }
	}



    }

    #calculating the index in the data frame and getting the row of interest
    rrd.cache[[key]][(timestamp - rrd.cache[[key]][1, 1])/step + 1, ]

}




importRRD <- function(filename = "char", cf = "char", start = "integer", end = "integer", step = "long") {


    if (missing(filename) || !is.character(filename))
	stop("Need to provide a path to an RRD file")



    if (missing(cf) || missing(start) || missing(end) || missing(step)) {

	.Call("smartImportRRD", filename, PACKAGE = "Rrd")

    } else {

	if (!is.numeric(start) || !is.numeric(end) || !is.numeric(step)) 
	    stop("start, end, step need to be numeric")

	if (!is.character(cf))
	    stop("consolidation function should be a string")

	.Call("importRRD", filename, cf, start, end, step, PACKAGE = "Rrd")
    }

}




