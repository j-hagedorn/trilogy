library(tidyverse); library(readxl); library(gutenbergr); library(fuzzyjoin); library(stringdist)

marked <- 
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
  gutenberg_works(gutenberg_id %in% marked$id) %>%
  distinct(gutenberg_id,.keep_all = T) %>%
  mutate(
    link = paste0(
      "https://www.gutenberg.org/cache/epub/",
      gutenberg_id,"/pg",gutenberg_id,".txt"
    )
  )

rm(marked)

# Read in texts

# Make a lookup table with the variables to read in each text consistently

lookup <-
  tribble(
    ~gutenberg_id, ~start_toc, ~stop_toc, ~start_text, ~stop_text, ~ignore_case, ~clean,
    ############# | ######### | ######## | ########## | ######### | ########### | ######
    "4928",        318,        453,       912,         33608,       T,         F,
    "7128",        190,        247,       288,         6521,        T,         F,
    "18450",       126,        208,       650,         6943,        T,         F,
    "19713",       159,        200,       206,         6130,        F,         F,
    "27499",       77,         135,       263,         4987,        T,         F,
    "28099",       150,        202,       320,         3204,        T,         F,
    "29939",       108,        275,       316,         10642,       T,         F,
    "35564",       87,         160,       189,         2875,        T,         F,
    "36923",       102,        145,       459,         4048,        T,         F,
    "37002",       72,         104,       200,         7227,        T,         F,
    "37884",       56,         87,        122,         4299,        T,         F,
    "38112",       175,        243,       335,         7174,        T,         F,
    "42981",       2595,       2750,      2763,        12382,       T,         F,
    "45723",       96,         126,       467,         12022,       T,         F,
    "47146",       137,        266,       415,         3433,        T,         F,
    "51002",       76,         128,       172,         5525,        F,         F,
    "52596",       71,         94,        181,         4051,        F,         F,
    "56614",       39,         133,       1751,        14809,       T,         F,
    "57399",       32,         154,       173,         17481,       T,         F,
    "58889",       32,         161,       197,         15446,       T,         F,
    "58900",       173,        251,       290,         10265,       T,         F,
    "62514",       73,         107,       173,         1718,        F,         F,
    "66509",       42,         153,        238,        3075,        F,         F,
    "66870",       34,         82,        1824,        13365,       T,         F,
    "66923",       32,         80,        422,         3193,        F,         F,
    "67085",       67,         141,       192,         7630,        T,         F,
    "4018",        14,         35,        98,          7548,        F,         T,
    "2198",        23,         54,        61,          7188,        T,         T,
    "36241",       138,        188,       281,         4717,        F,         T,
    "338",         17,         30,        41,          2141,        F,         T,
    "341",         20,         59,        153,         4588,        T,         T,
    "503",         12,         48,        53,          13530,       F,         T,
    "2503",        143,        213,       218,         3811,        F,         T,
    "5245",        37,         98,        109,         20527,       T,         T,
    "6145",        19,         61,        248,         8457,        T,         T,
    "6606",        20,         64,        375,         2557,        T,         T,
    "6607",        18,         32,        42,          831,         T,         T,
    "6611",        18,         58,        68,          2181,        T,         T,
    "7518",        74,         114,       122,         1709,        F,         T,
    "7871",        22,         62,        68,          4922,        F,         T,
    "7885",        172,        197,       205,         6815,        F,         T,
    "8299",        149,        346,       665,         21518,       T,         T,
    "8599",        33,         47,        54,          9023,        T,         T,
    "9313",        53,         111,       117,         3123,        F,         T,
    "9368",        41,         87,        95,          5171,        F,         T,
    "11028",       33,         145,       164,         6482,        F,         T,
    "11167",       96,         115,       139,         2312,        F,         T,
    "11547",       34,         102,       392,         5360,        F,         T,
    "11938",       119,        328,       359,         15423,       F,         T,
    "12814",       154,        248,       322,         5286,        F,         T,
    "13015",       88,         123,       186,         10198,       F,         T,
    "13833",       58,         83,        90,          3843,        F,         T,
    "14241",       191,        277,       315,         5880,        T,         T,
    "15186",       36,         94,        100,         4986,        T,         T,
    "17071",       12,         44,        69,          4162,        T,         T,
    "18674",       49,         77,        117,         5195,        T,         T,
    "19994",       34,         179,       191,         4558,        T,         T,
    "22072",       71,         133,       138,         5106,        T,         T,
    "22096",       66,         133,       733,         3574,        F,         T,
    "22420",       63,         185,       197,         4212,        T,         T,
    "22693",       214,        280,       331,         9732,        F,         T,
    "24473",       89,         92,        148,         989,         F,         T,
    "24569",       85,         150,       175,         3252,        F,         T,
    "24714",       81,         115,       122,         2453,        T,         T,
    "24811",       73,         93,        241,         3873,        F,         T,
    "24948",       144,        221,       373,         4696,        T,         T,
    "24978",       65,         101,       111,         4123,        F,         T,
    "25555",       55,         94,        202,         7507,        F,         T,
    "26070",       38,         48,        55,          5158,        F,         T,
    "28932",       259,        311,       360,         5909,        T,         T,
    "29672",       53,         82,        196,         5552,        T,         T,
    "30577",       79,         107,       112,         3100,        T,         T,
    "30635",       83,         167,       360,         5308,        T,         T,
    "31481",       73,         113,       123,         3896,        F,         T,
    "32375",       74,         90,        117,         2776,        F,         T,
    "32786",       231,        278,       283,         10493,       T,         T,
    "34431",       133,        166,       249,         5144,        T,         T,
    "34453",       158,        196,       232,         6441,        T,         T,
    "34655",       53,         149,       466,         4406,        F,         T,
    "35060",       107,        129,       138,         4229,        T,         T,
    "35557",       90,         103,       420,         3158,        T,         T,
    "36039",       51,         78,        86,          2722,        T,         T,
    "36241",       138,        188,       281,         4717,        F,         T,
    "36385",       170,        266,       363,         10893,       T,         T,
    "36540",       13,         56,        68,          7888,        T,         T,
    "36668",       57,         69,        76,          2691,        T,         T,
    "37472",       107,        116,       163,         3187,        T,         T,
    "37532",       143,        201,       206,         7497,        T,         T,
    "38339",       46,         135,       301,         2838,        F,         T,
    "38488",       133,        154,       231,         6559,        T,         T,
    "44536",       141,        187,       201,         5475,        T,         T,
    "45321",       44,         94,        693,         7909,        F,         T,
    "45634",       54,         154,       11419,       17076,       T,         T,
    "46047",       95,         259,       273,         4619,        T,         T,
    "46944",       460,        488,       496,         7289,        T,         T,
    "46960",       73,         96,        247,         4807,        F,         T,
    "51762",       78,         118,       129,         3757,        T,         T,
    "58816",       101,        157,       166,         5349,        F,         T,
    "60165",       57,         66,        2224,        8667,        T,         T,
    "66443",       81,         89,        124,         3167,        T,         T,
    "128",         22,         55,        289,         11417,       F,         F,
    "1597",        10,         27,        32,          5810,        T,         T,
    "5160",        12,         23,        294,         9503,        T,         F,
    "5314",        13,         224,       228,         25109,       F,         F,
    "30973",       77,         91,        183,         4504,        F,         T,
    "677",         NA,         NA,        NA,          NA,          NA,        NA,
    "13725",       NA,         NA,        NA,          NA,          NA,        NA,
    "14726",       NA,         NA,        NA,          NA,          NA,        NA,
    "20552",       NA,         NA,        NA,          NA,          NA,        NA,
    "20916",       NA,         NA,        NA,          NA,          NA,        NA,
    "24737",       NA,         NA,        NA,          NA,          NA,        NA,
    "27467",       NA,         NA,        NA,          NA,          NA,        NA,
    "28497",       NA,         NA,        NA,          NA,          NA,        NA,
    "29551",       NA,         NA,        NA,          NA,          NA,        NA,
    "30109",       NA,         NA,        NA,          NA,          NA,        NA,
    "32572",       NA,         NA,        NA,          NA,          NA,        NA,
    "34206",       NA,         NA,        NA,          NA,          NA,        NA,
    "37488",       NA,         NA,        NA,          NA,          NA,        NA,
    "37668",       NA,         NA,        NA,          NA,          NA,        NA,
    "39195",       NA,         NA,        NA,          NA,          NA,        NA,
    "39250",       NA,         NA,        NA,          NA,          NA,        NA,
    "44746",       NA,         NA,        NA,          NA,          NA,        NA,
    "44935",       NA,         NA,        NA,          NA,          NA,        NA,
    "45214",       NA,         NA,        NA,          NA,          NA,        NA,
    "46863",       NA,         NA,        NA,          NA,          NA,        NA,
    "48771",       NA,         NA,        NA,          NA,          NA,        NA,
    "48908",       NA,         NA,        NA,          NA,          NA,        NA,
    "57265",       NA,         NA,        NA,          NA,          NA,        NA,
    "57826",       NA,         NA,        NA,          NA,          NA,        NA,
  )

ref <- 
  ref %>%
  mutate(gutenberg_id = as.character(gutenberg_id)) %>%
  left_join(lookup, by = "gutenberg_id") %>%
  # Remove works not containing tales
  filter(
    !gutenberg_id %in% c(
      "12545", "15250", "29287", "29773", "34704", "36127", "38064", "38688", 
      "41148", "42390", "44430", "44638", "45279", "46501", "51275", "53080",
      "55025", "56597", "67426", "68225", "9914", "24421","40588"
    )
  )

i <- 106

combo_df <- tibble()
combo_toc <- tibble()

for (i in 1:nrow(lookup %>% filter(clean))) {
  
  df <- 
    gutenberg_download(lookup$gutenberg_id[i]) %>%
    mutate(text = str_squish(text))
  
  toc <- 
    df %>% 
    slice(lookup$start_toc[i]:lookup$stop_toc[i]) %>% 
    mutate(
      # Remove leading numbers
      text = str_remove(text,"^[0-9]+\\."),
      # Remove Roman numerals
      text = str_remove(text,"^M{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\\."),
      # Remove trailing (page) numbers
      text = str_remove(text,"[0-9]+$"),
      text = str_squish(text)
    ) %>%
    filter(!is.na(text)) %>%
    filter(text != "")
  
  y <- 
    df %>%
    mutate(line = row_number()) %>%
    stringdist_left_join(
      toc %>% select(text),
      by = "text", method = "jw", 
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
    mutate(
      str_diff = stringdist(str_to_upper(text),str_to_upper(tale), method = "jw")
    ) %>%
    filter(str_diff > 0.16) %>%
    group_by(gutenberg_id,tale) %>%
    summarize(text = paste(text,collapse = " ")) %>%
    ungroup()
  
  combo_df <- combo_df %>% bind_rows(y)
  combo_toc <- combo_toc %>% bind_rows(toc)
  
}

write_rds(combo_df,"data/aft_v2.rds")


  
