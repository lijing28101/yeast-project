#!/usr/bin/env Rscript

require(docopt)

"Usage:
    parse_gff.R [ -h -i <input> -o <output> -f <feature> -a1 <attribute1> -a2 <attribute2> -a3 <attribute3> ]

Options:
  -h --help Show this screen
  -i Input GFF file
  -o Output GFF file
  -f Feature of gene
  -a1 Attribute1 of gene
  -a2 Attribute2 of gene
  -a3 Attribute3 of gene

" -> doc

opts <- docopt(doc)

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

gffRead <- function(gffFile, nrows = -1) {
     cat("Reading ", gffFile, ": ", sep="", file=stderr())
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
     cat("found", nrow(gff), "rows with classes:",
         paste(sapply(gff, class), collapse=", "), "\n")
     stopifnot(!any(is.na(gff$start)), !any(is.na(gff$end)))
     return(gff)
}

if(!file.exists(opts$i)){
  cat("Cannot open GFF file\n", file=stderr())
}


species.gff <- gffRead(opts$i)
species.gff_F <- subset(species.gff,feature==opts$f)
species.gff_F2 <- subset(species.gff_F,select=-(attributes))
species.gff_F2$opts$a1 <- getAttributeField(species.gff_F$attributes,opts$a1)
species.gff_F2$opts$a2 <- getAttributeField(species.gff_F$attributes,opts$a2)
species.gff_F2$opts$a3 <- getAttributeField(species.gff_F$attributes,opts$a3)

write.table(species.gff_F2,opts$o,sep="\t",row.names=FALSE,col.names=FALSE,quote=FALSE)

