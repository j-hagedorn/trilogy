library(tidyverse); library(tidygraph)

x <-
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
    coreness = node_coreness(),
    bridging = node_bridging_score(),
    connectivity = node_connectivity_impact()
  )

x %>% activate(nodes) %>% as_tibble() %>% View()

x %>%
  ggraph() +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name, alpha = 0.1)) +
  theme_void()

library(visNetwork)

p <-
  x %>%
  visIgraph() %>%
  visIgraphLayout(layout = "layout_with_kk")

visSave(p,"docs/atu_network.html")
