library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)

twain_list <- gutenberg_works() %>% 
  filter(str_detect(author, "Twain, Mark"),
         str_detect(title, "Letters"),
         !str_detect(title, "Complete"))
  

dickens_list <- gutenberg_works() %>% 
  filter(str_detect( author, "Dickens, Charles"), 
         str_detect(title, "Letters"))

twain_raw <- gutenberg_download(as.vector(twain_list$gutenberg_id)) %>% 
  group_by(gutenberg_id) %>% 
  mutate(linenumber = row_number(),
         letternumber = cumsum(str_detect(text, regex("^To.*:$"))))


dickens_raw <- gutenberg_download(as.vector(dickens_list$gutenberg_id)) %>% 
  group_by(gutenberg_id) %>% 
  mutate(linenumber = row_number(),
         letternumber = cumsum(str_detect(text, regex("^\\[Sidenote"))))

twain_tidy <- twain_raw %>% unnest_tokens(twain_raw)
