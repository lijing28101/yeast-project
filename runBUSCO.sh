#!/bin/bash
module use /work/LAS/mash-lab/software/modules
module load mash-lab/augustus
# BLAST 2.4 has bug, only use 2.2+
module load ncbi-blast/2.2.31+
module load hmmer

#ORG download from BUSCO web, the below one only used for yeast species. Need unzip after download.
ORG=saccharomycetales_odb9
MODE=genome
BUSCO_HOME=/work/LAS/mash-lab/jing/busco

genome="$1"
outname=$(basename ${genome%.*})
python ${BUSCO_HOME}/BUSCO.py \
      -o ${outname} \
      -i ${genome} \
      -l ${BUSCO_HOME}/${ORG} \
      -m ${MODE} \
      -c 16 \
      -f

