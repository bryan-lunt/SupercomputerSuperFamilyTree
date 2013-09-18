#!/bin/bash

cd $PBS_O_WORKDIR

parallel --colsep " " ./single_fitch.bash < ${JOBFILE}

