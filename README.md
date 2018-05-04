
<!-- README.md is generated from README.Rmd. Please edit that file -->
Rrd
===

The `Rrd` package allows you to read data from an [RRD](http://oss.oetiker.ch/rrdtool/) database.

Internally it uses [librrd](http://oss.oetiker.ch/rrdtool/doc/librrd.en.html) to import the binary data directly into R without exporting it to an intermediate format first.

For an introduction to RRD database, see <https://oss.oetiker.ch/rrdtool/tut/rrd-beginners.en.html>

Installation
------------

Pre-requisites
--------------

In order to build the package from source you need [librrd](http://oss.oetiker.ch/rrdtool/doc/librrd.en.html). Installing [RRDtool](http://oss.oetiker.ch/rrdtool/) from your package manager will usually also install the library.

``` sh
sudo apt-get install librrd-dev
```

`Rrd` is not yet on CRAN

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrie/Rrd")
```

Example
-------

In R:

``` r
library(Rrd)
```

### Read an entire RRD file:

Use `read_rrd()`:

``` r
rrd_cpu_0 <- system.file("extdata/cpu-0.rrd", package = "Rrd")

cpu <- read_rrd(rrd_cpu_0)
names(cpu)
#>  [1] "AVERAGE60"    "AVERAGE300"   "MIN300"       "MAX300"      
#>  [5] "AVERAGE3600"  "MIN3600"      "MAX3600"      "AVERAGE86400"
#>  [9] "MIN86400"     "MAX86400"
head(cpu[[1]])
#>                      timestamp       user         sys nice      idle wait
#> 1522671840 2018-04-02 12:24:00 0.01044307 0.008107867    0 0.9813112    0
#> 1522671900 2018-04-02 12:25:00 0.01259380 0.006296933    0 0.9791922    0
#> 1522671960 2018-04-02 12:26:00 0.01588280 0.008079600    0 0.9760375    0
#> 1522672020 2018-04-02 12:27:00 0.00853440 0.006469267    0 0.9849954    0
#> 1522672080 2018-04-02 12:28:00 0.01218453 0.009994067    0 0.9778214    0
#> 1522672140 2018-04-02 12:29:00 0.01056633 0.006036933    0 0.9833967    0
#>            irq softirq       stolen
#> 1522671840   0       0 0.0001368667
#> 1522671900   0       0 0.0019161333
#> 1522671960   0       0 0.0000000000
#> 1522672020   0       0 0.0000000000
#> 1522672080   0       0 0.0000000000
#> 1522672140   0       0 0.0000000000
tail(cpu[[1]])
#>                      timestamp      user          sys nice      idle
#> 1525263420 2018-05-02 12:17:00 0.0054528 0.0014390667    0 0.9916691
#> 1525263480 2018-05-02 12:18:00 0.0060240 0.0020080000    0 0.9913991
#> 1525263540 2018-05-02 12:19:00 0.0088878 0.0005689333    0 0.9905433
#> 1525263600 2018-05-02 12:20:00 0.0071476 0.0000000000    0 0.9914162
#> 1525263660 2018-05-02 12:21:00 0.0060206 0.0014390667    0 0.9919725
#> 1525263720 2018-05-02 12:22:00 0.0017068 0.0005689333    0 0.9977243
#>                    wait irq softirq    stolen
#> 1525263420 0.0014390667   0       0 0.0000000
#> 1525263480 0.0005689333   0       0 0.0000000
#> 1525263540 0.0000000000   0       0 0.0000000
#> 1525263600 0.0000000000   0       0 0.0014362
#> 1525263660 0.0000000000   0       0 0.0005678
#> 1525263720 0.0000000000   0       0 0.0000000

tail(cpu$AVERAGE60$sys)
#> [1] 0.0014390667 0.0020080000 0.0005689333 0.0000000000 0.0014390667
#> [6] 0.0005689333
```

### Read a single RRA archive from an RRD file

Use `read_rra()`:

``` r
rrd_cpu_0 <- system.file("extdata/cpu-0.rrd", package = "Rrd")

start_time <- as.POSIXct("2018-05-01") # timestamp with data in example
end_time <- as.POSIXct("2018-05-02") # timestamp with data in example
avg_60 <- read_rra(rrd_cpu_0, cf = "AVERAGE", step = 60L, 
                     start = start_time, 
                     end = end_time)
names(avg_60)
#> [1] "timestamp" "user"      "sys"       "nice"      "idle"      "wait"     
#> [7] "irq"       "softirq"   "stolen"
head(avg_60)
#>                      timestamp        user          sys nice      idle
#> 1525132860 2018-05-01 00:01:00 0.004583867 0.0020086000    0 0.9919656
#> 1525132920 2018-05-01 00:02:00 0.002584933 0.0005700667    0 0.9962749
#> 1525132980 2018-05-01 00:03:00 0.006327467 0.0014390667    0 0.9922335
#> 1525133040 2018-05-01 00:04:00 0.005153867 0.0020080000    0 0.9913991
#> 1525133100 2018-05-01 00:05:00 0.004016000 0.0005689333    0 0.9948461
#> 1525133160 2018-05-01 00:06:00 0.006894133 0.0014390667    0 0.9916668
#>            wait irq softirq       stolen
#> 1525132860    0   0       0 0.0014419333
#> 1525132920    0   0       0 0.0005700667
#> 1525132980    0   0       0 0.0000000000
#> 1525133040    0   0       0 0.0014390667
#> 1525133100    0   0       0 0.0005689333
#> 1525133160    0   0       0 0.0000000000
tail(avg_60)
#>                      timestamp        user         sys nice      idle wait
#> 1525218900 2018-05-01 23:55:00 0.005457333 0.002009133    0 0.9925335    0
#> 1525218960 2018-05-01 23:56:00 0.004579200 0.002005133    0 0.9934157    0
#> 1525219020 2018-05-01 23:57:00 0.002577533 0.000567800    0 0.9968547    0
#> 1525219080 2018-05-01 23:58:00 0.006326333 0.000000000    0 0.9936737    0
#> 1525219140 2018-05-01 23:59:00 0.008020533 0.001436200    0 0.9905433    0
#> 1525219200 2018-05-02 00:00:00 0.005149333 0.003445933    0 0.9914047    0
#>            irq softirq stolen
#> 1525218900   0       0      0
#> 1525218960   0       0      0
#> 1525219020   0       0      0
#> 1525219080   0       0      0
#> 1525219140   0       0      0
#> 1525219200   0       0      0
```

More information
----------------

For more information on `rrdtool` and the `rrd` format please refer to the official [rrdtool documentation](http://oss.oetiker.ch/rrdtool/doc/index.en.html) and [tutorials](http://oss.oetiker.ch/rrdtool/tut/index.en.html).

You can read a more in-depth description of the package and more examples in this [blog post](http://plamendimitrov.net/blog/2014/08/09/r-package-for-working-with-rrd-files/).
