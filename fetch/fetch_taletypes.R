
library(tidyverse)

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
  # Manually remove duplicates
  filter(!(atu_id == "934D" & tale_name == "Nothing Happens without God")) %>%
  mutate(tale_name = str_replace(tale_name,"^934D1 ",""))


atu_seq <-
  atu_df %>%
  select(atu_id,tale_type) %>%
  mutate(motifs = str_extract_all(tale_type,"\\[[A-Z][1-9](.*?)\\]") ) %>%
  select(-tale_type) %>%
  unnest(motifs) %>%
  mutate(
    motifs = str_remove_all(motifs,"cf. |Cf. |e.g. "),
    motifs = str_remove(motifs, "Type [^\\]]+")  
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
  filter(if_any(-atu_id,~!is.na(.))) %>%
  group_by(atu_id) %>%
  # Need to address these issues, here (before expanding):
  # Reference to motif at beginning of sequence which is not explicitly named (e.g. "A1750ff.")
  # Reference to range of motifs in sequence not explicitly named (e.g. "F611.1.11�F611.1.15")
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

atu_combos <-
  atu_df %>%
  select(atu_id, combos) %>%
  mutate(
    combos = str_squish(combos),
    combos = str_remove_all(combos, "This type is usually combined with episodes of one or more other types"),
    combos = str_remove_all(combos, "and |also |and also |esp |\\."),
    combos = str_split(combos,",")
  ) %>%
  unnest(combos) %>%
  mutate(
    combos = str_squish(combos),
    combos = if_else(combos == "",NA_character_,combos)
  )

# write_csv(atu_df,"data/atu_df.csv")
# write_csv(atu_seq,"data/atu_seq.csv")
# write_csv(atu_combos,"data/atu_combos.csv")

