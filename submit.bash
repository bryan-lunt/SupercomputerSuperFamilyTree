#!/bin/bash

export INPUTSEQFILE=${1}

if [ ! -s ${INPUTSEQFILE} ]
then
	echo "No such input file: ${INPUTSEQFILE}"
	exit 1
fi

#Begin Submitting Jobs
BLASTJOB=$(qsub -v INPUTSEQFILE ~/SFT/bin/doblast.bash)

SUPERTREEJOBS=$(qsub -t 1-10 -W "depend=afterok:${BLASTJOB}" -V ~/SFT/bin/supertree.bash)

qsub -W "depend=afterok:${SUPERTREEJOBS}" ~/SFT/bin/dofitch.bash
