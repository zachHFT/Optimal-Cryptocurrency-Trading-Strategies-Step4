source("impute.R")

ETH1h <- read.csv("ETHUSDT-1h-binance.csv")
ETH1himp <- impute(ETH1h, gap='hour')
write.csv(ETH1himp, "ETHUSDT-1h-binance-imputed.csv")

ETH1m <- read.csv("ETHUSDT-1m-binance.csv")
ETH1mimp <- impute(ETH1h, gap='min')
write.csv(ETH1himp, "ETHUSDT-1m-binance-imputed.csv")

BTC1h <- read.csv("BTCUSDT-1h-binance.csv")
BTC1himp <- impute(BTC1h, gap='hour')
write.csv(BTC1himp, "BTCUSDT-1h-binance-imputed.csv")

BTC1m <- read.csv("BTCUSDT-1m-binance.csv")
BTC1mimp <- impute(BTC1m, gap='min')
write.csv(BTC1mimp, "BTCUSDT-1m-binance-imputed.csv")
