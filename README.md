SupercomputerSuperFamilyTree
============================

The Super Family Tree programs from the Saier Lab, fixed and setup to run on PBS based supercomputers.

I DO NOT ENDORSE THIS PROGRAM SCIENTIFICALLY.
============================================


These scripts expect to be in a PBS based batch environment.
You will have to alter things like the queue and requested resources to suit your installation.

These programs and scripts require the following:

* PERL (Probably with Bio-Perl)
* gnu parallel
* PHYLIP : http://evolution.gs.washington.edu/phylip/download/phylip-3.695.tar.gz
* ncbi BLAST : ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/LATEST/blast-2.2.26-x64-linux.tar.gz
* ncbi nr database for BLAST : ftp://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz

The modified getNcbiSeq.pl program needs to know where your BLAST nr database is installed, so you may have to alter doblast.bash

