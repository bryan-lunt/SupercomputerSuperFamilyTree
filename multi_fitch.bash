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

cd $PBS_O_WORKDIR

#name the sequences back in the tree.
sed 's/>//g ; s/\./\\./g' rename.txt | awk '{print "s/"$1":/"$2":/g";}' > rename.sed
sed -f rename.sed consensus/outtree > FINAL_CONSENSUS_TREE.newick
