Rrd
===

R package for working with .rrd files


#Installation
In order to build the package from source you need librrd.  
Installing rrdtool from your package manager will usually also install the library.  

In the parent directory of Rrd:  

    R CMD build Rrd
    R CMD check Rrd
    sudo R CMD INSTALL Rrd

#Usage

In R:

    library(Rrd)

##importRRD(filename)
Exposes all the values in an RRD - each RRA, each DS, from first to last timestamp.


    rrd = importRRD("filename.rrd")
    rrd[[i]][[j]][k]

refers to the k<sup>th</sup> value (starting from the earliest timestamp for which the RRD stores data) from the j<sup>th</sup> data store in the i<sup>th</sup> RRA.


##importRRD(filename, consolidation function, start, end, step)
Finds RRA that best matches the __consolidation function__ and the __step__ and imports all values (from all DS) in that RRA that are between timestamp __start__ and __end__.

    rrd = importRRD("filename.rrd", "AVERAGE", 0, 0, 1)
    rrd[[j]][k]

refers to the k<sup>th</sup> value (starting from timestamp __start__ until __end__) from the j<sup>th</sup> data store (DS) in the RRA that best matches the required __consolidation function__ and __step__.


For more information on rrdtool and the rrd format please refer to the official rrdtool [documentation](http://oss.oetiker.ch/rrdtool/doc/index.en.html) and [tutorials](http://oss.oetiker.ch/rrdtool/tut/index.en.html).
    



