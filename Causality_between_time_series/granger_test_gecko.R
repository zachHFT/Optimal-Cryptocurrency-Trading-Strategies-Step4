library("geckor")
library("dplyr")
library(ggplot2)
library(reshape2)
library(lmtest)

CID <- c("bitcoin", "ethereum", "litecoin", "eos")
vs_currency <- "usd"
coin_history <- coin_history(coin_id = CID, vs_currency = vs_currency, days = 364)
coin_id <- with(coin_history, coin_id)
price <- with(coin_history, price)
logreturns.df <- data.frame(btc = diff(log(price[coin_id=="bitcoin"])),
                            eth = diff(log(price[coin_id=="ethereum"])),
                            ltc = diff(log(price[coin_id=="litecoin"])),
                            eos = diff(log(price[coin_id=="eos"])),
                            day = 1:364)
logreturns.df.melt <- melt(logreturns.df, id.vars = "day", variable.name = "price")

ggplot(logreturns.df.melt, aes(x=day, y=100*value)) + 
  geom_line() + 
  facet_grid(price ~ .)

grangertest(btc ~ ltc, order = 1, data=logreturns.df)


