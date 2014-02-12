#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=1,walltime=50:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'10'}
export SEED=${SEED-'89'}
export TMPDIR=${TMPDIR-'/tmp'}
export SUBJOB=${SUBJOB-"${PBS_ARRAYID}"}

~/SFT/bin/supertree.pl -i faaOut -n ${NUM_TREES} -t ${TMPDIR}/supertree${SUBJOB} -o supertreeOut/infile${SUBJOB}

