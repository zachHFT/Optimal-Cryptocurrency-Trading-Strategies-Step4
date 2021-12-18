#source("multiple_authors_signal_creation.R")
btc_v_authors <- lm(data=BTC_imp_w_signal, close ~ simplelifestyle + CoinCorner)
plot(btc_v_authors)

