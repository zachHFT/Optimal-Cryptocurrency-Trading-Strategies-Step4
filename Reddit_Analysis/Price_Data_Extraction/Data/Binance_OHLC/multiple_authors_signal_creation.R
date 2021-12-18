library(tidyverse)
library(dplyr)

##Read files
filenames <- list.files(pattern="+_posts_nrstmin.*csv")

##Create list of author names using filenames 
names <-sub("_.*", "", filenames)

post_times <- list()
for (i in 1:length(filenames)){
  post_times[[i]] <- as.data.frame(read.csv(filenames[i]))$X0
}
names(post_times) <- names

btc_authors <- c("simplelifestyle", "CoinCorner") #actually CoinCorner_Sam

ETHUSD1m <- as.data.frame(read.csv("ETHUSDT-1m-binance.csv"))
BTCUSD1m <- as.data.frame(read.csv("BTCUSDT-1m-binance.csv"))

source("impute.R")

ETHUSD1m.imputed <- impute(prices=ETHUSD1m, gap="min")
BTCUSD1m.imputed <- impute(prices=BTCUSD1m, gap="min")

source("create_signal.R")

signals <- list()
for (i in 1:length(filenames)){
  if(names(post_times)[i] %in% btc_authors){ #use bitcoin data for bitcoin authors 
    signals[[i]] <- create_signal(post_times[[i]], BTCUSD1m.imputed, 'min')
  }else{
    signals[[i]] <- create_signal(post_times[[i]], ETHUSD1m.imputed, 'min')
  }
}
names(signals) <- names

#initialise
old_btc <- BTCUSD1m.imputed
old_eth <- ETHUSD1m.imputed

source("add_signal.R")

for(i in which(names(signals) %in% btc_authors)){
    new_btc <- add_signal(old_btc, signals, i) 
    old_btc <- new_btc
}
for(i in which(!names(signals) %in% btc_authors)){
    new_eth <- add_signal(old_eth, signals, i)
    old_eth <- new_eth
}

BTC_imp_w_signal <- new_btc
ETH_imp_w_signal <- new_eth