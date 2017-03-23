#!/usr/bin/env Rscript --vanilla



gfffile="species.gff"

# think about what can go wrong, add tests and messages
# to make this an R script, Rscript
# look at the argparse library or docopt (http://docopt.org/)

getAttributeField <- function (x, field, attrsep = ";") {
  regex <- sprintf('.*%s=([^;]+).*', field)
  regex_log <- sprintf('%s=[^;]+', field) 
  if( !all(grepl(regex_log, x)) ){
    warning(sprintf("Incorrect formatting of GFF file, could not find pattern '%s'", regex_log))
  }
  sub(regex, '\\1', x)
}

# getAttributeField <- function (x, field, attrsep = ";") {
#      s = strsplit(x, split = attrsep, fixed = TRUE)
#      sapply(s, function(atts) {
#          a = strsplit(atts, split = "=", fixed = TRUE)
#          m = match(field, sapply(a, "[", 1))
#          if (!is.na(m)) {
#              rv = a[[m]][2]
#          } else {
#              rv = as.character(NA)
#          }
#          return(rv)
#      })
# }

gffRead <- function(gffFile, nrows = -1) {
     # cat("Reading ", gffFile, ": ", sep="", file=stderr())
     gff = read.table(
       gffFile,
       sep="\t",
       as.is=TRUE,
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
     # cat("found", nrow(gff), "rows with classes:",
     #     paste(sapply(gff, class), collapse=", "), "\n")
     stopifnot(!any(is.na(gff$start)), !any(is.na(gff$end)))
     return(gff)
}

if(!file.exists(gfffile)){
  cat("Cannot open GFF file\n", file=stderr())
}

species.gff <- gffRead(gfffile)
species.gff_CDS <- subset(species.gff,feature=="CDS")
species.gff_CDS2 <- subset(species.gff_CDS,select=-(attributes))
species.gff_CDS2$Parent <- getAttributeField(species.gff_CDS$attributes,"Parent")
species.gff_CDS2$ID <- getAttributeField(species.gff_CDS$attributes,"ID")
