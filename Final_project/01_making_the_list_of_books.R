## a long-long story....

## Final project - How average senitments changed over time of ALL books 
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  
#  01 making the list of books
# 
#  This script filter a bunch of books from the Gutenberg project (more than 1000!)
#  AND retrieving the publishing dates from 2 pages. 
#
#  scraping is very slow,  
#
#  Input: gutenbergR metafiles + scraped info from the web
#  Output: download_this.feather    
 

library(gutenbergr)
library(tidyverse)
library(stringr)
library(urltools)
library(rvest)
library(feather)

rm(list = ls())


authors <- gutenberg_authors %>% 
  filter(deathdate > 1850)

# meta: shortlist of interesting books

meta  <- gutenberg_metadata %>% 
  inner_join(authors) %>% 
  filter(language == "en",
         has_text == TRUE,
         !is.na(wikipedia),
         !str_detect(gutenberg_bookshelf, "hildren"),
         !str_detect(gutenberg_bookshelf, "Australia"),
         !str_detect(gutenberg_bookshelf, "United Kingdom"),
         !str_detect(gutenberg_bookshelf, "Animals"),
         str_detect(gutenberg_bookshelf, "iction"),
         str_detect(author, ",")
  ) %>% 
  mutate(author2 = str_replace(author, "^([0-9A-Za-z]+), ([0-9A-Za-z]+)(\\.|,| |$)([\\.,() 0-9A-Za-z])*", "\\2 \\1")
)

# author2: a simpler name, just one name and family name. increases the search rate on web




# uncomment this for a basic analysis by author
# meta %>% 
#   group_by(wikipedia) %>% 
#   summarise(N = n()) %>% 
#   arrange(desc(N))  

################## helper functions #################################

## to extract year number from scraped text
## input: messy string from scrape
## output: 4 digit number, starting with 1-2
## method: extracting from the last 6/12 characters

extract_publish <- function(RAW_TEXT_I) {
  s1 <- str_trunc(RAW_TEXT_I, 6, side = "left", ellipsis = "")
  min(as.numeric(str_extract_all(s1, "[0-9]{4,4}")), na.rm = TRUE)
  
}
extract_publish_openlib <- function(RAW_TEXT_I) {
  s1 <- str_trunc(RAW_TEXT_I,12, side = "left", ellipsis = "")
  min(as.numeric(str_extract_all(s1, "[0-9]{4,4}")), na.rm = TRUE)
  
}
#############end of helper functions #################################



look_this <- meta  # will looking for this list 
#look_this <- meta %>% sample_n(20) # uncomment this line to try the scraping on a sample

############### Worldcat.org #############################################
############### getting publish year info, searching for author2 and title
# vectorized search 

url1 <- "https://www.worldcat.org/search?qt=worldcat_org_bks&q="
url2 <- paste0("ti:", url_encode( look_this$title))
url3 <- paste0("+au:", url_encode(look_this$author2))
url4 <- "&qt=advanced&dblist=638"

url <- paste0(url1, url2, url3, url4)  # composing the search url vector

raw_worldcat_download   <- tibble(links = url) %>%  # do the search scrape
  mutate( webpages = map(links, read_html))  #  this takes a long time, so better break the pipe here

#save(raw_worldcat_download, file = "./Final_project/raw_worldcat_download.RData")
# feather is not working with this data 


raw_worldcat_processed <- raw_worldcat_download %>%  # get the html text out
  mutate( nodes = map(webpages, html_nodes, '.itemPublisher')) %>% 
  mutate( text = map(nodes, html_text)) 

look_this$year_worldcat <- map_dbl(raw_worldcat_processed$text, 
                                   extract_publish) # call the helper function

################# second method www.openlibrary.org

url1 <- "https://openlibrary.org/search?q="
url2 <- paste0("title:", url_encode( look_this$title))
url3 <- paste0("+author:", url_encode(look_this$author2))
url4 <- "&mode=everything"

url <- paste0(url1, url2, url3, url4)

raw_openlib_download <- tibble(links = url) %>% 
  mutate( webpages = map(links, read_html))  # takes a long time, better break the pipe here

#save(raw_openlib_download, file = "./Final_project/raw_openlib_download.RData")


raw_openlib_processed <- raw_openlib_download %>% 
  mutate( nodes = map(webpages, html_nodes, '.resultPublisher')) %>% 
  mutate( text = map(nodes, html_text)) 

look_this$year_openlib <- map_dbl(raw_openlib_processed$text, 
                                  extract_publish_openlib)  # call the helper

#write_feather(look_this, "./Final_project/look_this.feather")


## now we have 'look_this' that contains the possible booklist with the metadata

#look_this <- read_feather("./Final_project/look_this.feather") # uncomment this to start the script from here


# now we merge the two publish dates into one
# also compare to the birth / death year of the author

yearhelper <- function(birth, death, y1, y2) {
  birth <- birth + 15  # allow to publish at age 15
  death <- death + 5  # until death + 5: exact year when the author wrote those words is important. 
  if (y1 < birth || y1 > death) { # not credible dates
    y1 <- Inf
  } 
  if (y2 < birth || y2 > death) { # not credible dates
    y2 <- Inf
  } 
  min(y1,y2) # the publish year is the lower of the two scraped
}

look_this$year <- Inf  # ugly for cycle instead of a map with 4 parameters
num <- length(look_this$gutenberg_id)
for (i in seq(1:num)) {
  look_this$year[[i]] <- yearhelper(look_this$birthdate[[i]],
                                    look_this$deathdate[[i]],
                                    look_this$year_openlib[[i]],
                                    look_this$year_worldcat[[i]]
  )
}
                                    
# now we have the publish date in the year column, we can filter out the books
# not matching our year criteria

download_this <- look_this %>% 
  filter(year < 1990, year > 1850)

write_feather(download_this, "./Final_project/download_this.feather")

### end of this script. continue with 02_download.R
