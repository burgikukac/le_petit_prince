## a long-long story....

## Final project - How average senitments changed over time of ALL books 
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  
#  03 bind
# 
#  This script filter a bunch of books from the Gutenberg project (more than 1000!)
#  AND retrieving the publishing dates from 2 pages. After that downloads each book
#  separately and saves as a feather file. 
#  However, if the target file already exists, the download only happens with FORCED_OVERWRITE = TRUE
#
#  Finally, loads the downloaded files and binds them together
#  
#  Actually no need to run until the list of desired books unchanged - the analyis will
#  use the available final_tidy file
#  
#
#
#
#  Input: 1, download_this.feather (list of books with metadata)
#         2, .feather files of donwloaded books in ./store folder
#  Output: final_tidy file (feather and Rdata)
# 

library(tidyverse)
library(tidytext)
library(stopwords)
library(feather)

rm(list = ls())


this <- read_feather("./Final_project/download_this.feather") # list of books


################## helper function that we can map on our list
custom_read <- function(number) {
  file_name <- paste0("./store/", as.character(number),".feather")
  read_feather(file_name)
}
################## end of helper function


final_raw_1990 <- map(this$gutenberg_id, custom_read) %>%  # read and bind the books
  bind_rows()

## uncomment any of this to save before tidying

# write_feather(final_raw_1990, "./Final_project/final_raw_1990.feather")
# save(final_raw_1990, file = "./Final_project/final_raw_1990.Rdata")


## I encountered memory problems increasing the number of files
## a for-cycle would be better with further increasing
 
final_tidy_1990 <- final_raw_1990 %>% 
  unnest_tokens(word, text)

## feather is faster, but github has a 100mb file limit, 

# write_feather(final_tidy_1990, "./Final_project/final_tidy_1990.feather")
save(final_tidy_1990, file = "./Final_project/final_tidy_1990.RData")

## end of this script. continue with 04_analysis.R
