#!/bin/bash
#PBS -q hotel
#PBS -lnodes=1:ppn=16,walltime=10:00:00

source ${SFT_BIN}/SETTINGS.sh

cd $PBS_O_WORKDIR

export NUM_TREES=${NUM_TREES-'100'}
export INPUTSEQFILE=${INPUTSEQFILE-'inputfile.faa'}


#Rename sequences so that they have names short enough to be accepted by PHYLIP.
awk 'START {id=0;} /^>/ {id++; print ">seq_"id,$1 >"rename.txt"; print ">seq_"id; } !/^>/ {print $0; }' ${INPUTSEQFILE} > blast_input.faa
#Creates a file "rename.txt", we will need this to rename the sequences back at the end


set -e
${SFT_BIN}/getNcbiSeq.pl -d ${SFT_BLASTDB} -i blast_input.faa -N ${PBS_NUM_PPN}
exit $?
