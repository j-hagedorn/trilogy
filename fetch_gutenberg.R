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

df <-
  gutenberg_works(gutenberg_id %in% x$id) %>%
  distinct(gutenberg_id,.keep_all = T) %>%
  mutate(
    link = paste0(
      "https://www.gutenberg.org/cache/epub/",
      gutenberg_id,"/pg",gutenberg_id,".txt"
    )
  )

# Folklore bookshelf
# https://www.gutenberg.org/ebooks/bookshelf/37