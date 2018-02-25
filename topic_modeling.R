## Homework 2 
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  Comparing the Volumes of letters of Mark Twain and Charles Dickens
#  With word frequencies and TF-IDF
#  
#  I thought that these volumes of letters are more interesting than just some romances
#
#  Input: raw text files from Project Gutenberg (6 + 3 files)
#   
#  


library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(reshape2)
library(RColorBrewer)

gutenberg_metadata %>% first(10)

head(gutenberg_subjects)

scifi_list <- gutenberg_subjects %>% 
  filter(str_detect(subject, "Science fiction")) %>%
  filter(str_detect(subject, "English")) %>%
  top_n(10)
  
love_list <- gutenberg_subjects %>% 
  filter(str_detect(subject, "Love stories")) %>%
  filter(str_detect(subject, "English")) %>%
  top_n(10)

scifi_raw <- gutenberg_download(as.vector(scifi_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Scifi ",gutenberg_id))  # more informative
  
  love_raw <- gutenberg_download(as.vector(love_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Scifi ",gutenberg_id)) %>%  # more informative
  





  library(data.table)
a <- data.table(gutenberg_subjects)
a[, .N, by = subject]

c("Science  fiction", "Love stories")


