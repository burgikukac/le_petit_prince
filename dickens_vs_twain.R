library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(reshape2)
library(RColorBrewer)



twain_list <- gutenberg_works() %>% 
  filter(str_detect(author, "Twain, Mark"),
         str_detect(title, "Letters"),
         !str_detect(title, "Complete"))
  
dickens_list <- gutenberg_works() %>% 
  filter(str_detect( author, "Dickens, Charles"), 
         str_detect(title, "Letters"))


twain_raw <- gutenberg_download(as.vector(twain_list$gutenberg_id)) %>% 
  group_by(gutenberg_id) %>% 
  mutate(author = "Twain",
         linenumber = row_number(),
         letternumber = cumsum(str_detect(text, regex("^To.*:$")))) %>% 
  filter(letternumber > 0) %>% 
  ungroup()

dickens_raw <- gutenberg_download(as.vector(dickens_list$gutenberg_id)) %>% 
  group_by(gutenberg_id) %>% 
  mutate(author = "Dickens",
         linenumber = row_number(),
         letternumber = cumsum(str_detect(text, regex("^\\[Sidenote")))) %>% 
  filter(letternumber > 0) %>% 
  ungroup()

together_tidy <- rbind(twain_raw, dickens_raw) %>% 
  unnest_tokens(word, text) %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  filter(!is.na(word)) %>% 
  anti_join(stop_words)

word_freq <- together_tidy %>% 
  count(author, word) %>%
  group_by(author) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  ungroup()


word_freq_by_author <- word_freq %>% 
  spread(author, proportion)

word_freq_by_book <- together_tidy %>% 
  count(gutenberg_id, word) %>%
  group_by(gutenberg_id) %>%
  mutate(proportion = n / sum(n)) %>% 
  select(-n) %>% 
  ungroup() %>% 
  spread(gutenberg_id, proportion)


#head(word_freq)

cor.test(word_freq_by_author$Dickens, word_freq_by_author$Twain         )

data <-cor(word_freq_by_book[,-1], use = "pairwise")
?cor.test


data <- word_freq_by_book[,-1]
qplot(x = as.factor(Var1), 
      y = as.factor(Var2), 
      data = melt(cor(data, use = "p")), 
      fill = value, geom="tile",
      main = "Correlation Plot between Dickens/Twain letter volumes",
      xlab = "Gutenberg id", 
      ylab = "Gutenberg id") +
  scale_fill_distiller(palette = "BrBG", limits = c(-1,1))
  
  
#25852 is strange - too much intro? subscript?

book_words <- together_tidy %>% 
  rename(book = gutenberg_id) %>% 
  count(book, word, sort = TRUE) %>% 
  ungroup() %>% 
  bind_tf_idf(word, book, n) %>% 
  arrange(desc(tf_idf))


