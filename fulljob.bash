#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=8,walltime=10:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'100'}
export SEED=${SEED-'89'}



~/SFT/bin/getNcbiSeq.pl -i inputfile.faa -N 8
cd faaOut
~/SFT/bin/supertree.pl
fitch << EOF
m
$NUM_TREES
$SEED
y
EOF

