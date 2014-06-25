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
