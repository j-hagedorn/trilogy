
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
  fill(sub_division,.direction = "down")
  
