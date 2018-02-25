## Homework 3
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  Topics analysis on some books about Politics, History and Love
#  
#  Ideally the topics algorithm identify these 3 categories - or gives
#  some other insight
#
#  Input: raw text files from Project Gutenberg (6 + 3 files)
#   
#  


library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(topicmodels)

library(reshape2)
library(RColorBrewer)


rm(list=ls())

## Creating lists of Gutenberg_id-s by categories

history_list <- gutenberg_subjects %>% 
  filter(str_detect(subject, "History")) %>%
  filter(str_detect(subject, "English")) %>%
  top_n(n = 10, -gutenberg_id)

politics_list <- gutenberg_subjects %>%
  filter(str_detect(subject, "Politics")) %>%
  filter(gutenberg_id != 20046) %>%
  top_n(n = 10, gutenberg_id)

love_list <- gutenberg_subjects %>% 
  filter(str_detect(subject, "Romance")) %>%
  filter(str_detect(subject, "English")) %>%
#  filter(gutenberg_id != 31100) %>%  # was too long
  top_n(n = 10, -gutenberg_id)




## Downloading the raw books, adding the categories to the id.

history_raw <- gutenberg_download(as.vector(history_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("History ",gutenberg_id))  
  # more informative

politics_raw <- gutenberg_download(as.vector(politics_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Politics ",gutenberg_id))  # more informative

love_raw <- gutenberg_download(as.vector(love_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Love ",gutenberg_id))  # more informative



## Combining the 3 raw sets, and tidying

raw <- rbind(history_raw, politics_raw, love_raw)
##raw %>% group_by(gutenberg_id) %>% summarise(N = n()) %>% ungroup() %>% ggplot(aes(factor(gutenberg_id), N)) + geom_bar() + coord_flip()
to_remove <- c("thou", "de", "thy", "thee")  # custom stopwords

tidy <- raw %>% unnest_tokens(word, text)  %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  filter(!word %in% to_remove) %>%  # filtering only the new stopwords
  filter(!is.na(word)) %>% 
  anti_join(stop_words)


word_freq_by_book <- tidy %>% 
  count(gutenberg_id, word) %>%
  group_by(gutenberg_id) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  ungroup()

wc <- tidy %>% 
  count(gutenberg_id, word, sort = TRUE) %>% 
  ungroup() %>% 
  cast_dtm(gutenberg_id, word, n)



## LDA with 3 topics

LDA_result <- LDA(wc, k = 3, control = list (seed = 20180225))

LDA_result

topics <- tidy(LDA_result, matrix = "beta")

top_terms <- topics %>% 
  group_by(topic) %>% 
  top_n(10, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms

top_terms %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip()

tidy(LDA_result, matrix = "gamma") %>% 
  separate(document, c("Type", "ID"), sep = " ", convert = TRUE) %>% 
  mutate(Type = reorder(Type, gamma * topic)) %>% 
  ggplot(aes(factor(topic), gamma)) + 
  geom_boxplot() +
  facet_wrap(~ Type)




