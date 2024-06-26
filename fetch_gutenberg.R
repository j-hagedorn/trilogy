library(tidyverse); library(readxl); library(gutenbergr)

x <- 
  read_excel(
    "data/process_files/tagged_folk_collections.xlsx",
    col_names = c("site","price","rating","reviews","brand","name","type")
  ) %>%
  select(site,name) %>%
  filter(str_detect(site,"\\.txt$")) %>%
  mutate(
    id = str_extract(site,"epub/\\s*(.*?)\\s*/pg"),
    id = str_remove(id,"^epub/"),
    id = str_remove(id,"/pg$")
  )

# Folklore bookshelf
# https://www.gutenberg.org/ebooks/bookshelf/37

ref <-
  gutenberg_works(gutenberg_id %in% x$id) %>%
  distinct(gutenberg_id,.keep_all = T) %>%
  mutate(
    link = paste0(
      "https://www.gutenberg.org/cache/epub/",
      gutenberg_id,"/pg",gutenberg_id,".txt"
    )
  )

# Read in texts

lookup <-
  tribble(
    ~gutenberg_id, ~start_toc, ~stop_toc, ~start_text, ~stop_text,
    ############# | ######### | ######## | ########## | #########
    "4018",        14,         35,        98,          7548,
    "2198",        23,         54,        61,          7188,
    "36241",       138,        188,       281,         4717,
    "NA",          NA,         NA,        NA,          NA,
    "NA",          NA,         NA,        NA,          NA,
    "NA",          NA,         NA,        NA,          NA,
    "NA",          NA,         NA,        NA,          NA,
    "NA",          NA,         NA,        NA,          NA
  )

i <- 3

df <- gutenberg_download(lookup$gutenberg_id[i])

toc <- 
  df %>% 
  slice(lookup$start_toc[i]:lookup$stop_toc[i]) %>% 
  mutate(
    text = str_squish(text),
    text = str_remove(text,"[0-9]+\\."),
    text = str_extract(text, "[^\\.]+"),
    text = str_squish(text)
  ) %>%
  .$text

y <- 
  df %>%
  mutate(
    text = str_squish(text),
    tale = if_else(
      str_detect(text,regex(paste(toc,collapse = "|"),ignore_case = T)),
      text,NA_character_
    )
  ) %>%
  fill(tale) %>% 
  slice(lookup$start_text[i]:lookup$stop_text[i]) %>%
  filter(text != "") %>%
  filter(text != tale) %>%
  group_by(gutenberg_id,tale) %>%
  summarize(text = paste(text,collapse = " ")) %>%
  ungroup()
  
