#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=1,walltime=10:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'10'}
export SEED=${SEED-'89'}

cd faaOut
~/SFT/bin/supertree.pl -n ${NUM_TREES} -t supertree${SUBJOB} -o infile${SUBJOB}

