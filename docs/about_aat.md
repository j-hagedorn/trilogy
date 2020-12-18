First, we get a list of the links on the main page and their titles:

``` r
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
  distinct(.keep_all = T)
```

Some of the names are conveniently located in the URL, while some need
to be manually added:

``` r
recode_links <-
  links %>%
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
  mutate(
    atu_id = str_remove(short_name,"^type"),
    atu_id = str_remove(atu_id,"jack$|ast$")
  ) %>%
  select(type_name,atu_id,url = rev_url)

write_csv(recode_links,"ashliman_links.csv")
```

The following still need a type identified:

  - Girl Without Hands
  - Nasreddin Hodja: Tales of the Turkish Trickster

The following pages can be linked to multiple tale types, and we will
need to determine how to manage these. Are they combinations of the
types, etc.? These are retained with a single type, if that type was
explicitly noted in the URL

  - Bald Stories: Folktales about Hairless Men
  - Bluebeard (types 312 and 312A)
  - The Boy Who Had Never Seen a Woman (types 1678 and 1459)
  - Bride Tests
  - Cat and Mouse
  - Death of an Underground Person, or of the King of the Cats (types
    6070B and 113A)
  - Forgiveness and Redemption (755 and 756)
  - The Two Frogs (278A and 278A\*)
  - Midwife (or Godparent) for the Elves (type 5070 OR 476\*)