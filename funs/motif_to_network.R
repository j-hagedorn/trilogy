
library(tidyverse); library(tidygraph)

tmi <- read_csv("data/tmi.csv")

# Clean up messiness
df <- tmi %>% filter(!duplicated(id)) 

chapter_df <- df %>% select(chapter_id,motif_name = chapter_name) %>% distinct()

ntwk_df <-
  bind_rows(
    tibble(from = "Root", to = unique(df$chapter_id)),
    df %>% ungroup() %>% select(from = chapter_id,to = level_0) %>% distinct(),
    df %>% ungroup() %>% select(from = level_0,to = level_1) %>% distinct(),
    df %>% ungroup() %>% select(from = level_1,to = level_2) %>% distinct(),
    df %>% ungroup() %>% select(from = level_2,to = level_3) %>% distinct(),
    df %>% ungroup() %>% select(from = level_3,to = level_4) %>% distinct(),
    df %>% ungroup() %>% select(from = level_4,to = level_5) %>% distinct()
  ) %>%
  # Need to tidy up in prep grouping, avoid distinct(to, .keep_all = T)
  distinct(to, .keep_all = T) %>% ungroup() %>% 
  filter(!is.na(to) & !is.na(from))
  
motif_graph <- 
  ntwk_df %>% 
  as_tbl_graph(directed = T) %>% 
  activate(edges) %>% filter(!edge_is_multiple()) %>%
  activate(nodes) %>% 
  # Join chapters
  left_join(chapter_df, by = c("name" = "chapter_id")) %>%
  # Join rest of motifs
  left_join(df %>% select(id,motif_name,notes,level), by = c("name" = "id")) %>%
  mutate(motif_name = if_else(is.na(motif_name.x),motif_name.y,motif_name.x)) %>%
  select(name,motif_name,notes,level) %>%
  mutate(
    level = as.numeric(level) + 1,
    level = if_else(is.na(level),0,level),
    root = node_is_root(),
    center = node_is_center(),
    neighbors = centrality_degree(),
    row = row_number()
  ) %>%
  activate(edges) %>%
  left_join(
    df %>% mutate(row = row_number()) %>% 
      select(row,edge_section = id),
    by = c("from" = "row")
  )

rm(ntwk_df); rm(chapter_df); rm(df)

write_graph(motif_graph,"data/motif_graph.graphml", format = "graphml")

