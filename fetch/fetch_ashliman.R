library(tidyverse); library(httr); library(rvest); library(tidytext)

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

# i = 2

for (i in 1:length(links$url)) {
  
  print(i)
  
  try(
    {
      sub_pg <- 
        read_html(links$url[i]) %>%
        # html_nodes("li , p, h3, a")
        html_nodes("body, li , p, h3, a")
      
      x <-
        tibble(
          text = sub_pg %>% html_text(),
          name = sub_pg %>% html_name(),
          class = sub_pg %>% html_attrs()
        ) 
      
      body <-
        x %>%
        filter(name == "body") %>%
        select(-class) %>%
        mutate(
          text = str_squish(text),
          text = str_replace_all(text,'\\\\',"")
        )
      
      nobody <- 
        x %>% 
        filter(name != "body") %>%
        mutate(
          text = str_squish(text),
          text = str_replace_all(text,'\\\\',""),
          len = str_length(text)
        ) %>%
        filter(text != "") %>%
        arrange(desc(len))
      
      for (n in 1:nrow(nobody)) {
        print(paste0(n,": ",nobody$text[n]))
        try(
          {
            body <- 
              body %>% 
              mutate(
                text = str_replace_all(
                  text,regex(nobody$text[n],ignore_case = T),"@"
                )
              )
          }
        )
        
      }
      
      
      %>%
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
        filter(!str_detect(text,regex("table of contents",ignore_case = T))) %>%
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
      
      df <- bind_rows(df,x)
    }
  )
  
}

aat <-
  df %>%
  filter(text != "") %>%
  filter(!is.na(tale_title)) %>%
  filter(!str_detect(text,"^Return to D. L. Ashliman's folktexts|^Return to:$")) %>%
  mutate(tale_title = str_squish(tale_title))

write_csv(aat,"data/aat.csv")

rm(list = c("df","pg","x","i","site_url","links"))
