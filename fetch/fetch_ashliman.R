library(tidyverse); library(httr); library(rvest); library(tidytext); library(fuzzyjoin)

site_url <- "http://www.pitt.edu/~dash/folktexts.html"

pg <-
  read_html(site_url) %>%
  html_nodes("a") 

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
  # Only single letter
  filter(!str_detect(url,"#[a-z]$")) %>%
  filter(!str_detect(url,"^ashliman.html$|^folktexts.html$|^folktexts2.html$|^folklinks.html$")) %>%
  filter(!str_detect(type_name,regex("essay",ignore_case = T))) %>%
  distinct() %>%
  # Recode html names which do not contain their tale types
  mutate(
    rev_name = recode(
      short_name,
      `alibaba`      = "type0676",
      `animalindian` = "type0402",
      `norway133`    = "type0133",
      `type2033`     = "type0020c",
      `friday`       = "type0779j*",
      `frog`         = "type0440",
      `hand`         = "type0958e*",
      `type1066`     = "type1343",
      `hog`          = "type0441",
      `norway010`    = "type1408",
      `norway120`    = "type0313",
      `midwife`      = "type5070"
    )
  ) %>%
  filter(str_detect(short_name,regex("^type",ignore_case = T))) %>%
  filter(!str_detect(short_name,"0207c#longfellow")) %>%
  mutate(
    atu_id = str_remove(short_name,"^type"),
    atu_id = str_remove(atu_id,"jack$|ast$")
  ) %>%
  select(type_name,atu_id,url = rev_url)
  

# for each sub-page...

df <- tibble()

# i = 70
range <- 1:length(links$url)

# errors: c(7,20)

for (i in range[!range %in% c(70)]) {
  
  print(i)
  
  try(
    {
      sub_pg <- 
        read_html(links$url[i]) %>%
        html_nodes("body, li , p, h3, a")
      
      x <-
        tibble(
          text = sub_pg %>% html_text(),
          name = sub_pg %>% html_name(),
          class = sub_pg %>% html_attrs()
        ) 
      
      # Split into a table for the unstructured 'body' text...
      
      body <-
        x %>%
        filter(name == "body") %>%
        select(-class) %>%
        mutate(
          text = str_squish(text),
          text = str_replace_all(text,'\\\\',"")
        )
      
      # and another for the structured .html tags
      
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
        # divide front matter from tales
        mutate(
          div   = str_detect(mess_text,"Return to D. L. Ashliman's folktexts"),
          div_n = cumsum(div)
        ) %>%
        filter(div_n == 1) %>%
        mutate(
          type_name = links$type_name[i],
          atu_id = links$atu_id[i],
          type = case_when(
            name == "a" & str_detect(class,"href") ~ "links",
            name == "p"  ~ "text",
            name == "a"  ~ "title",
            str_detect(mess_text,regex("^Return to the table of contents.",ignore_case = T)) ~ "title",
            str_detect(mess_text,regex("^source",ignore_case = T))     ~ "source",
            str_detect(mess_text,regex("copyright|©",ignore_case = T)) ~ "copyright",
            name == "h3" ~ "provenance",
            name == "li" ~ "notes"
          )
        ) %>%
        mutate(mess_text = str_replace(mess_text,"^Return to the table of contents.","")) %>%
        select(-div,-div_n,-name,-class) %>%
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
        filter(!is.na(tale_title))
      
      clean_df <-
        nobody %>%
        mutate(
          type_name = links$type_name[i],
          atu_id = links$atu_id[i],
          type = case_when(
            name == "a" & str_detect(class,"href") ~ "links",
            name == "p"  ~ "text",
            name == "a"  ~ "title",
            str_detect(text,regex("^source",ignore_case = T))     ~ "source",
            str_detect(text,regex("copyright|©",ignore_case = T)) ~ "copyright",
            name == "h3" ~ "provenance",
            name == "li" ~ "notes"
          )
        ) %>%
        # remove TOC links
        filter(
          !str_detect(text,regex("table of contents",ignore_case = T))
          | is.na(text)
        ) %>%
        # divide front matter from tales
        mutate(
          div   = str_detect(class,"folktexts.html"),
          div_n = cumsum(div)
        ) %>%
        filter(div_n == 1) %>%
        filter(!str_detect(class,"folktexts.html")) %>%
        # Exclude links to sources
        filter(type != "links") %>%
        select(-div,-div_n,-name,-class) %>%
        mutate(tale_title = if_else(type == "title",text,NA_character_)) %>%
        fill(tale_title,.direction = "down") %>%
        filter(type != "title") %>%
        group_by(type_name,atu_id,tale_title,type) %>%
        summarize(text = paste(text,collapse = " ")) %>%
        mutate(text = str_squish(text)) %>%
        group_by(type_name,atu_id,tale_title) %>%
        pivot_wider(names_from = "type",values_from = "text") %>%
        select(type_name,atu_id,tale_title,text,everything())
      
      # Then join 'body_df' and 'clean_df'
      
      x <-
        clean_df %>%
        full_join(
          body_df %>% ungroup() %>% select(-type_name, -atu_id), 
          by = "tale_title"
        )
      
      df <- bind_rows(df,x)
    }
  )
  
}

aat <-
  df  %>%
  # Privilege columns based on source (.y = messy body text, .x = structured html)
  mutate(
    text = if_else(!is.na(text.y),text.y,text.x),
    provenance = if_else(!is.na(provenance.x),provenance.x,provenance.y),
    source = if_else(!is.na(source.x),source.x,source.y),
    notes = if_else(!is.na(notes.x),notes.x,notes.y),
    copyright = if_else(!is.na(copyright.x),copyright.x,copyright.y)
  ) %>%
  select_at(vars(!matches(".x$|.y$"))) %>%
  filter(text != "") %>%
  filter(!is.na(tale_title)) %>%
  filter(!str_detect(text,"^Return to D. L. Ashliman's folktexts|^Return to:$")) %>%
  mutate(tale_title = str_squish(tale_title))

write_csv(aat,"data/aat.csv")

rm(list = c("df","pg","x","i","site_url","links"))
