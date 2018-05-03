.smart_import_rrd <- function(filename){
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("smartImportRRD", filename, PACKAGE = "Rrd")
}


.import_rrd <- function(filename, cf, start, end, step){
  assert_that(is.character(filename))
  assert_that(file.exists(filename))
  .Call("importRRD", filename, cf, start, end, step, PACKAGE = "Rrd")
}
