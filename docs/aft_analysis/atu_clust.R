
library(tidyverse)
aft <- read_csv("data/aft.csv")
tmi <- read_csv("data/tmi.csv")
atu <- read_csv("data/atu.csv")
atu_seq <- read_csv("data/atu_seq.csv")


m <- 
  atu_seq %>%
  # right_join(aft %>% distinct(atu_id), by = "atu_id") %>%
  mutate(atu_variant = paste0(atu_id,"_",tale_variant)) %>%
  select(atu_variant, motif) %>%
  # get rid of multiple motif occurrences per tale_variant
  distinct(.keep_all = F) %>% 
  mutate(value = 1) %>%
  pivot_wider(names_from = "motif", values_fill = 0) %>%
  column_to_rownames("atu_variant")  %>%
  slice_sample(n = 714) %>%
  as.matrix()


library(heatmaply)
heatmaply(normalize(m))


tst <- percentize(m)
gplots::heatmap.2(m)


library(logisticPCA)

logpca_cv = cv.lpca(m, ks = 2, ms = 1:10)
p0lot(logpca_cv)
.
library(tidymodels); library(embed)

split <- seq.int(1, 150, by = 9)
tr <- iris[-split, ]
te <- iris[split, ]

supervised <-
  recipe(atu_variant ~ ., data = m) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  step_umap(all_predictors(), outcome = vars(atu_variant), num_comp = 2) %>%
  prep(training = m)
