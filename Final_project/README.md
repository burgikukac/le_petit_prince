# Final project (DS of Unstructured Text Data)


This is my **final project** for the course  **DS of Unstructured Text Data** held by *Eduardo Ariño de la Rubia* on CEU in 2018.

The idea was to demonstrate some of the topics that we learned through an analysis and by doing it learning some more...

## The problem  

The question I tried to answer seems to be impossible - however sometimes trying to solve very hard things drives innovation.  

Is it possible to forecast drastic changes through textual data? **Is there a demonstrable sentiment change in literature before wars?** Calm before storm? Or just the opposite, the subconscious tension can be seen? **How average sentiments changed over time?**   

There are lots of biases here, so I focused on:

1, literature available in English on the Gutenberg Project
2, preferably USA based
3, fiction
4, between 1850-1990 (first published)


### Structure of the script  

1. Finding the books I am interested in
2. Download them via the *gutenbergR* library
3. Binding the downloaded files
4. Doing the analysis


### Publishing dates and the Gutenberg Project

For me it was very suprising that among the Gutenberg **metadata** there is no information about the publishing dates of the works. The cliché about the time-consuming 80% part of the analytics process emerged again: most of the time I spent solving this problem.  

Finally I ended up using two sources and merging the extracted data: **www.worldcat.org** and **openlibrary.org**. The search engine of the first one is better (more flexible too), almost every enquiry had result - but often the edition was a late one, sometimes the result was the upload time to the Gutenberg Project! My interest was **when** the author wrote those words, and not when somebody published another edition. For this purpose, I always extracted the earliest date among the results. Openlibrary gave much less answers, but it has a clear *first published in* field.   

I set the date to the minimum of the two sources, if it was *credible* (after the birth year + 15, less than death year + 5). The script than only downloads the books in the target range.  

After the Gutenberg filtering, 1118 books were on my list, without the publishing dates. Filtering to the year, **remained 507**.  

## Downloading  



## Binding todether, tidying

## Analysis, results

## Possible development

## The key things I learned solving this problem

1. **web scraping** (simulating repeated searches on a webpage to find the data I am interested in)
2. **using regular expressions** (extracting information from strings)
3. **using dplyr pipelines constantly** (and breaking down the pipeline when it is important)
4. **using feather** (saving / reloading tables blazingly fast in order to avoid unnecessary repeated scraping / computation)
5. **caching my downloads** (my custom function only downloads files that not exist already in the local repo, unless the FORCED_OVERWRITE is set to TRUE) 
6. **freeing up memory** (processing 1000+ books could eat up memory unless we discard the unused data)
7. **breaking up the process of analysis** (different file for different function, saving state in feather files, recalculate what is necessary only)
8. **basic sentiment analysis** 


Tamas Burghard