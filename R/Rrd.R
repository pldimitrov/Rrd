importArray <- function() {
    .Call("exposeArray",'c', PACKAGE = "Rrd")
}

importRRD <- function(filename = "char", cf = "char", start = "integer", end = "integer", step = "long") {
    .Call("importRRD", filename, cf, start, end, step, PACKAGE = "Rrd")
}

#importRRD <- function() {
    #.Call("importRRD", 'c', PACKAGE = "Rrd")
#}
