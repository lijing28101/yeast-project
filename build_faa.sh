#!/usr/bin/env bash

# Overall, avoid hard-coding values (e.g. modules, filenames, column positions)

#  NOTE: we should check the versions of dependencies, but shouldn't explicitly
#        import them, since the module loading code will vary between systems.
module load python/3.6.0
module load emboss/6.5.7
module load bedtools2/2.26.0

species=$1

#  NOTE: we should either take all these files as inputs OR state very clearly
#        our assumptions about the directory structure.
#  NOTE: we should also check the existence of all these files
input_gff=gff/$species.gff
input_fna=genome_seq/$species.fna
output_faa=faa/$species.faa
x=/tmp/get_proteins_$species

# It might be worthwhile to replace all the material from `cat $intput_gff` to
# just before `bedtools` with an R script. All of this column management in
# Bash is very error prone. The best solution would be to rewrite this entire
# script in pure R.

cat $input_gff |
    awk '$3 == "CDS"' | 
    # NOTE: this is a nice clean approach, however it won't work for all
    #       inputs. The entries (<tag>=<value>) in the 9th don't have to be in
    #       any particular order. 'Parent' won't always be the second tag. So
    #       rather than parsing based on position, we should parse based on
    #       tag. From the 9th column, extract the values you want.
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
