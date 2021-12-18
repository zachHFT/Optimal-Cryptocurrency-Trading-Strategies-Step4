library("geckor")
library("dplyr")
library(igraph)
library(ggraph)
library(gganimate)
library(networkDynamic)
library(network)
library(reshape2)
library(ndtv)

CID <- c("bitcoin", "ethereum", "litecoin", "eos")
vs_currency <- "usd"
coin_history <- coin_history(coin_id = CID, vs_currency = vs_currency, days = 364)
coin_id <- with(coin_history, coin_id)
price <- with(coin_history, price)
prices.vec <- c(price[coin_id=="bitcoin"],
                price[coin_id=="ethereum"],
                price[coin_id=="litecoin"],
                price[coin_id=="eos"])

pairs.1 <- combn(1:length(CID), 2)
pairs.2 <- pairs.1[c(2,1),]
pairs <- cbind(pairs.1,pairs.2)
rates <- apply(pairs, 2, FUN = function(x) {price[coin_id == CID[x[1]]]/price[coin_id == CID[x[2]]]})

edge_frame <- data.frame(from=pairs[1,], to=pairs[2,])
rates_network <- graph_from_data_frame(d=edge_frame, directed=TRUE)
adj <- as_adjacency_matrix(rates_network)

tails <- rep(pairs[1,], each=365)
heads <- rep(pairs[2,], each=365)

prices_norm <- BBmisc:::normalize(prices.vec, method="range", range=c(10,100)) 
rates_norm <- BBmisc:::normalize(melt(rates)$value, method="range", range=c(10,100))

vs <- data.frame(onset=0:364, 
                 terminus=1:365, 
                 vertex.id=rep(1:length(CID), each=365), 
                 size = prices_norm) 
es <- data.frame(oneset=0:364, 
                 terminus=1:365, 
                 tail=tails, 
                 head=heads, 
                 rate = rates_norm)

rates_network <- network(adj, matrix.type="adjacency")
rates_network %v% "name" <- CID
rates_network_dynamic <- networkDynamic(rates_network,
                                        edge.spells=es,
                                        vertex.spells=vs,
                                        create.TEAs=TRUE,
                                        vertex.TEA.names="size",
                                        edge.TEA.names="rate")

render.d3movie(rates_network_dynamic,
               vertex.cex='size',
               edge.lwd='rate',
               displaylabels=TRUE,
               label = rates_network %v% "name", 
               label.cex = 0.5,
               nodeSizeFactor=0.01,
               verbose=F)
