#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=1,walltime=50:00:00

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'10'}
export SUBJOB=${PBS_ARRAYID}
export TMPDIR=${TMPDIR-'/tmp'}/supertree${SUBJOB}
mkdir -p $TMPDIR

echo "SUBJOB ${SUBJOB} doing ${NUM_TREES} Trees"

cd faaOut

${SFT_BIN}/supertree.pl -n ${NUM_TREES} -t ${TMPDIR} -o ../supertreeOut/infile${SUBJOB}

