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
#  Input: raw text files from Project Gutenberg
#   
#  

library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(topicmodels)

rm(list=ls())

## Creating lists of Gutenberg_id-s by categories

subjects <- gutenberg_subjects %>%   # this prefilter is needed to avoid french books
  inner_join(gutenberg_metadata) %>% 
  filter(language == "en", has_text == T) 

history_list <- subjects %>% 
  filter(str_detect(subject, "History")) %>%
  top_n(n = 30, gutenberg_id)

politics_list <- subjects %>%
  filter(str_detect(subject, "Politics")) %>%
  top_n(n = 30, gutenberg_id)

love_list <- subjects %>% 
  filter(str_detect(subject, "Romance")) %>%
  top_n(n = 30, gutenberg_id)




## Downloading the raw books, adding the categories to the id.

history_raw <- gutenberg_download(as.vector(history_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("History ",gutenberg_id))  # more informative

politics_raw <- gutenberg_download(as.vector(politics_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Politics ",gutenberg_id))  # more informative

love_raw <- gutenberg_download(as.vector(love_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Love ",gutenberg_id))  # more informative



## Combining the 3 raw sets, and tidying

raw <- rbind(history_raw, politics_raw, love_raw)

to_remove <- c("thou", "de", "thy", "thee")  # custom stopwords

tidy <- raw %>% unnest_tokens(word, text)  %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  filter(!word %in% to_remove) %>%  # filtering only the new stopwords
  filter(!is.na(word)) %>% 
  anti_join(stop_words)


## basic word frequencies plot

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

topics <- tidy(LDA_result, matrix = "beta")

top_terms <- topics %>% 
  group_by(topic) %>% 
  top_n(8, beta) %>% 
  ungroup() %>% 
  arrange(topic, -beta)

top_terms

## graphs 

top_terms %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  ggtitle("The strongest words of the topics") 

## I was thinking about removing 'ii' and 'iii' with stopwords, but these words can represent difference between
## historical text and romance

tidy(LDA_result, matrix = "gamma") %>% 
  separate(document, c("Type", "ID"), sep = " ", convert = TRUE) %>% 
  mutate(Type = reorder(Type, gamma * topic)) %>% 
  ggplot(aes(factor(topic), gamma)) + 
  geom_boxplot() +
  facet_wrap(~ Type) + 
  labs(title = "Original subjects VS LDA Topics", 
       x = "Topic",
       caption = "What can I say?  \n History is a mix of love and politics...")

## What can I say? History is a mix of love and politics...


