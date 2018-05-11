rrd_cpu_0 <- system.file("extdata/cpu-0.rrd", package = "rrd")

describe_rrd(rrd_cpu_0)

cpu <- read_rrd(rrd_cpu_0)
names(cpu)
head(cpu[[1]])
tail(cpu[[1]])

tail(
  cpu$AVERAGE60$sys
)
