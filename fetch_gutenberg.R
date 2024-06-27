library(tidyverse); library(readxl); library(gutenbergr); library(fuzzyjoin)

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
    "36241",       138,        188,       281,         4717,        F,
    "338",         17,         30,        41,          2141,        F,
    "341",         20,         59,        153,         4588,        T,
    "503",         12,         48,        53,          13530,       F,
    "2503",        143,        213,       218,         3811,        F,
    # "4928",        318,        453,       912,         33608,       T,
    "5245",        37,         98,        109,         20527,       T,
    "6145",        19,         61,        248,         8457,        T,
    "6606",        20,         64,        375,         2557,        T,
    "6607",        18,         32,        42,          831,         T,
    "6611",        18,         58,        68,          2181,        T,
    # "7128",        190,        247,       288,         6521,        T,
    "7518",        74,         114,       122,         1709,        F,
    "7871",        22,         62,        68,          4922,        F,
    "7885",        172,        197,       205,         6815,        F,
    "8299",        149,        346,       665,         21518,       T,
    "8599",        33,         47,        54,          9023,        T,
    "9313",        53,         111,       117,         3123,        F,
    "9368",        41,         87,        95,          5171,        F,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA,
    "NA",          NA,         NA,        NA,          NA,          NA
  )

i <- 19

df <- 
  gutenberg_download(lookup$gutenberg_id[i]) %>%
  mutate(text = str_squish(text))

toc <- 
  df %>% 
  slice(lookup$start_toc[i]:lookup$stop_toc[i]) %>% 
  mutate(
    text = str_remove(text,"^[0-9]+\\."),
    # Remove Roman numerals
    text = str_remove(text,"^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\\."),
    text = str_squish(text)
  ) %>%
  filter(!is.na(text)) %>%
  filter(text != "")

y <- 
  df %>%
  mutate(line = row_number()) %>%
  stringdist_left_join(
    toc %>% select(text),
    by = "text",method = "jw", 
    max_dist = 0.2, distance_col = "dist",
    ignore_case = lookup$ignore_case[i]
  ) %>%
  rename(text = text.x, tale = text.y) %>%
  group_by(gutenberg_id,text,line) %>%
  filter(dist == min(dist,na.rm = T) | is.na(dist)) %>%
  ungroup() %>%
  fill(tale) %>% 
  slice(lookup$start_text[i]:lookup$stop_text[i]) %>%
  filter(text != "") %>%
  filter(text != tale) %>%
  group_by(gutenberg_id,tale) %>%
  summarize(text = paste(text,collapse = " ")) %>%
  ungroup()
  
