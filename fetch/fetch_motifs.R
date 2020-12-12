# get_motifs.R

library(tidyverse); library(rvest)

# Full online work: https://en.m.wikisource.org/wiki/Motif-Index_of_Folk-Literature

# url <- "https://sites.ualberta.ca/~urban/Projects/English/Content/a.htm"
# section_name <- "Myths"

get_motifs <- function(section_name,url){
  library(tidyverse); library(rvest)
  
  html_df <- 
    read_html(url) %>% 
    html_nodes('p') %>%
    html_text() %>%
    enframe(name = NULL)
  
  df <-
    html_df %>%
    slice(-1:-3) %>%
    mutate(
      # Remove everything before the initial '†'
      value = str_remove(value,"^[^†]*†"),
      # Extract and remove section ID (up to first space)
      section = str_extract(value,"[^\\s]+"),
      value = str_remove(value,"[^\\s]+"),
      # Extract and remove brief section name (up to first period)
      value = str_replace_all(value,"etc.","etc"),
      value = str_replace_all(value,"St\\.","Saint"),
      name = str_extract(value,"[^\\.]+"),
      name = str_replace_all(name,"\r?\n|\r"," "),
      notes = str_sub(value,start = str_locate(value,"\\.")[,1] + 1)
    ) %>%
    select(section,name,notes) %>%
    mutate_all(.funs = list(~str_trim(.))) %>%
    mutate_all(.funs = list(~na_if(.,""))) %>%
    filter(!section %in% c("Note:","DETAILED")) %>% 
    # Remove instances where section ID does not end with dot (notes and such)
    filter(str_detect(section,"\\.$")) %>%
    # Remove final decimal/dot
    mutate(
      chapter_id = str_extract(section,"^[[:alpha:]]"),
      section = str_remove(section,"\\.$"),
      section = str_remove_all(section,"[[:alpha:]]")
    )  %>%
    separate(section, into = c("a","b","c","d","e"),sep = "\\.|-†|\\.--",remove = F) %>%
    filter(!is.na(name)) %>%
    # Remove title levels which are duplicated beneath
    filter(!str_detect(section,".†|.--")) %>%
    filter(section != "") %>%
    # If duplicated, remove row without notes
    group_by(section) %>%
    filter(
      # If there's text in `notes`, keep that
      (sum(!is.na(notes)) > 0 & !is.na(notes))
      | sum(!is.na(notes)) == 0 & !duplicated(section)
    ) %>%
    ungroup() %>%
    mutate_at(vars(a:e),list(~as.numeric(.))) %>%
    mutate(
      name = str_to_title(name),
      # 'Grand divisions' are sections divisible by 100
      level_0 = ifelse(assertive.numbers::is_divisible_by(a,100) & !str_detect(section,"\\."),section,NA),
      # Smaller divisions end with '0', intervals of 10 
      level_1 = ifelse(str_detect(as.character(a),"0$") & is.na(b),section,NA),
      # First 'non-grouped' level, all sections without subdivisions
      level_2 = ifelse(!str_detect(section,"\\."),section,NA),
      level_3 = ifelse(
        (!is.na(a) & is.na(level_0)) & !is.na(b) & (is.na(c) | b == "0") & is.na(d) & is.na(e),section,NA
      ),
      level_4 = case_when(
        !is.na(level_2) ~ NA_character_,
        !is.na(a) & !is.na(b) & !is.na(c) & (is.na(d) | c == "0" | b == "0") & is.na(e) ~ section
      ),
      level_5 = case_when(
        !is.na(level_3) & is.na(e) ~ NA_character_,
        !is.na(a) & !is.na(b) & !is.na(c) & (!is.na(d) | c == "0") & (is.na(e) | d == "0" | c == "0" | b == "0") ~ section
      ),
      level_6 = case_when(
        !is.na(level_4) ~ NA_character_,
        !is.na(a) & !is.na(b) & !is.na(c) & !is.na(d) & (!is.na(e) | d == "0") ~ section
      ),
      level = case_when(
        !is.na(level_0)                                                                     ~ "0",
        !is.na(level_1)                                                                     ~ "1",
        !is.na(level_2) & is.na(level_3) & is.na(level_4) & is.na(level_5) & is.na(level_6) ~ "2",
        is.na(level_1) & is.na(level_2) & !is.na(level_3) & is.na(level_4) & is.na(level_5) & is.na(level_6) ~ "3",
        is.na(level_1) & is.na(level_2) & is.na(level_3) & !is.na(level_4) & is.na(level_5) & is.na(level_6) ~ "4",
        is.na(level_1) & is.na(level_2) & is.na(level_3) & is.na(level_4) & !is.na(level_5) & is.na(level_6) ~ "5",
        is.na(level_1) & is.na(level_2) & is.na(level_3) & is.na(level_4) & is.na(level_5) & !is.na(level_6) ~ "6",
        TRUE ~ NA_character_
      ),
      level = as.numeric(level)
    ) %>%
    # Manage fill of level 0, which originally goes by order of data presented rather than numerically
    arrange(a) %>%
    fill(level_0) %>% group_by(level_0) %>%
    fill(level_1) %>% group_by(level_1) %>% 
    fill(level_2) %>% group_by(level_2) %>%
    fill(level_3) %>% group_by(level_3) %>%
    fill(level_4) %>% group_by(level_4) %>%
    fill(level_5) %>% group_by(level_5) %>%
    fill(level_6) %>% ungroup() %>%
    arrange(a,b,c,d,e) %>%
    mutate(chapter_name = section_name) 
  
  return(df)
  
}

motif_myth <- get_motifs("Myths","https://sites.ualberta.ca/~urban/Projects/English/Content/a.htm")
motif_animal <- get_motifs("Animals","https://sites.ualberta.ca/~urban/Projects/English/Content/b.htm")
motif_tabu <- get_motifs("Tabu","https://sites.ualberta.ca/~urban/Projects/English/Content/c.htm")
motif_magic <- get_motifs("Magic","https://sites.ualberta.ca/~urban/Projects/English/Content/d.htm")
motif_dead <- get_motifs("Death","https://sites.ualberta.ca/~urban/Projects/English/Content/e.htm")
motif_marvels <- get_motifs("Marvels","https://sites.ualberta.ca/~urban/Projects/English/Content/f.htm")
motif_ogres <- get_motifs("Ogres","https://sites.ualberta.ca/~urban/Projects/English/Content/g.htm")
motif_tests <- get_motifs("Tests","https://sites.ualberta.ca/~urban/Projects/English/Content/h.htm")
motif_wisdom <- get_motifs("Wisdom and Folly","https://sites.ualberta.ca/~urban/Projects/English/Content/j.htm")
motif_deceive <- get_motifs("Deceptions","https://sites.ualberta.ca/~urban/Projects/English/Content/k.htm")
motif_fortune <- get_motifs("Reversals of Fortune","https://sites.ualberta.ca/~urban/Projects/English/Content/l.htm")
motif_future <- get_motifs("Ordaining the Future","https://sites.ualberta.ca/~urban/Projects/English/Content/m.htm")
motif_chance <- get_motifs("Chance and Fate","https://sites.ualberta.ca/~urban/Projects/English/Content/n.htm")
motif_society <- get_motifs("Society","https://sites.ualberta.ca/~urban/Projects/English/Content/p.htm")
motif_rewards <- get_motifs("Rewards and Punishments","https://sites.ualberta.ca/~urban/Projects/English/Content/q.htm")
motif_captive <- get_motifs("Captives and Fugitives","https://sites.ualberta.ca/~urban/Projects/English/Content/r.htm")
motif_cruelty <- get_motifs("Cruelty","https://sites.ualberta.ca/~urban/Projects/English/Content/s.htm")
motif_sex <- get_motifs("Sex","https://sites.ualberta.ca/~urban/Projects/English/Content/t.htm")
motif_life <- get_motifs("Nature of Life","https://sites.ualberta.ca/~urban/Projects/English/Content/u.htm")
motif_religion <- get_motifs("Religion","https://sites.ualberta.ca/~urban/Projects/English/Content/v.htm")
motif_traits <- get_motifs("Traits of Character","https://sites.ualberta.ca/~urban/Projects/English/Content/w.htm")
motif_humor <- get_motifs("Humor","https://sites.ualberta.ca/~urban/Projects/English/Content/x.htm")
motif_misc <- get_motifs("Miscellaneous","https://sites.ualberta.ca/~urban/Projects/English/Content/z.htm")

motifs <- 
  bind_rows(
    motif_myth,motif_animal,motif_tabu,motif_magic,motif_dead,motif_marvels,
    motif_ogres,motif_tests,motif_wisdom,motif_deceive,motif_fortune,motif_future,
    motif_chance,motif_society,motif_rewards,motif_captive,motif_cruelty,motif_sex,
    motif_life,motif_religion,motif_traits,motif_humor,motif_misc
  ) %>%
  mutate(id = paste0(chapter_id,section)) %>%
  select(-a:-e) %>%
  ungroup() %>%
  mutate_all(list(~str_trim(.))) %>%
  select(id,chapter_name,name,notes,level,chapter_id,level_0:level_6) %>%
  # Some cleaning
  filter(!str_detect(name,"^--")) %>%
  rename(motif_name = name) %>%
  mutate_at(vars(level_0:level_6),list(~ifelse(is.na(.),NA_character_,paste0(chapter_id,.))))

# Duplicates = 8
# tst <- motifs %>% filter(duplicated(id,fromLast = T) | duplicated(id,fromLast = F))

rm(list = c("motif_myth","motif_animal","motif_tabu","motif_magic","motif_dead","motif_marvels",
            "motif_ogres","motif_tests","motif_wisdom","motif_deceive","motif_fortune","motif_future",
            "motif_chance","motif_society","motif_rewards","motif_captive","motif_cruelty","motif_sex",
            "motif_life","motif_religion","motif_traits","motif_humor","motif_misc"))  
  
# feather::write_feather(motifs,"data/motifs.feather")
write_csv(motifs,"data/motifs.csv")
