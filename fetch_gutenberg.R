library(tidyverse); library(readxl); library(gutenbergr)

x <- 
  read_excel(
    "data/process_files/tagged_folk_collections.xlsx",
    skip = 3
  ) %>%
  select(site = Name,name = Link) %>%
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

# Make a lookup table with the variables to read in each text consistently

lookup <-
  tribble(
    ~gutenberg_id, ~start_toc, ~stop_toc, ~start_text, ~stop_text, ~ignore_case,
    ############# | ######### | ######## | ########## | ######### | ##########
    "4018",        14,         35,        98,          7548,        F,
    "2198",        23,         54,        61,          7188,        T,
    "36241",       138,        188,       281,         4717,        NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA
  )

i <- 1

df <- 
  gutenberg_download(lookup$gutenberg_id[i]) %>%
  mutate(text = str_squish(text))

toc <- 
  df %>% 
  slice(lookup$start_toc[i]:lookup$stop_toc[i]) %>% 
  mutate(
    text = str_remove(text,"^[0-9]+\\."),
    text = str_extract(text, "[^\\.]+"),
    text = str_squish(text)
  ) %>%
  select(text) %>%
  .$text

library(fuzzyjoin)

y <- 
  df %>%
  stringdist_left_join(
    toc,by = "text",method = "jw", 
    max_dist = 0.2, distance_col = "dist"
  )

y <- 
  df %>%
  mutate(
    tale = if_else(
      str_detect(
        text,
        regex(
          paste(toc,collapse = "|"),
          ignore_case = lookup$ignore_case[i]
        )
      ),
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
  
