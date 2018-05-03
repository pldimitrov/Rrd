#' Import RRD
#'
#' Finds the RRA that best matches the `consolidation function` and the `step` and imports all values (from all data stores) in that RRA that are between timestamp `start` and `end`. Note that `start` is not included in the result.
#'  
#' Returns a `data.frame` object having the `timestamp` and the data stores as columns. The data store names are retrieved from the RRD file and set as the corresponding column names. The timestamps are also used as row names.
#'
#'
#' Use `importRRD(filename)` and `importRRD(filename, consolidation function, start, end, step)` to import (a part of) an RRA into a `data.frame`. The filename, consolidation function and step parameters uniquely identify an RRA array in the RRD file. Start and end define the time-slice to be retrieved. Start is not included in the result. Look at the documentation for [rrdfetch](https://oss.oetiker.ch/rrdtool/doc/rrdfetch.en.html) for more info.
#' 
#' The returned `data.frame` has the timestamp and the data stores as separate columns. The names of the data sources are extracted from the RRD file and set as column names. The timestamps are also used as row names.
#' 
#' `importRRD(filename)` first reads the metadata in the RRD and adjusts the parameters accordingly in order to expose all RRAs in their entirety.
#' 
#' 
#'
#' @param filename File name
#' @param cf The consolidation function that is applied to the data you want to fetch. Must be one of `c("AVERAGE", "MIN", "MAX", "LAST")`
#' @param step step
#' 
#' @param start start
#' @param end end
#'
#' @return Returns a list of data.frames with labels constructed as "consolidation function" + "step" - e.g. "AVERAGE15".
#' @export
#' @family rrd functions
#'
# @examples
importRRD <- function(filename, cf, start, end, step) {
  assert_that(is.character(filename))
  
  assert_that(file.exists(filename))
  
  if (missing(cf) || missing(start) || missing(end) || missing(step)) {
    .Call("smartImportRRD", filename, PACKAGE = "Rrd")
  } else {
    assert_that(is.character(cf))
    assert_that(cf %in% c("AVERAGE", "MIN", "MAX", "LAST"))
    assert_that(is.numeric(start))
    assert_that(is.numeric(end))
    assert_that(is.numeric(step))
    
    cf <- match.arg(cf, c("AVERAGE", "MIN", "MAX", "LAST"))
    .Call("importRRD", filename, cf, start, end, step, PACKAGE = "Rrd")
  }
}




