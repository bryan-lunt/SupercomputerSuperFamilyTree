#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=16,walltime=10:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'100'}
export INPUTSEQFILE=${INPUTSEQFILE-'inputfile.faa'}

set -e
${SFT_BIN}/getNcbiSeq.pl -i ${INPUTSEQFILE} -N ${PBS_NUM_PPN}
exit $?
