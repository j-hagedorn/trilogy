library(tidyverse); library(tidygraph); library(igraph)

atu_graph <-
  atu_seq %>%
  group_by(atu_id) %>%
  filter(tale_variant == min(tale_variant)) %>%
  group_by(atu_id,tale_variant) %>%
  mutate(to = lead(motif)) %>%
  rename(from = motif) %>%
  select(-motif_order) %>%
  filter(!is.na(to)) %>%
  as_tbl_graph() %>%
  activate(nodes) %>%
  mutate(
    coreness_in = node_coreness(mode = "in"),
    coreness_out = node_coreness(mode = "out"),
    coreness_all = node_coreness(mode = "all"),
    constraint = node_constraint(),
    bridging = node_bridging_score(),
    connectivity = node_connectivity_impact()
  )

write_graph(atu_graph,"data/atu_graph.graphml", format = "graphml")

combos_graph <-
  atu_combos %>%
  rename(from = atu_id, to = combos) %>%
  as_tbl_graph() 

write_graph(combos_graph,"data/combos_graph.graphml", format = "graphml")

# x %>% 
#   activate(nodes) %>% 
#   as_tibble() %>% 
#   left_join(
#     tmi %>% select(id, motif_name), 
#     by = c('name' = 'id')
#   ) %>%
#   View()
# 
# x %>%
#   ggraph() +
#   geom_edge_link() +
#   geom_node_point() +
#   geom_node_text(aes(label = name, alpha = 0.1)) +
#   theme_void()
# 
# library(visNetwork)
# 
# p <-
#   x %>%
#   visIgraph() %>%
#   visIgraphLayout(layout = "layout_with_kk")
# 
# visSave(p,"docs/atu_network.html")
