library(tidyverse)
library(tidytext)
library(rvest)

# Sys.setlocale(category = "LC_ALL", "en_US.UTF-8")

## Uses:
# Szabó Martina Katalin 2014. Egy magyar nyelvû szentimentlexikon létrehozásának
# tapasztalatai [Experiences of creation of a Hungarian sentiment lexicon]. 
# Conference „Nyelv, kultúra, társadalom”, Budapest, Hungary. 


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

d <- tibble(scan(con))
data <- matrix(scan(con),ncol=4,byrow=TRUE)
unlink(temp)

scan(con)
con

pos <- read.csv(con, stringsAsFactors = FALSE)
