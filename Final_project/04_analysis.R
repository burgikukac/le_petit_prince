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


sentiments_nrc_alter <- sentiments_nrc %>%  # custom sentiment dict. based on only positive and negative
  filter(sentiment %in% c("positive","negative")) %>% 
  mutate(score = ifelse(sentiment=="positive", 1, -1))

senti_nrc_pos_neg <- final_tidy_1990 %>% 
  inner_join(sentiments_nrc_alter) %>% 
  group_by(gutenberg_id) %>% 
  summarise(sentiment = sum(score, na.rm = TRUE)) %>% 
  left_join(wc_by_book) %>% 
  mutate(avg_senti = round(sentiment / N_ALL, 3)) %>% 
  left_join(metadata)
  
senti_together <- senti_by_book_with_meta %>% 
  rename(avg_senti_afin = avg_senti) %>% 
  select(gutenberg_id, avg_senti_afin) %>% 
  left_join(senti_nrc_pos_neg)

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

############### plot Afinn sentiments (2 on the same plot)

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


plot02_with_margin <- ggMarginal(plot2, type = "histogram", margins = "x") 
plot02_with_margin
png("./Final_project/Plot_02_Afinn_sentiments.png")
dev.off()
# ggsave("./Final_project/Plot_02_Afinn_sentiments.png") # not working well with ggMarginal

############### plot 3 - nrc sentiments

ggplot(senti_by_nrc_with_meta, aes(year, n, color = factor(sentiment))) +
  geom_point() + 
  geom_smooth(se = FALSE, color = "black", size = 1.5) +
  theme(legend.position="none") + 
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
            fill = "red", alpha = 0.003) +
  labs(title = "Nrc sentiments over time", x = '', 
       caption = "Red lines: first years of major conflicts \n Civil War, World war 1-2, Cuban Missile Crisis")

ggsave("./Final_project/Plot_03_Nrc_sentiments.png") 






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

##### plot 4

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






############### plot Afinn + nrcsentiments (2 on the same plot)

plot5 <- ggplot(senti_together, aes(year, avg_senti)) +
  geom_smooth(se = FALSE) +
  geom_smooth(aes(year, avg_senti_afin), color = "purple", se = FALSE) +
  scale_x_continuous(breaks = seq(1850, 1990, 10)) +
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
  labs(title = "Afinn and NRC sentiments over time",
       caption = "Red lines: first years of major conflicts \n Civil War, World war 1-2, Cuban Missile Crisis")

plot5


ggsave("./Final_project/Plot_05_Afinn_and_NRC_together.png") # not working well with ggMarginal

