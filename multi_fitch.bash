#!/bin/bash
#PBS -lnodes=1:ppn=8,walltime=10:00:00
#PBS -q hotel


cd $PBS_O_WORKDIR
(cd fitchIn; ~/SFT/bin/splitinfiles.bash ../supertreeOut/*)

cd fitchOut

touch outfile
touch outtree

ls ../fitchIn/infile* | parallel -j ${PBS_NUM_PPN} ~/SFT/bin/single_fitch.bash 
