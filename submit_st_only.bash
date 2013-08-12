#!/bin/bash

export NUM_TREES=1

ALLJOBS=""
for SUBJOB in $(seq 61 67)
do
	export SUBJOB
	ALLJOBS+=":"
	ALLJOBS+=$(qsub -lwalltime=5:00:00 -V ~/SFT/bin/supertree.bash)

done

export NUM_TREES=100

qsub -W "depend=afterok${ALLJOBS}" -V ~/SFT/bin/dofitch.bash
