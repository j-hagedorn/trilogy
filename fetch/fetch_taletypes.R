library(tidyverse)
tmi <- read_csv("data/tmi.csv")

atu_df <-
  read_lines("fetch/ATU.Master.Hels.txt", locale = locale(encoding = "UTF-8")) %>%
  as_tibble() %>%
  rename(text = value) %>%
  # Remove front matter and index
  slice(173:16129) %>%
  mutate(
    type = case_when(
      str_detect(text,"^\\s$")                     ~ NA_character_,
      str_detect(text,"Combinations:")             ~ "combos",
      str_detect(text,"Remarks:")                  ~ "remarks",
      str_detect(text,"Literature/Variants:")      ~ "litvar",
      str_detect(lag(text),"Literature/Variants:") ~ "provenance",
      str_detect(text,"^[0-9]")                    ~ "tale_type",
      str_detect(text,"^[A-Z].*[0-9]$") & str_to_upper(text) == text ~ "division",
      str_detect(text,"^[[A-Za-z]|\\s].*[0-9]$")   ~ "sub_division",
      str_detect(text,"^[A-Z|\\s]+$")              ~ "chapter"
    )
  ) %>%
  mutate(chapter = if_else(type == "chapter",text,NA_character_)) %>%
  fill(chapter,.direction = "down") %>%
  mutate(division = if_else(type == "division",text,NA_character_)) %>%
  group_by(chapter) %>%
  fill(division,.direction = "down") %>%
  mutate(sub_division = if_else(type == "sub_division",text,NA_character_)) %>%
  group_by(chapter,division) %>%
  fill(sub_division,.direction = "down") %>%
  mutate(
    atu_id = if_else(
      type == "tale_type",
      # number before space OR number and asterisk OR number and single letter
      str_extract(text,"^[0-9]+[:space:]|^[0-9]+\\*{1,}[:space:]|^[0-9]+[A-Z]{1,}[:space:]|^[0-9]+[A-Z]{1,}+\\*{1,}[:space:]"),
      NA_character_
    ),
    # Remove ID from text field
    text = case_when(
      type == "tale_type" ~ str_remove(text,"^[0-9]+[:space:]|^[0-9]+\\*{1,}[:space:]|^[0-9]+[A-Z]{1,}[:space:]|^[0-9]+[A-Z]{1,}+\\*{1,}[:space:]"),
      is.na(type)         ~ text,
      TRUE ~ text
    )
  ) %>%
  mutate(
    tale_name = if_else(
      type == "tale_type",
      # everything up to first period
      str_extract(text,".*?\\."),
      NA_character_
    ),
    # Remove ID from text field
    text = case_when(
      type == "tale_type" ~ str_remove(text,".*?\\."),
      is.na(type)         ~ text,
      TRUE ~ text
    )
  ) %>%
  group_by(chapter,division,sub_division) %>%
  fill(atu_id,.direction = "down") %>%
  fill(tale_name,.direction = "down") %>%
  ungroup() %>%
  filter(!is.na(atu_id)) %>%
  filter(text != "") %>%
  group_by(chapter,division,sub_division,atu_id,tale_name) %>%
  fill(type,.direction = "down") %>%
  mutate(type = if_else(is.na(type),"tale_type",type)) %>%
  group_by(chapter,division,sub_division,atu_id,tale_name,type) %>%
  summarize(text = paste(text,collapse = " ")) %>%
  group_by(chapter,division,sub_division,atu_id,tale_name) %>%
  pivot_wider(names_from = type, values_from = text) %>%
  ungroup() %>%
  mutate(
    chapter = str_to_title(chapter),
    division = str_to_title(division),
    division = str_replace(division, "\\?", "\\-"),
    sub_division = str_to_title(sub_division),
    sub_division = str_replace(sub_division, "\\?", "\\-"),
    atu_id  = str_trim(atu_id),
    tale_name = str_remove(tale_name, "\\.$"),
    litvar  = str_remove(litvar,"^Literature/Variants:|^Literature/Variants: "),
    remarks = str_remove(remarks,"^Remarks:|^Remarks: "),
    combos  = str_remove(combos,"^Combinations:|^Combinations: "),
    combos  = str_remove(combos,"^ This type is usually combined with one or more other types, esp.")
  ) %>%
  mutate_at(
    vars(tale_name:remarks),
    list(~str_remove_all(., "\\?"))
  ) %>%
  mutate_all(list(~str_squish(.))) %>%
  # Manually remove duplicates where there is a clear preference
  filter(!(atu_id == "934D" & tale_name == "Nothing Happens without God")) %>%
  mutate(tale_name = str_replace(tale_name,"^934D1 ","")) %>%
  # Otherwise, keep initial version (this only removes 802A*)
  distinct(atu_id, .keep_all = T)

atu_seq <-
  atu_df %>%
  select(atu_id,tale_type) %>%
  mutate(motifs = str_extract_all(tale_type,"\\[[A-Z][1-9](.*?)\\]") ) %>%
  select(-tale_type) %>%
  unnest(motifs) %>%
  mutate(
    motifs = str_remove_all(motifs,"cf. |Cf. |e.g. "),
    motifs = str_remove(motifs, "Type [^\\]]+"),
    motifs = str_replace_all(motifs,";",","),
    motifs = str_replace(motifs,", \\]","]")
  ) %>%
  filter(!is.na(motifs)) %>%
  group_by(atu_id) %>%
  mutate(motif_order = row_number()) %>%
  select(atu_id,motif_order,motifs) %>%
  mutate(
    motifs = str_remove_all(motifs,"^\\[|\\]$"),
    # Split into list of elements
    motifs = str_split(motifs,",|;")
  ) %>% 
  ungroup() %>%
  # Convert all lists to same length for unnesting
  mutate(motifs = map(motifs, `length<-`, max(lengths(motifs)))) %>%
  unnest(motifs) %>%
  mutate(motifs = str_trim(motifs)) %>%
  pivot_wider(
    names_from = motif_order, 
    names_prefix = "ord_",
    values_from = motifs,
  ) %>% 
  unnest() %>%
  filter(if_any(-atu_id,~!is.na(.))) 

# Discretely list ranges of motifs before expanding:
# E.g. Reference to range of motifs in sequence not explicitly named (e.g. "F611.1.11�F611.1.15")
motif_ranges <- 
  atu_seq %>%
  filter(if_any(starts_with("ord_"),~str_detect(.,"�|ff"))) %>%
  pivot_longer(
    starts_with("ord_"),names_to = "motif_order", values_to = "motif_range"
  ) %>%
  filter(str_detect(motif_range,"�|ff")) %>%
  mutate(
    id = str_remove(motif_range,"�.*$"),
    ord_init = str_remove(motif_range,"�.*$"),
    ord_last = str_remove(motif_range,"^.*�"),
    regex_formula = if_else(
      str_detect(motif_range,"ff"),
      paste0("^",str_remove(motif_range,"ff.*$"),".*$"),
      NA_character_
    )
  ) 

x <-
  tmi %>% select(id) %>%
  inner_join(
    motif_ranges,
    join_by(between(id,ord_init,ord_last))
  ) %>%
  select(motif_range,motif_id = id.x)

atu_seq <-
  atu_seq %>%
  left_join(x,by = c('ord_1' = 'motif_range')) %>%
  mutate(ord_1 = if_else(str_detect(ord_1,"�"),motif_id,ord_1))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_2' = 'motif_range')) %>%
  mutate(ord_2 = if_else(str_detect(ord_2,"�"),motif_id,ord_2))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_3' = 'motif_range')) %>%
  mutate(ord_3 = if_else(str_detect(ord_3,"�"),motif_id,ord_3))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_4' = 'motif_range')) %>%
  mutate(ord_4 = if_else(str_detect(ord_4,"�"),motif_id,ord_4))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_5' = 'motif_range')) %>%
  mutate(ord_5 = if_else(str_detect(ord_5,"�"),motif_id,ord_5))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_6' = 'motif_range')) %>%
  mutate(ord_6 = if_else(str_detect(ord_6,"�"),motif_id,ord_6))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_7' = 'motif_range')) %>%
  mutate(ord_7 = if_else(str_detect(ord_7,"�"),motif_id,ord_7))%>%
  select(-motif_id) %>%
  left_join(x,by = c('ord_8' = 'motif_range')) %>%
  mutate(ord_8 = if_else(str_detect(ord_8,"�"),motif_id,ord_8))%>%
  select(-motif_id) %>%
  # Now fill down into NA areas by group
  group_by(atu_id) %>%
  fill(starts_with("ord_"), .direction = "down") %>% 
  expand(
    ord_1, ord_2, ord_3, ord_4, ord_5, ord_6, ord_7, ord_8,
    ord_9, ord_10,ord_11,ord_12,ord_13,ord_14,ord_15,ord_16, 
    ord_17,ord_18,ord_19,ord_20,ord_21,ord_22
  ) %>%
  mutate(tale_variant = row_number()) %>%
  group_by(atu_id,tale_variant) %>%
  pivot_longer(
    starts_with("ord_"),names_to = "motif_order", values_to = "motif"
  ) %>%
  filter(!is.na(motif)) %>%
  mutate(
    motif_order = str_remove(motif_order,"^ord_"),
    motif_order = as.numeric(motif_order)
  ) %>%
  distinct()

# Remove temporary dataframes
rm(motif_ranges); rm(x); rm(y)

atu_combos <-
  atu_df %>%
  select(atu_id, combos) %>%
  mutate(
    combos = str_squish(combos),
    combos = str_remove_all(combos, "This type is usually combined with episodes of one or more other types"),
    combos = str_remove_all(combos, "This type is often combined with one or more other types"),
    combos = str_remove_all(combos, "This tale is often combined with one or more other tales"),
    combos = str_remove_all(combos, "Various combinations but no type frequently|Sometimes combined with"),
    combos = str_remove_all(combos, "Usually in combination with|Usually combined with|\\(only version 3\\)"),
    combos = str_replace_all(combos, "; frequently introduced by Type",","),
    combos = str_replace_all(combos, "sometimes of |and |also |and also |of |esp |\\.|;",","),
    combos = str_split(combos,",")
  ) %>%
  unnest(combos) %>%
  mutate(
    combos = str_squish(combos),
    combos = if_else(combos %in% c("","esp","lying"),NA_character_,combos),
    range = if_else(str_detect(combos,"�"),combos, NA_character_)
  ) %>%
  separate(range,c("from","to"),sep = "�") %>%
  mutate(
    to = if_else(
      str_detect(to,"^[A-Z]$"),
      paste0(str_remove(from,"[A-Z]$"),to),
      to
    ),
    from = if_else(
      str_detect(from,"^[A-Z]$"),
      paste0(str_remove(to,"[A-Z]$"),from),
      from
    )
  ) 

x <- 
  atu_df %>% select(atu_id) %>% arrange(atu_id) %>%
  left_join(
    atu_combos,
    join_by(between(atu_id,from,to))
  ) %>%
  rename(atu_id = atu_id.y, atu_id_combo = atu_id.x) %>%
  filter(!is.na(atu_id)) %>%
  select(atu_id,atu_id_combo,from,to)
  
atu_combos <-
  atu_combos %>%
  mutate(combos = if_else(str_detect(combos,"�"),NA_character_,combos)) %>%
  select(atu_id,combos) %>%
  left_join(x %>% select(atu_id,atu_id_combo), by = 'atu_id') %>%
  mutate(combos = if_else(is.na(combos),atu_id_combo,combos)) %>%
  select(atu_id,combos) %>%
  distinct(.keep_all = T) %>%
  filter(!is.na(combos))

rm(x)

# write_csv(atu_df,"data/atu_df.csv")
# write_csv(atu_seq,"data/atu_seq.csv")
# write_csv(atu_combos,"data/atu_combos.csv")

