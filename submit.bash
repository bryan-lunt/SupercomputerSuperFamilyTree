#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT_ABS_PATH=$(readlink -f ${0})
# Absolute path to the directory this script is in. /home/user/bin
SCRIPT_ABS_DIR=$(dirname ${SCRIPT_ABS_PATH})

export INPUTSEQFILE=${1}

if [ ! -s ${INPUTSEQFILE} ]
then
	echo "No such input file: ${INPUTSEQFILE}"
	exit 1
fi

mkdir -p supertreeOut
mkdir -p fitchIn
mkdir -p fitchOut
touch fitchOut/outfile
touch fitchOut/outtree


#Begin Submitting Jobs
BLASTJOB=$(qsub -v INPUTSEQFILE ${SCRIPT_ABS_DIR}/doblast.bash)

SUPERTREEJOBS=$(qsub -t 1-10 -W "depend=afterok:${BLASTJOB}" -V ${SCRIPT_ABS_DIR}/supertree.bash)

qsub -W "depend=afterok:${SUPERTREEJOBS}" ${SCRIPT_ABS_DIR}/multi_fitch.bash
