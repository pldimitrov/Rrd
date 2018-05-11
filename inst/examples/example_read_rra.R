rrd_cpu_0 <- system.file("extdata/cpu-0.rrd", package = "rrd")

start_time <- as.POSIXct("2018-05-01") # timestamp with data in example
end_time <- as.POSIXct("2018-05-02") # timestamp with data in example
avg_60 <- read_rra(rrd_cpu_0, cf = "AVERAGE", step = 60L, 
                     start = start_time, 
                     end = end_time)
names(avg_60)
head(avg_60)
tail(avg_60)

