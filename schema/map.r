MAPPING_COLUMNS <- -1:-2

# Load the mappings spreadsheet
mappings <- read.csv('mappings')
mappings$CsvUrl <- paste(
 'https://data.cityofchicago.org/api/views/',
  strsplit(mappings$url, '/')[-1],
  '/rows.csv?accessType=DOWNLOAD',
  sep = ''
)
rownames(mappings) <- mappings$Category

remap <- function (rowname){
  # Download a particular CSV and rearrange the columns.
  read.csv(mappings[rowname, 'CsvUrl'])[mappings[rowname, MAPPING_COLUMNS]]
}


Reduce(function(a, b){
  rbind(a, remap(b))
},rownames(mappings), subset(mappings, F))
