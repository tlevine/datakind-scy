library(RCurl)
ssl.read.csv <- function(theurl, ...){
  # Handle SSL
  read.csv(textConnection(getURL(theurl, ssl.verifypeer = F)), ...)
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

# Weird rows
mappings <- subset(mappings,
  CsvUrl != 'https://data.cityofchicago.org/api/views/bebh-exuy/rows.csv?accessType=DOWNLOAD' &
  CsvUrl != 'https://data.cityofchicago.org/api/views/meks-hp6f/rows.csv?accessType=DOWNLOAD'
)

remap <- function (rowname){
  # Download a particular CSV and rearrange the columns.
  # print(rowname)
  remapped.cols <- unlist(mappings[rowname, MAPPING_COLUMNS], use.names = F)
  remapped.cols <- remapped.cols[1:(length(remapped.cols)-1)] # Remove CsvUrl
  remapped.cols[remapped.cols == ''] <- 'NA' 
  df <- ssl.read.csv(mappings[rowname, 'CsvUrl'], as.is = T)
  df['NA'] <- NA
# foo <- t(data.frame(
#   sort(as.vector(remapped.cols)),
#   c(sort(names(df)), NA)
# ))
  out <- df[remapped.cols]
  out$CsvUrl <- rowname
  out
}

combined.and.remapped <- Reduce(function(a, b){
  df <- remap(b)
  #print(colnames(df))
  #print(names(a))
  names(df) <- names(a) # You didn't see anything....
  rbind(a, df)
},rownames(mappings), subset(mappings, F)[MAPPING_COLUMNS])
