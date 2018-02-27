## a long-long story....
library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(reshape2)
library(RColorBrewer)

authors <- gutenberg_authors %>% 
  filter(deathdate > 1850)

meta  <- gutenberg_metadata %>% 
  filter(language == "en",
         has_text == TRUE) %>% 
  group_by(has_text) %>% 
  summarise(N = n())

meta            

meta2 <- meta %>% inner_join(authors)


meta2 %>% 
  filter(language == "en",
         has_text == TRUE,
         !is.na(wikipedia),
         !str_detect(gutenberg_bookshelf, "hildren"),
         !str_detect(gutenberg_bookshelf, "Australia"),
         !str_detect(gutenberg_bookshelf, "United Kingdom"),
         !str_detect(gutenberg_bookshelf, "Animals"),
         str_detect(gutenberg_bookshelf, "iction")
         
         
  ) -> meta3

meta3 %>% 
  group_by(wikipedia) %>% 
  summarise(N = n()) %>% 
  arrange(desc(N))  -> kukucs
