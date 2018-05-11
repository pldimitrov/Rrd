# maps a data.frame with maximum rrd.cacheSize rows to each RRA
rrd.cache = new.env(hash = TRUE)

# stores the first timestamp of each RRA
rrd.first = new.env(hash = TRUE)

# determines the number of rows to fetch on a cache-miss
rrd.cacheBlock = 50
rrd.cacheSize = 1000


.onUnload <- function (libpath) {
  library.dynam.unload("rrd", libpath)
}