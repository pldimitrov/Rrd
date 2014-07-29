pkg.env <- new.env()
pkg.env$rrdCache = list()

setClass("RRD",
	 representation(
			filename="character",
			cache="list"
			)
	 )

RRD = function(filenameIn="character") {
    if (missing(filenameIn) || !is.character(filenameIn))
	stop("Need to provide a path to an RRD file")
    if (!file.exists(filenameIn)) 
	stop("File does not exist")
    new ("RRD", filename=filenameIn, cache = list())
}

#setGeneric("getVal",
	  getVal <- function(filename, cf, step, timestamp) {
	      if (!(step %in% names(pkg.env$rrdCache[[filename]][[cf]]))) {
		  pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]] <- importRRD(filename, cf, timestamp - 100, timestamp + 100, step)

	      }

	      else {
		  if (is.na(pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]][as.character(timestamp), ][1, 1])) {
		      #TODO decide direction or read-ahead, store last timestamp asked
		      tmpDF = importRRD(filename, cf, timestamp - 100, timestamp + 100, step)
		      if (nrow(pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]]) > 300) {
			  print(nrow(pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]]))
			  pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]] <- tmpDF;
		      }
		      else {
			  pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]] <- rbind(pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]], tmpDF)

		      }

		  }
	      }
	      pkg.env$rrdCache[[filename]][[cf]][[as.character(step)]][as.character(timestamp), ]

	  }
	 # )
	  



importArray <- function() {
    .Call("exposeArray",'c', PACKAGE = "Rrd")
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





updateRRD <- function () {
}
