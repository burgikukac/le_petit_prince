## a long-long story....
library(gutenbergr)
library(tidyverse)
library(tidytext)
library(stringr)
library(stopwords)
library(reshape2)
library(RColorBrewer)
library(urltools)
library(rvest)

rm(list = ls())


authors <- gutenberg_authors %>% 
  filter(deathdate > 1850)

meta  <- gutenberg_metadata %>% 
  filter(language == "en",
         has_text == TRUE)

#%>% 
#  group_by(has_text) %>% 
#  summarise(N = n())

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
         str_detect(gutenberg_bookshelf, "iction"),
         str_detect(author, ",")
         
         
  ) -> meta3

meta3 %>% 
  group_by(wikipedia) %>% 
  summarise(N = n()) %>% 
  arrange(desc(N))  -> kukucs

look_this <- meta3 %>% sample_n(50)

# url1 <- "https://www.worldcat.org/search?qt=worldcat_org_bks&q="
# 
# #Goodale%2C+S.+L.+%28Stephen+Lincoln%29+%3A+The+Principles+of+Breeding+or%2C+Glimpses+at+the+Physiological+Laws+involved+in+the+Reproduction+and+Improvement+of+Domestic+Animals
# 
# url3 <- "&fq=dt%3Abks"
# 
# value_to_set  <- paste(look_this$author, look_this$title, sep = " : " ) 
# value_to_set 
# v2 <- url_encode(value_to_set)
# v2
# 
# 
# url <- paste0(url1, v2, url3)

url1 <- "https://www.worldcat.org/search?qt=worldcat_org_bks&q="

url2 <- paste0("ti:", url_encode( look_this$title))
url3 <- paste0("+au:", url_encode(look_this$author))

url4 <- "&qt=advanced&dblist=638"

url <- paste0(url1, url2, url3, url4)

#raw2   <- tibble(v2, links = url) %>% 
#  mutate( webpages = map(links, read_html)) %>% 
#  mutate( nodes = map(webpages, html_nodes, '.itemPublisher')) %>% 
#  mutate( text = map(nodes, html_text)) 


#%>% 
#  select(languages, text)


raw2   <- tibble(links = url) %>% 
  mutate( webpages = map(links, read_html)) %>% 
  mutate( nodes = map(webpages, html_nodes, '.itemPublisher')) %>% 
  mutate( text = map(nodes, html_text)) 


# url <- "http://en.wikipedia.org/wiki/api.php?action=parse&pageid=1023&export=json"
# url <- param_set(url, key = "pageid", value = "12")
# url
# # [1] "http://en.wikipedia.org/wiki/api.php?action=parse&pageid=12&export=json"
# 
# As you can see this works pretty well; it even works in situations where the URL doesn't have a query yet:
# 
# url <- "http://en.wikipedia.org/wiki/api.php"
# url <- param_set(url, key = "pageid", value = "12")
# url
# # [1] "http://en.wikipedia.org/wiki/api.php?pageid=12"

View(raw2$text[[9]])
write.csv(raw2$links, "raw2.txt")
str(raw2, max.level = 1)

## to extract year number
## input: messy string from scrape
## output: 4 digit number, starting with 1-2
## method: extracting from the last 6 characters

#s1 <- str_trunc(raw2$text[[10]], 6, side = "left", ellipsis = "")
#min(as.numeric(str_extract_all(s1, "[0-9]{4,4}")), na.rm = TRUE)

extract_publish <- function(RAW_TEXT_I) {
  s1 <- str_trunc(RAW_TEXT_I, 6, side = "left", ellipsis = "")
  min(as.numeric(str_extract_all(s1, "[0-9]{4,4}")), na.rm = TRUE)
  
}

#extract_publish(raw2$text)

map(raw2$text, extract_publish)
