#!/bin/bash

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT_ABS_PATH=$(readlink -f $0)
# Absolute path to the directory this script is in. /home/user/bin
SCRIPT_ABS_DIR=$(dirname $SCRIPT_ABS_PATH)

lines=$(wc -l $1 | awk '{print $1;}')

export JOBFILE=$1

qsub -lnodes=1:ppn=${lines} -q hotel -V ${SCRIPT_ABS_DIR}/multi_fitch.bash

