#!/usr/bin/env bash

module load python/3.6.0
module load emboss/6.5.7
module load bedtools2/2.26.0

species=$1

input_gff=gff/$species.gff
input_fna=genome_seq/$species.fna
output_faa=faa/$species.faa
x=/tmp/get_proteins_$species

cat $input_gff |
    awk '$3 == "CDS"' | 
    sed 's/;/\t/g' |
    cut -f 1-8,10 |
    sed 's/=/\t/g' |
    cut -f 1-8,10 |
    sort -k9 -k4n |
    awk '
       BEGIN{FS="\t";OFS="\t"}
       {$3 = $9" "$7; print}
    ' |
    bedtools getfasta  \
       -fi $input_fna  \
       -bed /dev/stdin \
       -fo /dev/stdout \
       -name |
    sed 's/::.*//' |
    awk '$1 ~ /^>/ && $1 in seqids { next }; {seqids[$1]++; print}' > $x
cat <(smof grep ' +' $x) \
    <(smof grep ' -' $x | smof reverse -cV | sed 's/|.*//' ) |
    transeq -filter |
    smof clean -sux |
    perl -pe 's/_\d+$//' > $output_faa
rm $x
