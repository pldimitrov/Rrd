#' Get first
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
#' @references https://oss.oetiker.ch/rrdtool/doc/rrdfetch.en.html
#'
#' @return Returns a list of data.frames with labels constructed as "consolidation function" + "step" - e.g. "AVERAGE15".
#' @export
#' @family rrd functions
#'
# @examples
get_first <- function(filename, cf, step) {
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("get_first", filename, cf, step, PACKAGE = "Rrd")
}

