#' Import data from a RRD file into R
#' 
#' The package uses `librrd` to import the numerical data in a rrd database
#' directly into R data structures without using intermediate formats.
#' 
#' Exposes two functions:
#' 
#' * [importRRD()]
#' * [getVal()]
#' 
#' 
#' @name Rrd-package
#' @docType package
#' @author Plamen Dimitrov
#' 
#' Maintainer: Plamen Dimitrov <dim.plamen@@gmail.com>
#' 
#' @useDynLib Rrd, .registration = TRUE
#' @importFrom Rcpp sourceCpp
#'  
# @seealso
#' @references <http://oss.oetiker.ch/rrdtool/doc/index.en.html>
#' @references <https://github.com/pldimitrov/Rrd>
#' 
#' @keywords package rrd rrdtool librrd
#' 
#' 
#' @importFrom assertthat assert_that
#' 
#' @examples
#' 
#' \dontrun{
#' importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd", 
#'           "AVERAGE", 1402231215, 1402232085, 15)
#' rrd = importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd")
#' rrd$AVERAGE15
#' rrd[[1]]
#' rrd$AVERAGE15$timestamp
#' rrd$AVERAGE15$sum
#' rrd$AVERAGE15[1, 1]
#' rrd$AVERAGE15[1, "sum"]
#' rrd[["AVERAGE15"]]
#' rrd$AVERAGE60
#' getVal("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd", 
#'        "AVERAGE", 15, 1402231245)
#' rrd.cache[["/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrdAVERAGE15"]]
#' }
#' 
#' 
NULL



