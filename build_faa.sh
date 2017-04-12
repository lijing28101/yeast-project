#!/usr/bin/env bash

species=$1

# Assume the gff and genome_seq folders are in the current folder.
input_gff=$PWD/gff/$species.gff
input_fna=$PWD/genome_seq/$species.fna
output_faa=$PWD/faa/$species.faa
parse_script=$PWD/parse_gff.R
x=/tmp/get_proteins_$species

mkdir -p $PWD/faa

if [ ! -f "$input_gff" ]
then
   echo "$input_gff does not exist."
fi

if [ ! -f "$input_fna" ]
then
   echo "$input_fna does not exist."
fi

if [ ! -f "$parse_script" ]
then
   echo "$parse_script does not exist."
fi

$parse_script -i $input_gff 2> /dev/null |
   awk ' 
      BEGIN{FS="\t";OFS="\t"}
      {$3 = $9" "$7; print}
   ' |
   bedtools getfasta  \
      -fi $input_fna  \
      -bed /dev/stdin  \
      -fo /dev/stdout  \
      -name |
   sed 's/::.*//' |
   awk '$1 ~ /^>/ && $1 in seqids { next }; {seqids[$1]++; print}' > $x

cat <(smof grep ' +' $x) \
    <(smof grep ' -' $x | smof reverse -cV | sed 's/|.*//' ) |
    transeq -filter |
    smof clean -sux |
    perl -pe 's/_\d+$//' > $output_faa

rm $x
