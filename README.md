SupercomputerSuperFamilyTree
============================

The Super Family Tree programs from the Saier Lab, fixed and setup to run on PBS based supercomputers.


These scripts expect to be in a PBS based batch environment.
You will have to alter things like the queue and requested resources to suit your installation.

These programs and scripts require the following:

* PERL (Probably with Bio-Perl)
* gnu parallel
* PHYLIP
* ncbi BLAST

The modified getNcbiSeq.pl program needs to know where your BLAST nr database is installed, so you may have to alter doblast.bash

