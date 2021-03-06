#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT_ABS_PATH=$(readlink -f ${0})
# Absolute path to the directory this script is in. /home/user/bin
SCRIPT_ABS_DIR=$(dirname ${SCRIPT_ABS_PATH})

export SFT_BIN=${SCRIPT_ABS_DIR}

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
BLASTJOB=$(qsub -v INPUTSEQFILE,SFT_BIN ${SFT_BIN}/doblast.bash)

SUPERTREEJOBS=$(qsub -t 1-10 -W "depend=afterok:${BLASTJOB}" -v SFT_BIN -V ${SFT_BIN}/supertree.bash)

qsub -W "depend=afterokarray:${SUPERTREEJOBS}" -v SFT_BIN ${SFT_BIN}/multi_fitch.bash
