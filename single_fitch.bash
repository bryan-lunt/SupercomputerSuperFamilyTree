#!/bin/bash

JOBID=$1

export SEED=$(( 1 + ${JOBID}*2 ))


cd faaOut

fitch << EOF
infile${JOBID}
F
outfile${JOBID}
j
$SEED
1
y
F
outtree${JOBID}
EOF
