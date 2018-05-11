.smart_import_rrd <- function(filename){
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("smart_import_rrd", filename, PACKAGE = "rrd")
}


.import_rrd <- function(filename, cf, start, end, step){
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("import_rrd", filename, cf, start, end, step, PACKAGE = "rrd")
}

.describe_rrd <- function(filename){
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("describe_rrd", filename, PACKAGE = "rrd")
  NULL
}
