## a long-long story....

## Final project - How average senitments changed over time of ALL books 
#
#  DS of Unstructured Text Data held by Eduardo Ariño de la Rubia on CEU in 2018
#  Tamas Burghard
#
#  
#  02 Gutenberg download
# 
#  This script downloads tons of books from the Gutenberg project (more than 500!)
#  and saves each as a feather file. 
#  However, if the target file already exists, the download only happens with FORCED_OVERWRITE = TRUE
#
#  Actually no need to run until the list of desired books unchanged - the analyis will
#  use the available final_tidy file
#  
#
#  Input: download_this.feather (+raw text files from Project Gutenberg)
#  Output: separate .feather files in the ./store folder   
# 

library(gutenbergr)
library(feather)

rm(list = ls())

### custom (disk - cached) download

FORCED_OVERWRITE <- FALSE 

this <- read_feather("./Final_project/download_this.feather")
num <- length(this$gutenberg_id)

for (i in seq(1:num)) { # the vectorized pipeline was extremely slow here
  actual <- this$gutenberg_id[i]
  file_name <- paste0("./store/", as.character(actual),".feather")
  if ((FORCED_OVERWRITE == TRUE) || !file.exists(file_name)) {
    downloaded <- gutenberg_download(actual)
    write_feather(downloaded, file_name)
  }
}

### end of this script. continue with 03_bind.R