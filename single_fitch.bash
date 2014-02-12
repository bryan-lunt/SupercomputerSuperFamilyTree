#!/bin/bash

INFILENAME=$1

JOBID=$(echo ${INFILENAME} | sed 's/[^0-9]*//g')

export SEED=$(( 1 + ${JOBID}*2 ))

fitch << EOF
${INFILENAME}
F
outfile${JOBID}
j
$SEED
1
y
F
outtree${JOBID}
EOF
