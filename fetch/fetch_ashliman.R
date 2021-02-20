library(tidyverse); library(httr); library(rvest); library(tidytext); library(fuzzyjoin); library(textclean)

site_url <- "http://www.pitt.edu/~dash/folktexts.html"

pg <-
  read_html(site_url) %>%
  html_nodes("a") 

# Obtain urls for all sub-pages on Folktexts website, filtering for annotated ones

links <- 
  tibble(
    type_name = pg %>% html_text(),
    url = pg %>% html_attr("href")
  ) %>%
  filter(!is.na(url)) %>%
  mutate(
    rev_url = case_when(
      str_detect(url,"^http") ~ url,
      T ~ paste0("http://www.pitt.edu/~dash/",url)
    ),
    short_name = str_remove(url,".html")
  ) %>%
  filter(!str_detect(url,"^http")) %>%
  filter(!str_detect(url,"#[a-z]$")) %>% # Only single letter
  filter(!str_detect(url,"^ashliman.html$|^folktexts.html$|^folktexts2.html$|^folklinks.html$")) %>%
  filter(!str_detect(type_name,regex("essay",ignore_case = T))) %>%
  distinct() %>%
  # Recode html names which do not contain their tale types
  mutate(
    rev_name = recode(
      short_name,
      `alibaba`      = "type0676",
      `animalindian` = "type0402",
      `norway034`    = "type0402",
      `norway133`    = "type0133",
      `type2033`     = "type0020c",
      `friday`       = "type0779j*",
      `frog`         = "type0440",
      `hand`         = "type0958e*",
      `type1066`     = "type1343",
      `hog`          = "type0441",
      `monkey`       = "type0441",
      `melusina`     = "type4080",
      `norway010`    = "type1408",
      `norway120`    = "type0313",
      `midwife`      = "type5070"
    )
  ) %>%
  filter(str_detect(rev_name,regex("^type",ignore_case = T))) %>%
  mutate(
    atu_id = str_remove(rev_name,"^type"),
    atu_id = str_remove(atu_id,"jack$|ast$|#longfellow$")
  ) %>%
  select(type_name,atu_id,url = rev_url)
  
# for each sub-page...

df <- tibble()

# i = 109

range <- 1:length(links$url)

# 78
# errors: c(70,74)

for (i in range[!range %in% c(70,74)]) {

  print(i)
  
  try(
    {
      sub_pg <- 
        read_html(links$url[i]) %>%
        html_nodes("body, h1, li , p, h3, a")
      
      x <-
        tibble(
          text = sub_pg %>% html_text(),
          name = sub_pg %>% html_name(),
          class = sub_pg %>% html_attrs()
        ) 
      
      nobody <-
        x %>% 
        filter(name != "body") %>%
        mutate(
          text = str_squish(text),
          text = str_replace_all(text,'\\\\',""),
          len = str_length(text)
        ) %>%
        filter(text != "")
      
      # Clean the 'body' of the .html, which has paragraphs of unstructured text
      # and associate these, when possible, with structured sections using fuzzy matching
      
      body_df <-
        x %>%
        filter(name == "body") %>%
        select(text) %>%
        unnest_tokens(mess_text, text, token = "lines",to_lower = F) %>%
        mutate(mess = T) %>%
        stringdist_full_join(
          nobody, by = c("mess_text" = "text"), 
          method = "jw", max_dist = 1,
          distance_col = "dist"
        ) %>%
        group_by(mess_text) %>%
        filter(dist == min(dist)) %>%
        # If there is not a good match, make the joined cols NA
        mutate_at(
          vars(text:class),
          list(~ifelse(dist > 0.21,NA,.))
        ) %>%
        distinct(mess_text,text,.keep_all = T) %>%
        ungroup() %>%
        mutate(
          type_name = links$type_name[i],
          atu_id = links$atu_id[i],
          type = case_when(
            name == "a" & str_detect(class,"href") ~ "links",
            name == "p"  ~ "text",
            name == "a"  ~ "title",
            name == "h1" ~ "title",
            str_detect(mess_text,regex("^Return to the table of contents.",ignore_case = T)) ~ "title",
            str_detect(mess_text,regex("^source",ignore_case = T))     ~ "source",
            str_detect(mess_text,regex("copyright|©",ignore_case = T)) ~ "copyright",
            name == "h3" ~ "provenance",
            name == "li" ~ "notes"
          )
        )
      
      # If there is a TOC, locate and remove it
      if (sum(str_detect(body_df$mess_text,regex("table of contents|^contents$",ignore_case = T)), na.rm = T) > 0) {
        body_df <- 
          body_df %>%
          # divide front matter from tales
          mutate(
            div   = case_when(
              str_detect(mess_text,"folktexts, a library of folktales") ~ T,
              # str_detect(mess_text,"Return to D. L. Ashliman's folktexts, a") ~ T, # one off for 'Crop Division...' tales
              sum(str_detect(mess_text,"folktexts, a library of folktales")) == 0 & str_detect(mess_text,"Links to related sites") ~ T,
              T ~ F
            ),
            div_n = cumsum(div)
          ) %>%
          filter(div_n == 1) %>%
          select(-div,-div_n)
      } else body_df <- body_df
      
      body_df <- 
        body_df %>%
        mutate(mess_text = str_replace(mess_text,"^Return to the table of contents.","")) %>%
        filter(!str_detect(mess_text,regex("^D. L. Ashliman$",ignore_case = T))) %>%
        select(-name,-class) %>%
        mutate(tale_title = if_else(type == "title",mess_text,NA_character_)) %>%
        fill(tale_title,.direction = "down") %>%
        filter(type != "title" | is.na(type)) %>%
        # Exclude links to sources
        filter(type != "links" | is.na(type)) %>%
        # remove TOC links
        filter(
          !str_detect(mess_text,regex("table of contents",ignore_case = T)),
          !str_detect(mess_text,regex("D. L. Ashliman's folktexts",ignore_case = T)),
          !str_detect(str_squish(mess_text),regex("^Return to:$",ignore_case = T)),
          !str_detect(mess_text,regex("^Revised ",ignore_case = T)),
          !str_detect(mess_text,regex("^Link to ",ignore_case = T))
        ) %>%
        group_by(tale_title) %>%
        mutate(
          type = case_when(
            lag(type)=="provenance" & is.na(type) ~ "text",
            lag(type)=="copyright" & is.na(type) ~ "notes",
            is.na(type) ~ "text",
            TRUE ~ type
          )
        ) %>%
        fill(type,.direction = "down") %>%
        group_by(type_name,atu_id,tale_title,type) %>%
        summarize(text = paste(mess_text,collapse = " ")) %>%
        mutate_at(vars(tale_title,text),list(~str_squish(.))) %>%
        group_by(type_name,atu_id,tale_title) %>%
        pivot_wider(names_from = "type",values_from = "text") %>%
        select(type_name,atu_id,tale_title,text,everything()) %>%
        filter(!is.na(tale_title)) %>%
        ungroup() %>%
        # Some nested lists remain; paste these together
        mutate_all(list(~paste(.,sep = " ")))
      
      # Add 'provenance' col for join if necessary
      if(is.null(body_df$provenance)){
        body_df <- body_df %>% mutate(provenance = NA_character_)
      } 
      
      clean_df <-
        nobody %>%
        mutate(
          type_name = links$type_name[i],
          atu_id = links$atu_id[i],
          type = case_when(
            name == "a" & str_detect(class,"href") ~ "links",
            name == "a" & str_detect(class,".html$") ~ "links",
            name == "p"  ~ "text",
            name == "a"  ~ "title",
            name == "h1" ~ "title",
            str_detect(text,regex("^source",ignore_case = T))     ~ "source",
            str_detect(text,regex("copyright|©",ignore_case = T)) ~ "copyright",
            name == "h3" ~ "provenance",
            name == "li" ~ "notes"
          )
        ) 
      
      # If there is a TOC, locate and remove it
      if (sum(str_detect(clean_df$text,regex("table of contents|^contents$",ignore_case = T))) > 0) {
        clean_df <- 
          clean_df %>%
          # remove TOC links
          filter(
            !str_detect(text,regex("table of contents",ignore_case = T))
            | is.na(text)
          ) %>%
          slice(-(1:3)) %>% # remove top two rows, which contain dup "folktexts.html"
          # divide front matter from tales
          mutate(
            div   = case_when(
              str_detect(class,"folktexts.html")                          ~ T,
              atu_id %in% c("0850") & str_detect(class,"#bibliography$")  ~ T, # one-off coding due to html mess
              atu_id %in% c("0280a","0676") & str_detect(class,"#links$") ~ T,
              T ~ F
            ),
            div_n = cumsum(div)
          ) %>%
          filter(div_n == 1) %>%
          select(-div,-div_n)
      } else clean_df <- clean_df
      
      clean_df <-
        clean_df %>%
        filter(!str_detect(class,"folktexts.html")) %>%
        # Exclude links to sources
        filter(type != "links") %>%
        mutate(
          tale_title = if_else(type == "title",text,  NA_character_),
          title_tag  = if_else(type == "title",paste(class,sep = " "), NA_character_)
        ) %>%
        select(-name,-class) %>%
        fill(tale_title,title_tag,.direction = "down") %>%
        filter(type != "title") %>%
        group_by(type_name,atu_id,tale_title,title_tag,type) %>%
        summarize(text = paste(text,collapse = " ")) %>%
        mutate(text = str_squish(text)) %>%
        group_by(type_name,atu_id,tale_title,title_tag) %>%
        pivot_wider(names_from = "type",values_from = "text") %>%
        select(type_name,atu_id,tale_title,title_tag,text,everything()) 
      
      # Add 'provenance' col for join if necessary
      if(is.null(clean_df$provenance)){
        clean_df <- clean_df %>% mutate(provenance = NA_character_)
      }
      
      # Then join 'body_df' and 'clean_df'
      
      x <-
        clean_df %>%
        full_join(
          body_df %>% ungroup() %>% select(-type_name, -atu_id), 
          by = c("tale_title","provenance")
        ) 
      
      df <- bind_rows(df,x)
      
    }
  )
  
}

aft <-
  df  %>%
  # Privilege columns based on source (.y = messy body text, .x = structured html)
  mutate(
    text = case_when(
      !is.na(text.x) & !is.na(text.y) & (str_length(text.y) > str_length(text.x)) ~ text.y,
      !is.na(text.x) & !is.na(text.y) & (str_length(text.y) < str_length(text.x)) ~ text.x,
      is.na(text.x) & !is.na(text.y) ~ text.y,
      TRUE ~ text.x
    ),
    # provenance = if_else(!is.na(provenance.x),provenance.x,provenance.y),
    source = if_else(!is.na(source.x),source.x,source.y),
    notes = if_else(!is.na(notes.x),notes.x,notes.y),
    copyright = if_else(!is.na(copyright.x),copyright.x,copyright.y)
  ) %>%
  select_at(vars(!matches(".x$|.y$"))) %>%
  filter(text != "") %>%
  filter(!is.na(tale_title)) %>%
  filter(
    !str_detect(
      tale_title,
      regex(
        "contents|^links to |^links$|related links|^footnote$|^\\{footnote|notes and bibliography",
        ignore_case = T
      )
    )
  ) %>%
  filter(!str_detect(text,"^Return to D. L. Ashliman's folktexts|^Return to:$")) %>%
  mutate(
    type_name = str_replace_all(type_name,"\\n"," "),
    type_name = str_remove(type_name,"^Type.*: "),
    tale_title = str_squish(tale_title),
    atu_id = recode(atu_id, `2033` = "0020c"),
    source = str_remove(source,"^Source:|^Source: ")
  ) %>%
  mutate_all(list(~if_else(str_detect(.,"^NA$|^NULL$"),NA_character_,.))) %>%
  filter(!is.na(type_name)) %>%
  filter(!(str_detect(text,"^Revised ") & str_length(text) < 30)) %>%
  # If a title is duplicated, append parenthetical tag
  group_by(atu_id) %>%
  mutate(
    dup_title = duplicated(tale_title,fromLast = T) | duplicated(tale_title,fromLast = F),
    tale_title = if_else(
      dup_title, 
      paste0(tale_title," (",str_to_title(title_tag),")"),
      tale_title
    )
  ) %>%
  select(-dup_title,-title_tag) %>%
  mutate(
    text = text %>% 
      str_remove_all(fixed("\\")) %>%
      str_replace_all('[\"]', "'") %>%
      str_squish() %>%
      replace_html(replacement = ""),
    data_source = "Ashliman's Folktexts",
    date_obtained = lubridate::today()
  ) %>%
  distinct(.keep_all = T)

write_csv(aft,"data/aft.csv")

complete <-
  aft %>%
  group_by(atu_id) %>%
  summarise(
    pages = paste(unique(type_name),collapse = "; "),
    n_tales = n_distinct(tale_title),
    tales = paste(tale_title,collapse = "; ")
  ) %>%
  full_join(
    links %>% group_by(atu_id) %>%
      summarise(
        urls = paste(url,collapse = "; ")
      ), 
    by = c("atu_id")
  ) %>%
  arrange(desc(n_tales))

rm(list = c("pg","x","i","site_url","sub_pg","nobody","body_df","clean_df","range"))
