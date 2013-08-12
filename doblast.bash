#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=16,walltime=10:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'100'}
export SEED=${SEED-'89'}



~/SFT/bin/getNcbiSeq.pl -i inputfile.faa -N 16
