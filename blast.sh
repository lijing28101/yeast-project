#!/bin/bash

module load ncbi-blast

input=$PWD
output=$PWD/blastout
mkdir -p $output
mkdir -p $input/database

for j in $input/faa/*.faa
do
   echo $j |
      sed 's/^.*faa\///' |
      sed 's/.faa//' 
done > species
species=$(cat species)

for s in $species
do 
   mkdir -p $input/database/$s.db
   dbfolder=$input/database/$s.db
   input_protein=$s.faa
   cp $input/faa/$s.faa $dbfolder
   cd $dbfolder
   makeblastdb -in $input_protein -title $s.db -dbtype prot -out $s.db -parse_seqids
   cd $input
done

for s in $species
do 
   grep -v $s species > non.$s
   non=$(cat non.$s)
   for m in $non
   do
      query=$input/faa/$s.faa
      db=$input/database/$m.db/$m.db
      outfile=$output/$s.txt
      blastp \
         -query $query \
         -db $db \
         -num_threads 16 \
         -outfmt '6 qseqid sseqid evalue bitscore qstart qend sstart send' >> $outfile
    done
done

for s in $species
do
   query=$input/faa/$s.faa
   blast=$input/blastout/$s.txt
   x=/tmp/$s.complete_gene.txt
   y=/tmp/$s.non_orphan_gene.txt
   sed -n 's/>\([^ ]\+\).*/\1/p' $query > $x
   awk 'NR > 1 && $3 < 1e-3' $blast | cut -f1 | uniq | sort -u > $y
   cat $x $y | sort | uniq -u > orphan_$s.txt
   rm $x
   rm $y
done
