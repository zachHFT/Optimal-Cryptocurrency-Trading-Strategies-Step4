library(shiny)
library(igraph)
library(ggplot2)
library(dplyr)
library(influential)
library(ggraph)
library(graphlayouts)
library(visNetwork)
library(gghighlight)
library(DT)
library(data.table)

############## full graph investigation #################

authors <- scan("g_nodes.txt", what="", sep="\n") #scan in node labels
g <- read_graph("graph_for_backtesting.gml", format='gml') #get graph from gml file
V(g)$names <- authors #assign node labels to graph 

#calculate some properties of the nodes for plotting
deg.in <- degree(g, mode="in") #in degree
deg.out <- degree(g, mode='out') #out degree
deg.total <- degree(g, mode='total')

node_data <- data.frame(Author=authors, InDegree=deg.in, OutDegree=deg.out, Degree=deg.total)
node_data <- node_data %>% arrange(desc(deg.in))

##those with highest in degree have their comments replied to the most often

top_thirty_by_in_deg <- node_data[1:30,] #top fifty redditors measured by in degree
plot_indeg <- top_thirty_by_in_deg %>% ggplot(aes(x=reorder(Author, desc(InDegree), sum), y=InDegree)) + #reorder bar heights to descending
  geom_bar(stat='identity', fill="#FF4500") +
  xlab("Reddit author") +
  ggtitle(label = "Top 30 reddit authors in crypto related subreddits by in-degree") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) #rotate axis labels


##those with highest out degree are the most active commenters

top_commenters <- node_data %>% arrange(desc(OutDegree)) %>% filter(OutDegree > 0) #top redditors measured by out degree
plot_outdeg <- top_commenters[1:30,] %>% ggplot(aes(x=reorder(Author, desc(OutDegree), sum), y=OutDegree)) + #reorder bar heights to descending
  geom_bar(stat='identity', fill="#FF4500") +
  xlab("Reddit author") +
  ggtitle(label = "Top 30 reddit authors in crypto related subreddits by out-degree") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),) #rotate axis labels

##############################################################

######## reduced graph visualisation ###########

G <- read_graph("largest_connected_component_g_reduced", format="gml")

nodes <- data.frame(id=as.vector(V(G)),
                    #label=as.vector(V(G)$names),
                    value=1e7*V(G)$IVIcentrality,
                    x=V(G)$x,
                    y=V(G)$y)
edges <- data.frame(from=as.vector(tail_of(G,E(G))), 
                    to=as.vector(head_of(G,E(G))),
                    arrows="to")

##################################################


ui <- fluidPage(
  titlePanel(strong("Centrality and degree of authors in the largest connected component of Author-Commenter Network")),
  
  fluidRow(
    column(6,
           offset=3,
           h5("Here, the nodes are sized according to their centrality scores. You can play around with the network in several ways: drag nodes (or the whole graph),
              highlight nodes and edges, and zoom. Click on a node to get more details about it."),
           visNetworkOutput(outputId = 'network'),
           tableOutput("shiny_return")
           )
  ),
  
  fluidRow(
    column(6,
           offset=6.5,
           h2("Most active responders"),
           plotOutput(outputId='outdegree')
    ),
    column(6,
           offset = 0,
           h2("Most discussed authors"),
           plotOutput(outputId = 'indegree')
    )
  )
)


server <- function(input,output){
  output$network <- renderVisNetwork({
    
    visN <- visNetwork(nodes=nodes,edges=edges) %>% 
      visIgraphLayout() %>%
      visNodes(color=list(background="#FF4500", 
                          border='white', 
                          hover=list(background='#7FFFD4'),
                          highlight=list(background='#7FFFD4', border='white')),
               scaling=list(min=0.1,max=250)) %>%
      visEdges(color=list(color='grey', hover='#7FFFD4'), 
               width=8) %>%
      visInteraction(dragNodes = T, 
                     dragView = T, 
                     zoomView = T,
                     hover=T) %>%
      visEvents(select = "function(nodes) { Shiny.onInputChange('current_node_id', nodes.nodes);}") %>%
      visLegend() 
  })
  output$shiny_return <- renderTable({
    data <- data.table("Author" = V(G)$names[which(V(G) %in% input$current_node_id)],
                       "IVI centrality" = V(G)$IVIcentrality[which(V(G) %in% input$current_node_id)],
                       "In degree" = degree(g, mode='in')[which(V(g)$names %in% V(G)$names[unlist(input$current_node_id)])],
                       "Out degree" = degree(g, mode='out')[which(V(g)$names %in% V(G)$names[unlist(input$current_node_id)])])
  })
  
  output$indegree <- renderPlot({
    plot_indeg + gghighlight(Author == V(G)$names[which(V(G) %in% input$current_node_id)])
  })
  
  output$outdegree <- renderPlot({
    plot_outdeg + gghighlight(Author == V(G)$names[which(V(G) %in% input$current_node_id)])
  })
}

shinyApp(ui=ui,server=server)

rsconnect::deployApp('/Users/kc/Documents/StatCompVis/CryptoProject/Optimal-Cryptocurrency-Trading-Strategies-Step2/Reddit_Analysis/Network_Analysis')
