mappings <- read.csv('mappings')

keys <- mappings[-1] # Without source file
rownames(keys) <- mappings$source_file

remap <- function (filename){
  read.csv(filename)[keys[filename,]]
}

output_schema<-subset(keys, F)

Reduce(function(a, b){
  rbind(a, remap(b))
},rownames(keys), output_schema)
