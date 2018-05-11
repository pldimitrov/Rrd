rrd_cpu_0 <- system.file("extdata/cpu-0.rrd", package = "rrd")

# Note that the default end time is the current time (Sys.time())
# However, since the sample data is historic, specify the end time

start_time <- as.POSIXct("2018-05-01") # timestamp with data in example
end_time <- as.POSIXct("2018-05-02")   # timestamp with data in example

# read archive by specifying start time
avg_60 <- read_rra(rrd_cpu_0, cf = "AVERAGE", step = 60L, 
                     start = start_time, 
                     end = end_time)
names(avg_60)
head(avg_60)
tail(avg_60)

# read archive by specifying number of rows to retrieve
avg_60 <- read_rra(rrd_cpu_0, cf = "AVERAGE", step = 60L, 
                   n_rows = 5, 
                   end = end_time)
names(avg_60)
avg_60
