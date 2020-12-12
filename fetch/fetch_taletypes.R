
df <-
  read_lines("fetch/ATU.Master.Hels.txt") %>%
  as_tibble() %>%
  # Remove front matter and index
  slice(173:16129) %>%
  mutate(
    id = str_extract(value,"([0-9]+).*$")
  )
