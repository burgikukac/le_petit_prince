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

## creating the list of volumes to download

twain_list <- gutenberg_works() %>% 
  filter(str_detect(author, "Twain, Mark"),
         str_detect(title, "Letters"),
         !str_detect(title, "Complete"))  #  this would contain the previous ones
  
dickens_list <- gutenberg_works() %>% 
  filter(str_detect( author, "Dickens, Charles"), 
         str_detect(title, "Letters"))

## downloading the volumes, creating line- and letternumbers with regexp

twain_raw <- gutenberg_download(as.vector(twain_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Twain ",gutenberg_id)) %>%  # more informative
  group_by(gutenberg_id) %>% 
  mutate(author = "Twain",
         linenumber = row_number(),  #creating rownumbers in volumes
         letternumber = cumsum(str_detect(text, regex("^To.*:$")))) %>%  # identifying the first row of a letter
  filter(letternumber > 0) %>%  # before the first letter is not important for us (like preface)
  ungroup()

dickens_raw <- gutenberg_download(as.vector(dickens_list$gutenberg_id)) %>% 
  mutate(gutenberg_id = paste0("Dickens ",gutenberg_id)) %>% 
  group_by(gutenberg_id) %>% 
  mutate(author = "Dickens",
         linenumber = row_number(),
         letternumber = cumsum(str_detect(text, regex("^\\[Sidenote")))) %>% # identifying the first row of a letter
  filter(letternumber > 0) %>% 
  ungroup()

## creating a tidy text tibble, keeping just the alphabetical information (and: '), removing stop words

together_tidy <- rbind(twain_raw, dickens_raw) %>% 
  unnest_tokens(word, text) %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  filter(!is.na(word)) %>% 
  anti_join(stop_words)

## creating word frequencies / proportions by author and by volume (book)

word_freq_by_author <- together_tidy %>% 
  count(author, word) %>%
  group_by(author) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  ungroup() %>% 
  spread(author, proportion)

word_freq_by_book <- together_tidy %>% 
  count(gutenberg_id, word) %>%
  group_by(gutenberg_id) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  ungroup() %>% 
  spread(gutenberg_id, proportion)

## how much correlate the two authors and the volumes?

print("Correlation between ALL the letters of Dickens / Twain")
cor.test(word_freq_by_author$Dickens, word_freq_by_author$Twain)

# cor(word_freq_by_book[,-1], use = "pairwise")  # uncomment this line to see the corr. mtx

data <- word_freq_by_book[,-1]
qplot(x = as.factor(Var1), 
      y = as.factor(Var2), 
      data = melt(cor(data, use = "p")), 
      fill = value, geom="tile",
      main = "Correlation Plot between Dickens/Twain letter volumes",
      xlab = "Gutenberg id", 
      ylab = "Gutenberg id") +
  scale_fill_distiller(palette = "BrBG", limits = c(0,1))  # limit is intentionally from 0

#  correlation plots usually don't give much information, in our case the stronger correlation
#  between two volumes of the same author is clear. 3193 and 25853 seem to be different
#  3193: most probably because of the introduction


## TF-IDF, by books

(book_words <- together_tidy %>% 
  rename(book = gutenberg_id) %>% 
  count(book, word, sort = TRUE) %>% 
  ungroup() %>% 
  bind_tf_idf(word, book, n) %>% 
  arrange(desc(tf_idf)) %>% 
  top_n(15)
)

## the most powerful words: vo (volume), sidenote (addressing that Dickens used)
## clemens (twain's original name), dickens, twain
## TODO : remove these using custom stopwords

to_remove <- c("vo", "sidenote", "vols", "ii", "dickens", "twain", "clemens")

## TF-IDF, by books  WITH new stopwords

(book_words2 <- together_tidy %>% 
    filter(!word %in% to_remove) %>%  # filtering only the new stopwords
    rename(book = gutenberg_id) %>% 
    count(book, word, sort = TRUE) %>% 
    ungroup() %>% 
    bind_tf_idf(word, book, n) %>% 
    group_by(book) %>% 
    arrange(desc(tf_idf)) %>% 
    top_n(5) %>% 
    ungroup()
)

book_words2  %>%
  ggplot(aes(word, tf_idf, fill =tf_idf)) + 
  geom_col(show.legend = FALSE) +
  facet_wrap(~book, scales = "free_y") + 
  labs(y = "TF-IDF", x = NULL) + 
  coord_flip() + 
  ggtitle("Top 5 words with the highest TF-IDF by volumes \n (after removing custom stopwords)")



