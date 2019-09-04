library(arduinor)
library(lubridate)
library(tidyverse)

# Establish connection to Arduino serial
con <- ar_init("/dev/cu.usbmodem141101", baud = 9600)
# Flush data
ar_flush_hard(con)

# Read for 30 minutes
runtime_s <- 30 * 60
start_time <- now()
end_time <- start_time + seconds(runtime_s)
rate_hz <- 1
time <- rep(as.POSIXct(NA), runtime_s * rate_hz + 100)
temperature <- rep(NA, runtime_s * rate_hz + 100)
i <- 1
t <- now()
while (t < end_time) {
  temperature[i] <- parse_number(ar_read(con))
  time[i] <- t
  i <- i + 1
  t <- now()
}

result <- tibble(time, temperature) %>% 
  drop_na()
  
ggplot(result, aes(time, temperature)) +
  geom_smooth(method = "loess", se = FALSE) +
  geom_point() +
  theme_classic()

saveRDS(result, "data/calibrations/temperature/ds18b20190903-01.RDS")

oracle <- read_csv("data/calibrations/temperature/thermocouple20190903-01.csv") %>% 
  rename(time = Datetime,
         temperature = ThermocoupleTemp) %>% 
  mutate(time = force_tz(time, tz(result$time)))

ggplot(result, aes(time, temperature)) +
  geom_smooth(method = "loess", se = FALSE, color = "blue") +
  geom_point(color = "blue") +
  geom_smooth(data = oracle, method = "loess", se = FALSE, color = "red") +
  geom_point(data = oracle, color = "red") +
  theme_classic()
