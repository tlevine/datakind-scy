library(RCurl)
ssl.read.csv <- function(theurl, ...){
  # Handle SSL
  read.csv(textConnection(getURL(theurl)), ...)
}

# Columns with mappings
MAPPING_COLUMNS <- -1:-2

getCsvUrl <- function(theUrl){
  paste(
    'https://data.cityofchicago.org/api/views/',
    tail(strsplit(theUrl, '/')[[1]], 1),
    '/rows.csv?accessType=DOWNLOAD',
    sep = ''
  )
}

mappings <- (function(){
  # Load the mappings spreadsheet
  mappings <- read.csv('headers.csv', as.is = T)
  mappings$CsvUrl <- sapply(mappings$DataUrl, getCsvUrl)
  rownames(mappings) <- mappings$CsvUrl
  mappings
})()

remap <- function (rowname){
  # Download a particular CSV and rearrange the columns.
  ssl.read.csv(mappings[rowname, 'CsvUrl'])[MAPPING_COLUMNS]
}

combined.and.remapped <- Reduce(function(a, b){
  rbind(a, remap(b))
},rownames(mappings), subset(mappings, F))
