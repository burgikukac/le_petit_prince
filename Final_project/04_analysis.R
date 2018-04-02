## a long-long story....

## Final project - How average senitments changed over time of ALL books 
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  
#  04 analysis
# 
#  This script loads the tidy text and performs the sentiment analysis 
#
#
#
#  Input: 1, final_tidy_1990.Rdata (or feather)
#         2, download_this.feather (gutenbergR metadata)
#  Output: graphs    
# 
library(tidyverse)
library(tidytext)
library(stopwords)
library(RColorBrewer)
library(feather)
library(ggExtra)

rm(list = ls())

# final_tidy_1990 <- read_feather("./Final_project/final_tidy_1990.feather")
load(file = "./Final_project/final_tidy_1990.RData")

download_this <- read_feather("./Final_project/download_this.feather")

metadata <- download_this %>% 
  select(gutenberg_id, gutenberg_author_id, year)

### wordcounts by book 
wc_by_book <- final_tidy_1990  %>% 
  group_by(gutenberg_id) %>% 
  summarise(N_ALL = n()) %>% 
  ungroup()

###  sentiments 1: afinn (positive or negative)
sentiments <- get_sentiments("afinn")

senti_by_book <- final_tidy_1990 %>% 
  inner_join(sentiments) %>% 
  group_by(gutenberg_id) %>% 
  summarise(sentiment = sum(score, na.rm = TRUE)) %>% 
  left_join(wc_by_book) %>% 
  mutate(avg_senti = round(sentiment / N_ALL, 3))

senti_by_book_with_meta <- senti_by_book %>% 
  left_join(metadata)

### sentiments 2: nrc (anger, trust, fear, etc.)
sentiments_nrc <- get_sentiments("nrc")

senti_by_nrc_with_meta <- final_tidy_1990 %>% 
  inner_join(sentiments_nrc) %>%
  count(gutenberg_id, sentiment) %>% 
  left_join(wc_by_book) %>% 
  mutate(n = round(n / N_ALL, 3), N_ALL = NULL) %>%  
  #spread(sentiment, n, fill = 0) %>% 
  left_join(metadata)

  
  
############### plot 1 histogram : publish year
ggplot(metadata, aes(year)) +
  geom_histogram() + 
  geom_vline(xintercept = 1914, col="red") + 
  geom_vline(xintercept = 1939, col="red") +
  geom_vline(xintercept = 1861, col="red") +
  geom_vline(xintercept = 1989, col="red") +
  geom_vline(xintercept = 1962, col="red") +
  geom_rect(xmin = 1914, xmax = 1918, 
            ymin = 0, ymax = 100,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1939, xmax = 1945, 
            ymin = 0, ymax = 100,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1861, xmax = 1865, 
            ymin = 0, ymax = 100,
            fill = "red", alpha = 0.003) + 
  labs(title = "Number of books by year",
       caption = "Red lines: first years of major conflicts \n Civil War, World war 1-2, Cuban Missile Crisis")


ggsave("./Final_project/Plot_01_histogram.png")

############### plot 2 avg sentiments (2 on the same plot)

plot2 <- ggplot(senti_by_book_with_meta, aes(year, avg_senti)) +
  geom_point() + 
  geom_vline(xintercept = 1914, col="red") + 
  geom_vline(xintercept = 1939, col="red") +
  geom_vline(xintercept = 1861, col="red") +
  geom_vline(xintercept = 1989, col="red") +
  geom_vline(xintercept = 1962, col="red") +
  geom_rect(xmin = 1914, xmax = 1918, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1939, xmax = 1945, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1861, xmax = 1865, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) +
  geom_smooth(se = FALSE)  +
labs(title = "Afinn sentiments over time",
     caption = "Red lines: first years of major conflicts \n Civil War, World war 1-2, Cuban Missile Crisis")


ggMarginal(plot2, type = "histogram", margins = "x") 



#  geom_line(aes(y=rollmean(avg_senti, 10, na.pad=TRUE)), color = "red", size = 1)

#library(zoo)



ggplot(senti_by_nrc_with_meta, aes(year, n)) +
  geom_point() + 
  facet_wrap(~ sentiment) + 
  geom_vline(xintercept = 1914, col="red") + 
  geom_vline(xintercept = 1939, col="red") +
  geom_vline(xintercept = 1861, col="red") +
  geom_vline(xintercept = 1989, col="red") +
  geom_vline(xintercept = 1962, col="red") +
  
  
  geom_rect(xmin = 1914, xmax = 1918, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1939, xmax = 1945, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1861, xmax = 1865, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003)







ggplot(senti_by_nrc_with_meta, aes(year, n, color = sentiment)) +
  geom_point() + 
  geom_vline(xintercept = 1914, col="red") + 
  geom_vline(xintercept = 1939, col="red") +
  geom_vline(xintercept = 1861, col="red") +
  geom_vline(xintercept = 1989, col="red") +
  geom_vline(xintercept = 1962, col="red") +
  
  
  geom_rect(xmin = 1914, xmax = 1918, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1939, xmax = 1945, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1861, xmax = 1865, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003)


## additional stats
stats <- senti_by_nrc_with_meta %>% 
  group_by(sentiment, year ) %>% 
  summarize(
    min = min(n),
    max = max(n),
    mean = round(mean(n) , 3)) %>% 
  filter(sentiment == "fear")


ggplot(stats, aes(year, mean, color = sentiment)) +
  geom_line(color = "black") +
  geom_line(aes(y = min), color = "blue") +
  geom_vline(xintercept = 1914, col="red") + 
  geom_vline(xintercept = 1939, col="red") +
  geom_vline(xintercept = 1861, col="red") +
  geom_vline(xintercept = 1989, col="red") +
  geom_vline(xintercept = 1962, col="red") +
  
  
  geom_rect(xmin = 1914, xmax = 1918, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1939, xmax = 1945, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003) + 
  geom_rect(xmin = 1861, xmax = 1865, 
            ymin = -1, ymax = 1,
            fill = "red", alpha = 0.003)


