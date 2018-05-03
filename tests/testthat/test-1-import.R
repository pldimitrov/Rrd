# library(magrittr)
if (interactive()) library(testthat)

context("importRRD")

rrd_cpu_0 <- system.file("inst/extdata/cpu-0.rrd", package = "Rrd")
rrd_cpu_system <- system.file("inst/extdata/system-CPU.rrd", package = "Rrd")
rrd_ram <- system.file("inst/extdata/system-RAM.rrd", package = "Rrd")

test_that("can smart import rrd_cpu_0", {

  z <- importRRD(rrd_cpu_0)
  expect_is(z, "list")
  expect_is(z[[1]], "data.frame")
  expect_equal(length(z), 10)
  expect_equal(
    names(z), 
    c("AVERAGE60", "AVERAGE300", "MIN300", "MAX300", "AVERAGE3600", 
      "MIN3600", "MAX3600", "AVERAGE86400", "MIN86400", "MAX86400")
  )
})

test_that("can smart import rrd_cpu_system", {
  
  z <- importRRD(rrd_cpu_system)
  expect_is(z, "list")
  expect_is(z[[1]], "data.frame")
  expect_equal(length(z), 10)
  expect_equal(
    names(z), 
    c("AVERAGE60", "AVERAGE300", "MIN300", "MAX300", "AVERAGE3600", 
      "MIN3600", "MAX3600", "AVERAGE86400", "MIN86400", "MAX86400")
  )
  
})


test_that("can smart import rrd_ram", {
  
  z <- importRRD(rrd_ram)
  expect_is(z, "list")
  expect_is(z[[1]], "data.frame")
  expect_equal(length(z), 10)
  expect_equal(
    names(z), 
    c("AVERAGE60", "AVERAGE300", "MIN300", "MAX300", "AVERAGE3600", 
      "MIN3600", "MAX3600", "AVERAGE86400", "MIN86400", "MAX86400")
  )
  
})

test_that("can  import rrd_ram", {
  
  z <- importRRD(rrd_ram, "MAX", Sys.time() - 86400, Sys.time(), step = 1L)
  expect_is(z, "data.frame")
  expect_equal(nrow(z), 288)
  expect_equal(ncol(z), 9)
  expect_equal(
    names(z), 
    c("timestamp", "ram", "total", "used", "free", "actualused", 
      "actualfree", "usedpercent", "freepercent")
  )
  
})
