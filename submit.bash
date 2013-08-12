#!/bin/bash

BLASTJOB=$(qsub ~/SFT/bin/doblast.bash)

ALLJOBS=""
for SUBJOB in $(seq 10)
do
	export SUBJOB
	ALLJOBS+=":"
	ALLJOBS+=$(qsub -W "depend=afterok:${BLASTJOB}" -V ~/SFT/bin/supertree.bash)

done

qsub -W "depend=afterok${ALLJOBS}" ~/SFT/bin/dofitch.bash
