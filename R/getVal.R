#' Get value from RRD
#' 
#' Returns a `data.frame` row associated with a certain `timestamp`.
#' 
#' Reads small "chunks" of the RRA (see the `rrd.cacheBlock` constant in source 
#' code) and uses a package-wide read-ahead cache implemented as an [environment] 
#' object. The `timestamp` and `step` arguments are also used to calculate the 
#' row index in the cache to ensure fast indexing (as opposed to looking up by 
#' row name, which is known to be much slower in R). The cache is guaranteed 
#' to store a maximum of `rrd.cacheSize` rows per RRA.
#'
#' Use `getVal(filename, cf, step, timestamp)` to get values for a single
#' timestamp. Uses a package-wide read-ahead cache and calculates index in the
#' cache from the timestamp for faster indexing.
#' 
#' Returns a single `data.frame` row. Ensures no more than `rrd.cacheSize rows`
#' per RRA are kept in the cache.
#' 
#' @inheritParams read_rrd
#' @inheritParams read_rra
#' 
#' @param timestamp timestamp 
#'
#' @return data.frame
#' @export
#' @importFrom utils tail
#' @family rrd functions
#'
# @examples
getVal <- function(filename, cf, step, timestamp) {
  assert_that(is.character(filename))
  assert_that(is.character(cf))
  assert_that(is.numeric(step))
  assert_that(is.numeric(timestamp()))
  
  key <- paste0(filename, cf, step)
  
  # no cache entry for this RRA
  if (is.null(rrd.cache[[key]])) {
    
    # getting first timestamp for this RRA
    rrd.first[[key]] <- .Call("getFirst", filename, cf, step)
    if(is.null(rrd.first[[key]])) {
      stop("rra not matched")
    }
    
    tmpDF <- read_rra(
      filename, 
      cf, 
      max(rrd.first[[key]], timestamp - rrd.cacheBlock*step), 
      timestamp + rrd.cacheBlock*step, 
      step
    )
    if (is.null(tmpDF)) {
      stop("could not find timestamp in RRA or memory allocation error");
    }
    rrd.cache[[key]] <- tmpDF
    
    # checking if the requested timestamp can be in this RRA
    if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
      stop("step is wrong")
    }
  } else {
    lastTimestamp = tail(rrd.cache[[key]], n = 1)[1, 1]
    
    if (((timestamp - rrd.cache[[key]][1, 1]) %% step) != 0) {
      stop("step is wrong")
    }
    
    # avoid getting more than rrd.cacheSize rows per RRA
    if ( ((lastTimestamp - timestamp)/step > rrd.cacheSize) ||  
         ((timestamp - rrd.cache[[key]][1, 1])/step > rrd.cacheSize) ) {
      tmpDF <- read_rra(
        filename, 
        cf, 
        max(rrd.first[[key]], timestamp - rrd.cacheBlock*step), 
        timestamp + rrd.cacheBlock*step, 
        step
      )
      if (is.null(tmpDF)) {
        stop("could not find timestamp in RRA or memory allocation error");
      }
      rrd.cache[[key]] <- tmpDF;
    }
    else {
      #if requested timestamp is lower than the first in cache
      if (timestamp < rrd.cache[[key]][1, 1]) {
        tmpDF = read_rra(
          filename, 
          cf, 
          max(rrd.first[[key]], timestamp - rrd.cacheBlock*step), 
          rrd.cache[[key]][1, 1] - step, 
          step
        )
        if (is.null(tmpDF)) {
          stop("could not find timestamp in RRA or memory allocation error");
        }
        rrd.cache[[key]]  <- rbind(tmpDF, rrd.cache[[key]])
      }
      
      # if requested timestamp is higher than the last in cache
      if (timestamp > lastTimestamp) {
        tmpDF = read_rra(
          filename, 
          cf, 
          lastTimestamp, 
          timestamp + rrd.cacheBlock*step, 
          step
        )
        if (is.null(tmpDF)) {
          stop("could not find timestamp in RRA or memory allocation error");
        }
        rrd.cache[[key]] <- rbind(rrd.cache[[key]], tmpDF)
      }
    }
  }
  
  # calculating the index in the data frame and getting the row of interest
  rrd.cache[[key]][(timestamp - rrd.cache[[key]][1, 1]) /step + 1, ]
}

