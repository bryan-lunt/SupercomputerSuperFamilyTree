#!/bin/bash
#PBS -lnodes=1:ppn=8,walltime=10:00:00
#PBS -q hotel

source ${SFT_BIN}/SETTINGS.sh

cd $PBS_O_WORKDIR
(cd fitchIn; ${SFT_BIN}/splitinfiles.bash ../supertreeOut/*)

cd fitchOut

touch outfile
touch outtree

ls ../fitchIn/infile* | parallel -j ${PBS_NUM_PPN} ${SFT_BIN}/single_fitch.bash 

cd $PBS_O_WORKDIR 
mkdir -p consensus
cat fitchOut/outtree* > consensus/intree

cd consensus
consense << EOF
y
EOF
