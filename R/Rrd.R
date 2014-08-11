rrd.cache = new.env(hash = TRUE)
rrd.cacheBlock = 50


getVal <- function(filename, cf, step, timestamp) {
	key  = paste(as.character(filename), as.character(cf), as.character(step), sep = "")
	if (is.null(rrd.cache[[key]])) {

		if (!file.exists(filename) || !is.character(cf) || !is.numeric(step) || !is.numeric(timestamp)) {
			stop("usage: getVal(filename, cf, step, timestamp)")
		}
		rrd.cache[[key]] <- importRRD(filename, cf, timestamp - rrd.cacheBlock*step, timestamp + rrd.cacheBlock*step, step)
		if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
			stop("step is wrong")
		}

	}

	else {
		lastTimestamp = tail(rrd.cache[[key]], n = 1)[1, 1]

		if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
			stop("step is wrong")
		}

		if (timestamp < rrd.cache[[key]][1, 1]) {
			tmpDF = importRRD(filename, cf, timestamp - rrd.cacheBlock*step, rrd.cache[[key]][1, 1] - step, step)
			rrd.cache[[key]]  <- rbind(tmpDF, rrd.cache[[key]])

		}


		if (timestamp > lastTimestamp) {
			tmpDF = importRRD(filename, cf, lastTimestamp + step, timestamp + rrd.cacheBlock*step, step)
			rrd.cache[[key]] <- rbind(rrd.cache[[key]], tmpDF)
		}

	}

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




