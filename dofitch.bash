#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=1,walltime=10:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'100'}
export SEED=${SEED-'89'}



cd faaOut

rm infile_temporary

for i in infile*
do
	cat $i >> infile_temporary
done
mv infile_temporary infile
rm outfile

fitch << EOF
m
$NUM_TREES
$SEED
y
EOF

#consense << EOF
#outtree
#F
#consensus.txt
#y
#F
#consensus.newick
#EOF
