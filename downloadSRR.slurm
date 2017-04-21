#!/bin/bash

#SBATCH -t 48:00:00   # walltime
#SBATCH -N 1   # number of nodes in this job
#SBATCH -n 16   # total number of processor cores in this job
#SBATCH --mail-user=jingli@iastate.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

module load sratoolkit
while read line; do echo "now downloading $line"; fastq-dump --split-files --origfmt --gzip $line; done<SRR.numbers

