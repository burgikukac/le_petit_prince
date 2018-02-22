library(tidyverse)
library(tidytext)
library(rvest)
library(stopwords)

#Sys.setlocale(category = "LC_ALL", "en_US.UTF-8")

## Uses:
# Szab? Martina Katalin 2014. Egy magyar nyelv? szentimentlexikon l?trehoz?s?nak
# tapasztalatai [Experiences of creation of a Hungarian sentiment lexicon]. 
# Conference ?Nyelv, kult?ra, t?rsadalom?, Budapest, Hungary. 


links <- c("https://www.odaha.com/antoine-de-saint-exupery/maly-princ/the-little-prince",
           "https://www.odaha.com/antoine-de-saint-exupery/maly-princ/el-principito",
           "https://www.odaha.com/antoine-de-saint-exupery/maly-princ/il-piccolo-principe",
           "https://www.odaha.com/antoine-de-saint-exupery/maly-princ/kis-herceg",
           "https://www.odaha.com/antoine-de-saint-exupery/maly-princ/le-petit-prince")

languages <- c("en", "es", "it", "hu", "fr")

prince_raw   <- tibble(languages, links) %>% 
  mutate( webpages = map(links, read_html)) %>% 
  mutate( nodes = map(webpages, html_nodes, '.entrytext')) %>% 
  mutate( text = map(nodes, html_text)) %>% 
  select(languages, text)

prince_raw %>% 
  group_by(languages) %>% 
  summarize( Len = str_length(text)) %>% 
  ungroup()
 # length of each version


prince_tidy <- prince_raw %>% 
  unnest_tokens(word, text)



## SENTIMENT LISTS
temp <- tempfile()
download.file("http://www.opendata.hu/storage/f/2016-06-06T11%3A27%3A11.366Z/precosenti.zip",temp)
con <- unz(temp, "PrecoSenti/PrecoPos.txt")
pos <- read.csv(con, stringsAsFactors = FALSE, col.names = FALSE, encoding="UTF-8") %>% 
  mutate(score = 1, languages = "hu") %>% 
  rename(word = FALSE.)
con2 <- unz(temp, "PrecoSenti/PrecoNeg.txt")
neg <- read.csv(con, stringsAsFactors = FALSE, col.names = FALSE, encoding="UTF-8") %>% 
  mutate(score = -1, languages = "hu") %>% 
  rename(word = FALSE.)

sentiments_hu <- rbind(pos, neg)  # this could be a one-liner with the previous too

# sentiments_en_lou <- get_sentiments(loughran) %>% 

sentiments_en_lou <- get_sentiments("bing") %>% 
  mutate(score = if_else(sentiment == "positive", 1, -1)) %>% 
  mutate(sentiment = NULL, languages ="en")


# should fix this
#download.file("http://habla.dc.uba.ar/gravano/files/SpanishDAL-v1.2.tgz",temp)
#con2 <- unz(temp,)

# needs conversion
sp <-read.csv("http://danigayo.info/downloads/Ratings_Warriner_et_al_Spanish.csv", stringsAsFactors = FALSE)




sentiments <- rbind(sentiments_en_lou, sentiments_hu)


prince_tidy %>% 
  group_by(languages) %>% 
  inner_join(sentiments) %>% 
  summarise( sent = sum(score))



 wc <- prince_tidy %>% 
#  group_by(languages) %>% 
  inner_join(sentiments) %>% 
  group_by(languages) %>% 
  count(word, score, sort = TRUE) %>% 
 ungroup()


 wc
 




# good plot
wc %>%
  group_by(languages,score) %>% top_n(8) %>% ungroup() %>% mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n*score, fill = score)) + geom_col(show.legend = FALSE) +
  facet_wrap(~languages, scales = "free_y") + labs(y = "Contribution to sentiment", 
                                                   x = NULL) + coord_flip()



# comparing languages by 250 words
prince_tidy <- prince_raw %>% 
  unnest_tokens(word, text) 
  




to_plot <- prince_tidy %>%
  group_by(languages) %>% 
  mutate(row = row_number()) %>% 
  ungroup() %>% 
  inner_join(sentiments) %>% 
  group_by(languages, index = row %/% 250) %>% 
  summarize(sentiment = sum(score)) %>% 
  ungroup()


to_plot %>%
  ggplot(aes(index, sentiment, fill = languages)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~languages, ncol = 1, scales = "free_x")


#----------------------------------
# run above this line, this part is a previous junk of mine

stopwords_eng <- data_frame(word = stopwords("en"))
stopwords_hun <- data_frame(word = stopwords("hu", source = "stopwords-iso"))


str(stopwords("hu", source = "stopwords-iso"))



sentiments_eng_lou <- get_sentiments("loughran") %>% mutate(score = if_else(sentiment == "positive", 1, -1))

sentiments_eng_bing <- get_sentiments("bing") %>% mutate(score = if_else(sentiment == "positive", 1, -1))





