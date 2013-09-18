#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=1,walltime=20:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'10'}
export SEED=${SEED-'89'}
export SEED=$(( ${SEED} + ${PBS_ARRAYID}*2 ))


cd faaOut

fitch > fitch_stdout.${PBS_ARRAYID} 2> fitch_stderr.${PBS_ARRAYID} << EOF
infile${PBS_ARRAYID}
F
outfile${PBS_ARRAYID}
m
$NUM_TREES
$SEED
y
F
outtree${PBS_ARRAYID}
EOF
