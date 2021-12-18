library(igraph)
library(ggplot2)
library(ggraph)
library(dplyr)
library(visNetwork)
library(graphlayouts)
library(qgraph)
library(bAIo-lab/muvis)

g <- read_graph("bipartite_crypto_authors_subs.gml", format="gml")
nodes_labels <- read.csv("bipartite_crypto_authors_subs_nodes.csv")
authors <- read.csv('authors_r_cryptocurrency.csv')
V(g)$names <- nodes_labels$X0

g <- g %>% set_vertex_attr('type', index=V(g)[which(V(g)$names %in% authors$X0)], value=T)
g <- g %>% set_vertex_attr('type', index=V(g)[which(!(V(g)$names %in% authors$X0))], value=F)

V(g)$color <- plyr:::mapvalues(V(g)$type, from = c(0, 1), to = c("cyan", "orange"))
E(g)$color <- "grey"

g_subreddits <- bipartite_projection(g)$proj1

par(mfrow=c(1,2))
# Community detection (by optimizing modularity over partitions):
clp <- cluster_fast_greedy(g_subreddits)
#class(clp)
# Community detection returns an object of class "communities"which igraph knows how to plot:

layout.by.attr <- function(graph, wc, cluster.strength=1,layout=layout.auto) {  
  g <- graph.edgelist(get.edgelist(graph)) # create a lightweight copy of graph w/o the attributes.
  E(g)$weight <- 1
  
  attr <- cbind(id=1:vcount(g), val=wc)
  g <- g + vertices(unique(attr[,2])) + igraph::edges(unlist(t(attr)), weight=cluster.strength)
  
  l <- layout(g, weights=E(g)$weight)[1:vcount(graph),]
  return(l)
}

plot(clp, g_subreddits, layout=layout.by.attr(g_subreddits, V(g_subreddits)))
legend()


#layout_as_bipartite(g, hgap = 1, vgap = 1, maxiter = 100)

addNodes <- data.frame( color = c("cyan","orange"),
                      label = c("Subreddits", "Authors")) 

visIgraph(g, layout = "layout.bipartite", idToLabel = F) %>% 
  visLegend(addNodes=addNodes) #%>%
  visNodes(id=V(g)[which(V(g)$names=='CryptoCurrency')], label="CryptoCurrency", shape='dot')
  
par(mfrow=c(2,2))
visIgraph(bipartite_projection(g)$proj1)
visIgraph(bipartite_projection(g)$proj2)

freq_authors <- read.csv("freq_authors.csv")

V(g)$clu <- as.character(membership(cluster_louvain(g)))
V(g)$size <- degree(g)

bb <- layout_as_backbone(g,keep = 0.4)
E(g)$col <- FALSE
E(g)$col[bb$backbone] <- TRUE

ggraph(g,layout = "manual",x = bb$xy[,1],y = bb$xy[,2])+
  geom_edge_link0(aes(edge_colour = col),edge_width = 0.1)+
  geom_node_point(shape = 21)+
  scale_fill_brewer(palette = "Set1")+
  scale_edge_color_manual(values=c(rgb(0,0,0,0.3),rgb(0,0,0,1)))+
  theme_graph()+
  theme(legend.position = "none")


g_palette <- c("#1A5878", "#C44237", "#AD8941", "#E99093", 
                 "#50594B", "#8968CD", "#9ACD32")


