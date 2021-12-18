library(dplyr)

add_signal <- function(prices, signals, i){
  #signals should be a named list 
  
  prices <- cbind(prices, signals[[i]])
  colnames(prices)[length(colnames(prices))] <- names(signals)[i]
  return(prices)
}