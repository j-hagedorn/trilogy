
library(tidyverse)

df <-
  read_lines("fetch/ATU.Master.Hels.txt") %>%
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
  filter(text != "")

  
