
df <-
  read_lines("fetch/ATU.Master.Hels.txt") %>%
  as_tibble() %>%
  rename(text = value) %>%
   # Remove front matter and index
  slice(173:16129) %>%
  mutate(
    type = case_when(
      str_detect(text,"^\\s$")                ~ NA_character_,
      str_detect(text,"Combinations:")        ~ "combos",
      str_detect(text,"Remarks:")             ~ "remarks",
      str_detect(text,"Literature/Variants:") ~ "litvar",
      str_detect(text,"^[A-Z|\\s].*[0-9]$")   ~ "section",
      str_detect(text,"^[A-Z|\\s]+$")         ~ "heading"
    )
  )
