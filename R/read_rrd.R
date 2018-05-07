#' Imports data from an RRD database
#'
#' Reads the metadata in the RRD and adjusts the parameters accordingly in order to expose all RRAs in their entirety.
#' 
#' @param filename File name
#' 
#' @references <https://oss.oetiker.ch/rrdtool/doc/rrdfetch.en.html>
#'
#' @return Returns a named list of data.frames. Each data frame corresponds to an RRA (see [read_rra()]).  The list has names constructed as "consolidation function" + "step" - e.g. "AVERAGE15".
#' @export
#' @family rrd functions
#' @importFrom tibble as_tibble
#'
#' @example inst/examples/example_read_rrd.R
read_rrd <- function(filename) {
    dat <- .smart_import_rrd(filename)
    for (i in seq_along(dat)){
      dat[[i]] <- as_tibble(dat[[i]])
      dat[[i]][["timestamp"]] <- as.POSIXct(dat[[i]][["timestamp"]], origin = "1970-01-01")
    }
    dat
}

#' Describes content of a RRD file.
#' 
#' @inheritParams read_rrd
#' 
#' @export
#' @family rrd functions
#' @example inst/examples/example_describe_rrd.R
describe_rrd <- function(filename){
  .describe_rrd(filename)
  invisible(NULL)
}

#' Imports the RRA data from an RRD database
#' 
#' Finds the RRA (round robin array) that best matches the `consolidation function` and the `step` and imports all values (from all data stores) in that RRA that are between timestamp `start` and `end`. Note that `start` is not included in the result.
#'  
#' Returns a `data.frame` object having the `timestamp` and the data stores as columns. The data store names are retrieved from the RRD file and set as the corresponding column names. The timestamps are also used as row names.
#'
#' The `filename`, `cf` (consolidation function) and `step` arguments uniquely identify an RRA array in the RRD file.
#' 
#' The arguments `start` and `end` define the time-slice to be retrieved. Note that `start` is not included in the result. Refer to the documentation for [rrdfetch](https://oss.oetiker.ch/rrdtool/doc/rrdfetch.en.html) for more information.
#' 
#' The returned `data.frame` has the `timestamp` and the data stores as separate columns. The names of the data sources are extracted from the RRD file and set as column names. The timestamps are also used as row names.
#' 
#' @inheritParams read_rrd
#' @param cf The consolidation function that is applied to the data you want to fetch. Must be one of `c("AVERAGE", "MIN", "MAX", "LAST")`
#' @param step step
#' 
#' @param start start
#' @param end end
#' @export
#' @family rrd functions
#'
#' @example inst/examples/example_read_rra.R
read_rra <- function(filename, cf, start, end, step){
  assert_that(is.character(cf))
  assert_that(cf %in% c("AVERAGE", "MIN", "MAX", "LAST"))
  assert_that(is.time(start))
  assert_that(is.time(end))
  assert_that(is.integer(step))
  
  start <- as.numeric(start)
  end <- as.numeric(end)
  
  cf <- match.arg(cf, c("AVERAGE", "MIN", "MAX", "LAST"))
  dat <- .import_rrd(filename, cf, start, end, step)
  dat <- as_tibble(dat)
  dat[["timestamp"]] <- as.POSIXct(dat[["timestamp"]], origin = "1970-01-01")
  dat
}


#' Deprecated functions.
#' 
#' @export
importRRD <- function(filename, cf = NULL, start = NULL, end = NULL, step = NULL){
  if (any(!is.null(cf), !is.null(start), !is.null(end), !is.null(step))) {
    .Deprecated(read_rra)
  } else {
    .Deprecated(read_rrd)
  }
}

is.POSIXct <- function(x){
  inherits(x, "POSIXct")
}

is.time <- function(x){
  is.POSIXct(x) || is.numeric(x)
}
