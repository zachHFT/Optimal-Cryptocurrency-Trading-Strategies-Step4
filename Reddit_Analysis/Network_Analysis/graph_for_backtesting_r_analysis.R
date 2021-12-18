library(igraph)
library(ggplot2)
library(dplyr)
library(influential)
library(ggraph)
library(graphlayouts)

authors <- scan("g_nodes.txt", what="", sep="\n") #scan in node labels
g <- read_graph("graph_for_backtesting.gml", format='gml') #get graph from gml file
V(g)$names <- authors #assign node labels to graph 

#calculate some properties of the nodes for plotting
deg.in <- degree(g, mode="in") #in degree
deg.out <- degree(g, mode='out') #out degree
deg.total <- degree(g, mode='total')

node_data <- data.frame(Author=authors, InDegree=deg.in, OutDegree=deg.out, Degree=deg.total)
node_data <- node_data %>% arrange(desc(deg.in))

summary(deg.in)
hist(deg.in)
boxplot(deg.in)

##those with highest in degree have their comments replied to the most often

top_fifty <- node_data[1:50,] #top fifty redditors measured by in degree
top_fifty %>% ggplot(aes(x=reorder(Author, desc(InDegree), sum), y=InDegree)) + #reorder bar heights to descending
  geom_bar(stat='identity') +
  xlab("Reddit author") +
  ggtitle(label = "Top 50 reddit authors in crypto related subreddits by in-degree") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) #rotate axis labels

##those with highest out degree are the most active commenters

top_commenters <- node_data %>% arrange(desc(OutDegree)) %>% filter(OutDegree > 0) #top redditors measured by out degree
top_commenters[1:50,] %>% ggplot(aes(x=reorder(Author, desc(OutDegree), sum), y=OutDegree)) + #reorder bar heights to descending
  geom_bar(stat='identity') +
  xlab("Reddit author") +
  ggtitle(label = "Top 50 reddit authors in crypto related subreddits by out-degree") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),) #rotate axis labels

##identify influencers in the network using recent network methods 
##https://cran.r-project.org/web/packages/influential/vignettes/Vignettes.html#IVI

IVI <- ivi(g, vertices=V(g), directed=TRUE, loops=FALSE, scaled=TRUE, mode='in', d=3)

most_influential_authors <- V(g)$names[order(IVI, decreasing=TRUE)[1:10]]
write(most_influential_authors, file='most_influential_authors')

network_vis <- cent_network.vis(graph = g,
                                cent.metric = IVI,
                                layout='grid',
                                directed = TRUE,
                                plot.title = "IVI-based Network",
                                legend.title = "IVI value")

network_vis

####### set up graph for visualisation purposes #######

n <- 3
in_deg_more_than_n <- V(g)[degree(g, mode='in') > n]
g_reduced <- induced_subgraph(g, vids=in_deg_more_than_n)
largest_connected_component_g_reduced_index <- which(components(g_reduced)$membership==1)
largest_connected_component_g_reduced <- induced_subgraph(g_reduced,largest_connected_component_g_reduced_index)
largest_connected_component_g_reduced <- largest_connected_component_g_reduced %>%
  set_vertex_attr("IVIcentrality", value=IVI[which(V(g)$names %in% V(largest_connected_component_g_reduced)$names)])


write(V(largest_connected_component_g_reduced)$x, file='node_position_x')
write(V(largest_connected_component_g_reduced)$y, file='node_position_y')
write_graph(largest_connected_component_g_reduced, file="largest_connected_component_g_reduced", format="gml")

##################centrality measures##############################################
bc <- function(g) {betweenness(g, v=V(g), directed=TRUE)}
nc <- function(g) {neighborhood.connectivity(g, vertices=V(g), mode='in')}
Hindex <- function(g) {h_index(g, vertices=V(g), mode='in')}
LHindex <- function(g) {lh_index(g, vertices=V(g), mode='in')}
ci <- function(g) {collective.influence(g, vertices=V(g), mode='in', d=3)}
cRank <- function(g) {clusterRank(g, vids=V(g), directed=TRUE, loops=FALSE)}

centrality.measures.functions <- list("bc"=bc, "nc"=nc, "Hindex"=Hindex, "LHindex"=LHindex,
                            "ci"=ci, "cRank"=cRank)
N <- length(V(g))
centrality.measures <- matrix(rep(0, N*6), nrow=N, ncol=6)
colnames(centrality.measures) <- names(centrality.measures.functions)
for (i in 1:6){
  centrality.measures[,i] <- centrality.measures.functions[[i]](g)
}

centrality.measures <- cbind(centrality.measures, deg.total)
###########################################################################


