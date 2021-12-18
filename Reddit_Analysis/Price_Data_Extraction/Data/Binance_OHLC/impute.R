library(imputeTS)
library(dplyr)
library(tidyverse)

strip.tz <- function(dt) { # remove timezone from output cuz it's causing issue
  fmt <- "%Y-%m-%d %H:%M:%S"
  strptime(strftime(dt, format = fmt, tz=""), format = fmt, tz="UTC")
}

impute <- function(prices, gap){
  prices <- prices %>%
    mutate(timestamp = as.POSIXlt(timestamp, format = "%Y-%m-%d %H:%M:%S")) %>%
    mutate(timestamp = strip.tz(timestamp)) %>%
    complete(timestamp = seq(min(timestamp), max(timestamp), by=gap))
  
  close_with_na <- with(prices, close)
  prices$close <- na_kalman(close_with_na)

  return(prices)
}