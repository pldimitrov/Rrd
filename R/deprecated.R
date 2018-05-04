#' Deprecated functions.
#' 
#' @inheritParams read_rrd
#' @inheritParams read_rra
#' @export
importRRD <- function(filename, cf = NULL, start = NULL, end = NULL, step = NULL){
  if (any(!is.null(cf), !is.null(start), !is.null(end), !is.null(step))) {
    .Deprecated(read_rra)
  } else {
    .Deprecated(read_rrd)
  }
}
