#!/bin/bash

lines=$(wc -l $1 | awk '{print $1;}')

export JOBFILE=$1

qsub -lnodes=1:ppn=${lines} -q hotel -V multi_fitch.bash

