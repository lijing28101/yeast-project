#!/usr/bin/env Rscript

library(docopt)
library(plyr)

"Usage:
    parse_gff.R [ -i <input> ] [ -o <output> ] [ -f <feature> ] [ -a <attribute> ]

Options:
  -i Input GFF file  
  -o Output GFF file [default: /dev/stdout]
  -f Feature of gene [default: CDS]
  -a Attributes (comma delimited, e.g. 'ID,Parent') [default: Parent]
" -> doc

opts <- docopt(doc)

getAttributeField <- function (x, field, attrsep = ";") {
  regex <- sprintf('.*%s=([^;]+).*', field)
  regex_log <- sprintf('%s=[^;]+', field)
  if( !all(grepl(regex_log, x)) ){
    warning(sprintf("Incorrect formatting of GFF file, could not find pattern '%s'", regex_log))
  }
  sub(regex, '\\1', x)
}

gffRead <- function(gffFile, nrows = -1) {
     cat("Reading ", gffFile, ": ", sep="", file=stderr())
     gff = read.table(
       gffFile,
       sep="\t",
       stringsAsFactors=FALSE,
       quote="",
       header=FALSE,
       comment.char="#",
       nrows = nrows,
       colClasses=c(
          "character", "character", "character", "integer",
          "integer", "character", "character", "character", "character")
     )
     colnames(gff) = c(
          "seqname", "source", "feature", "start", "end",
          "score", "strand", "frame", "attributes")
     cat("found", nrow(gff), "rows with classes:",
         paste(sapply(gff, class), collapse=", "), "\n", file=stderr())
     stopifnot(!any(is.na(gff$start)), !any(is.na(gff$end)))
     return(gff)
}

if(!file.exists(opts$i)){
  cat("Cannot open GFF file\n", file=stderr())
}


species.gff <- gffRead(opts$i)
species.gff_F <- subset(species.gff,feature==opts$f)
species.gff_F2 <- subset(species.gff_F,select=-(attributes))

for(a in strsplit(opts$a, ",")[[1]]){
  species.gff_F2[[a]] <- getAttributeField(species.gff_F$attributes,a)
}

species.gff_F2 <- arrange(species.gff_F2,Parent,start)

write.table(
  species.gff_F2,
  opts$o,
  sep       = "\t",
  row.names = FALSE,
  col.names = FALSE,
  quote     = FALSE
)
