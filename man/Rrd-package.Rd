\name{Rrd-package}
\alias{Rrd-package}
\alias{Rrd}
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
to import RRA arrays into vectors in R.

importRRD(filename) tries to first read the metadata in the RRD and adjust the parameters accordingly in order to expose all arrays. 
importRRD(filename)[[i]][[j]][[k]]

i - index of RRA
j - index of ds
k - index of entry in time series

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

\seealso{
}

\examples{

importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/boottime.rrd", "AVERAGE", 0, 0, 1)
importRRD("/var/lib/ganglia/rrds/__SummaryInfo__/boottime.rrd")

}
