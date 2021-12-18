library("dplyr")
library(ggplot2)
library(reshape2)
library(lmtest)
library(quantmod)
library(xtable)

filenames <- list.files(pattern="+-imputed.*csv")

names <-sub("-b.*", "", filenames)

dfdata <- list()
for (i in 1:length(filenames)){
  dfdata[[i]] <- as.data.frame(read.csv(filenames[i]))
}
names(dfdata) <- names

dfdata.logreturn <- lapply(1:length(names), 
                           FUN = function(i){dfdata[[i]] %>% 
                               mutate(logreturn = c(0, diff(log(close)))) %>%
                               select(timestamp, logreturn)})
names(dfdata.logreturn) <- names

logreturn.hourly <- data.frame(btc = dfdata.logreturn$`BTCUSDT-1h`$logreturn,
                               eth = dfdata.logreturn$`ETHUSDT-1h`$logreturn)

par(mfrow=c(1,2))
acf(logreturn.hourly$btc, main="ACF for hourly Bitcoin")
acf(logreturn.hourly$eth, main="ACF for hourly Ethereum")

aTSA:::adf.test(logreturn.hourly$btc)
aTSA:::adf.test(logreturn.hourly$eth)

grangertest(btc ~ eth, order = 1, data=logreturn.hourly)
grangertest(eth ~ btc, order = 5, data=logreturn.hourly)

order <- c(1:5)
btc_cause_eth <- c()
eth_cause_btc <- c()

for (ord in order){
  btc_cause_eth <- rbind(btc_cause_eth, 
                         c(ord, grangertest(btc ~ eth, order = ord, data=logreturn.hourly)$`Pr(>F)`[2]))
  eth_cause_btc <- rbind(eth_cause_btc, 
                         c(ord, grangertest(eth ~ btc, order = ord, data=logreturn.hourly)$`Pr(>F)`[2]))
}

colnames(btc_cause_eth) <- c("Lag", "p-value")
colnames(eth_cause_btc) <- c("Lag", "p-value")

xtable(t(eth_cause_btc), 
       digits=3, 
       caption=c("Granger causality test scores for predicting Bitcoin returns with ethereum returns"))

xtable(t(btc_cause_eth), 
       digits=3, 
       caption=c("Granger causality test scores for predicting ethereum returns with Bitcoin returns"))

