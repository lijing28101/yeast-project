#!/bin/bash

#SBATCH -t 48:00:00   # walltime
#SBATCH -N 1   # number of nodes in this job
#SBATCH -n 16   # total number of processor cores in this job
#SBATCH --mail-user=jingli@iastate.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

#The braker in condo2017 is failed, use our private braker in lab folder
module use /work/LAS/mash-lab/software/modules
module purge
module load mash-lab/braker

module load hisat2
module load samtools

#Make a folder for a species, copy the SRR file and genomic sequence in this folder. 
#Copy this script in the folder and change the species name.
species=$1
hisat2-build $species.fna $species

#If the RNAseq is paired, cat the same direction file together for the paired data
cat SRR*_1* >> SRR_1.fq.gz
cat SRR*_2* >> SRR_2.fq.gz
hisat2 -p 16 -x $species -1 SRR_1.fq.gz -2 SRR_2.fq.gz > $sapecies.sam
samtools view -bS $species.sam | samtools sort -m 5G - > $species.bam

#If the RNAseq is single, cat the SRR file for single direction together
#if there are more than one sam file
#samtools view -bS input1.sam > output1.bam
#samtools view -bS input2.sam > output2.bam
#samtools merge combined.bam output1.bam output2.bam
#samtools sort -m 5G combined.bam > combined_sorted.bam

perl $BRAKER_HOME/braker.pl --genome=$species.fna --species=$species --bam=$species.bam

#After finishing braker, load cufflinks to convert gtf to gff3
#gffread -E augustus.gtf -o a.gff3 2> error
#grep "gene" error >>a.gff3 | sort -k4 > $species.gff
