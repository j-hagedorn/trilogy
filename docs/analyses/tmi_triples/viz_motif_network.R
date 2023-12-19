
library(tidygraph); library(igraph); library(visNetwork); library(ggraph)

source("funs/motif_to_network.R")

x <-
ntwk  %>%
  create_layout(layout = "dendrogram", circular = T) 
  
visIgraph(x) 

  ggraph(ntwk, 'dendrogram', circular = TRUE) + 
    geom_edge_elbow() + 
    coord_fixed()
  