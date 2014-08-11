\name{Rrd-package}
\alias{Rrd-package}
\alias{Rrd}
\alias{importRRD}
\alias{getVal}
\alias{rrd.cache}
\alias{rrd.cacheBlock}

\docType{package}
\title{
Import data from a RRD file into R
}

\description{
The package uses librrd to import the numerical data in a rrd database directly into R data structures without using intermediate formats.

}
\details{
\tabular{ll}{
Package: \tab Rrd\cr
Type: \tab Package\cr
Version: \tab 1.0\cr
Date: \tab 2014-06-01\cr
License: \tab What license is it under?\cr
}

Use importRRD(filename) and importRRD(filename, consolidation function, start, end, step)
to import (a part of) an RRA into a data.frame. The filename, consolidation function and step parameters uniquely identify an RRA array 
in the RRD file. Start and end define the time-slice to be retrieved. Start is not included in the result. Look at the documentation for rrd_fetch for more info.

The returned data.frame has the timestamp and the data stores as separate columns. The names of the data sources are
extracted from the RRD file and set as column names. The timestamps are also used as row names.

Use getVal(filename, cf, step, timestamp) to get values for a single timestamp. Uses a package-wide read-ahead cache and calculates index in the
cache from the timestamp for faster indexing. Returns a single data.frame row.

importRRD(filename) first reads the metadata in the RRD and adjusts the parameters accordingly in order to expose all arrays. Returns a list of data.frames (as above) 
with labels constructed as "consolidation function" + "step" - e.g. "AVERAGE15".


}
\author{
Plamen Dimitrov

Maintainer: Plamen Dimitrov <dim.plamen@gmail.com>
}
\references{
http://oss.oetiker.ch/rrdtool/doc/index.en.html
}

\keyword{ package }
\keyword{ rrd }
\keyword{ rrdtool }
\keyword{ librrd }

\seealso{
}

\examples{

importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd", "AVERAGE", 1402231215, 1402232085, 15)
rrd = importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd")
rrd$AVERAGE15
rrd[[1]]
rrd$AVERAGE15$timestamp
rrd$AVERAGE15$sum
rrd$AVERAGE15[1, 1]
rrd$AVERAGE15[1, "sum"]
rrd[["AVERAGE15"]]
rrd$AVERAGE60
getVal("/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrd", "AVERAGE", 15, 1402231245)
rrd.cache$`/var/lib/ganglia/rrds/__SummaryInfo__/mem_free.rrdAVERAGE15`


}
