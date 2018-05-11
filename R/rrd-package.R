#' Import data from a RRD database into R
#' 
#' The package uses `librrd` to import the numerical data in a rrd database
#' directly into R data structures without using intermediate formats.
#' 
#' Exposes two functions:
#' 
#' * [read_rrd()] to read an entire RRD file
#' * [read_rra()] to extract a single RRA (round robin archive) from an RRD file
#' * [getVal()] to extract a single value
#' 
#' For more information on rrdtool and the rrd format please refer to the official rrdtool [documentation](http://oss.oetiker.ch/rrdtool/doc/index.en.html) and [tutorials](http://oss.oetiker.ch/rrdtool/tut/index.en.html).
#' 
#' You can also read a more in-depth description of the package in a [blog post](http://plamendimitrov.net/blog/2014/08/09/r-package-for-working-with-rrd-files/).
#' 
#' 
#' @name rrd-package
#' @docType package
#' @author Plamen Dimitrov
#' 
#' Maintainer: Plamen Dimitrov <dim.plamen@@gmail.com>
#' 
#' @useDynLib rrd, .registration = TRUE
#'  
# @seealso
#' @references <http://oss.oetiker.ch/rrdtool/doc/index.en.html>
#' @references <https://github.com/pldimitrov/rrd>
#' 
#' @keywords package rrd rrdtool librrd
#' 
#' 
#' @importFrom assertthat assert_that
#' 
NULL



