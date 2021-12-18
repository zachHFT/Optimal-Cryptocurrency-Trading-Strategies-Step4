library(imputeTS)
library(dplyr)
library(tidyr)
library(lubridate)

create_signal <- function(post_times, prices, gap){
  post_times <- data.frame(post_times=unique(as.POSIXct(post_times)))
  
  post_times$signal <- rep(1, times = length(post_times$post_times)) 
  post_times <- post_times %>% 
    complete(post_times = seq(min(prices$timestamp), max(prices$timestamp), by=gap)) 
  
  signal <- with(post_times, signal)
  signal[is.na(signal)] <- 0

  return(signal)
}









