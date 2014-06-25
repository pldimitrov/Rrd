importArray <- function() {
    .Call("exposeArray",'c', PACKAGE = "Rrd")
}

importRRD <- function(filename = "char", cf = "char", start = "integer", end = "integer", step = "long") {


    if (missing(filename))
	stop("Need to provide a path to an RRD file")


    if (missing(cf) || missing(start) || missing(end) || missing(step)) {
	.Call("smartImportRRD", filename, PACKAGE = "Rrd")
    } else {

	.Call("importRRD", filename, cf, start, end, step, PACKAGE = "Rrd")
    }

}
