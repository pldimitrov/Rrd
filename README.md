Rrd
===

R package for working with [RRD](http://oss.oetiker.ch/rrdtool/) files. Uses [librrd](http://oss.oetiker.ch/rrdtool/doc/librrd.en.html) to import the binary data directly into R without exporting it to an intermediate format first.


# Installation

## Pre-requisites

In order to build the package from source you need [librrd](http://oss.oetiker.ch/rrdtool/doc/librrd.en.html).
Installing [RRDtool](http://oss.oetiker.ch/rrdtool/) from your package manager will usually also install the library.  

```sh
sudo apt-get install librrd-dev
```

## Installing the R package

Then install the R package

In the parent directory of `Rrd`:  

```r
R CMD build Rrd
R CMD check Rrd
sudo R CMD INSTALL Rrd
```

# Usage

In R:

```r
library(Rrd)
```

## importRRD(filename, consolidation function, start, end, step)

Finds the RRA that best matches the `consolidation function` and the `step` and imports all values (from all data stores) in that RRA that are between timestamp `start` and `end`. `start` is not included in the result.


```r
rra = importRRD("filename.rrd", "AVERAGE", 1402144275, 1402144410, 15)
```

Returns a data.frame object having the timestamp and the data stores as columns. The data store names are retrieved from the RRD file and set as the corresponding column names. The timestamps are also used as row names.

```r
head(rra)
```



                timestamp sum num
    1402144275 1402144275   0   0
    1402144290 1402144290   0   0
    1402144305 1402144305   0   0
    1402144320 1402144320   0   0
    1402144335 1402144335   0   0
    1402144350 1402144350   0   0



## importRRD(filename)

Retrieves the metadata from the RRD file and imports all values from this file - each RRA, each data store, from the first to the last timestamp. 


```r
rrd = importRRD("filename.rrd")
```

Returns a list of `data.frame`s (as above) with labels constructed as "consolidation function" + "step" - e.g. "AVERAGE15".

```r
head(rrd$AVERAGE15)
```

                timestamp sum num
    1402144275 1402144275   0   0
    1402144290 1402144290   0   0
    1402144305 1402144305   0   0
    1402144320 1402144320   0   0
    1402144335 1402144335   0   0
    1402144350 1402144350   0   0



## getVal(filename, consolidation function, step, timestamp)

Returns a `data.frame` row associated with a certain `timestamp`. Reads small "chunks" of the RRA (see the `rrd.cacheBlock` constant in source code) and uses a package-wide read-ahead cache implemented as an [environment](http://stat.ethz.ch/R-manual/R-devel/library/base/html/environment.html) object. The `timestamp` and `step` arguments are also used to calculate the row index in the cache to ensure fast indexing (as opposed to looking up by row name, which is known to be much slower in R). The cache is guaranteed to store a maximum of `rrd.cacheSize` rows per RRA.

```r
getVal("filename", "AVERAGE", 15, 1402231740)
```
                timestamp sum num
    1402231740 1402231740   0   0


    rrd.cache$`filenameAVERAGE15`
    

 
# More information

For more information on rrdtool and the rrd format please refer to the official rrdtool [documentation](http://oss.oetiker.ch/rrdtool/doc/index.en.html) and [tutorials](http://oss.oetiker.ch/rrdtool/tut/index.en.html).

A more in-depth description of the package and more examples can be seen [here](http://plamendimitrov.net/blog/2014/08/09/r-package-for-working-with-rrd-files/).
