SupercomputerSuperFamilyTree
============================

The Super Family Tree programs from the Saier Lab, fixed and setup to run on PBS based supercomputers.

This protocol was originally described in the papers:

http://dx.doi.org/10.1007%2F978-1-60761-700-6_3
and
http://dx.doi.org/10.1159/000334611

Those programs relied on the now-defunct NCBI BLAST web-service. (getNcbiSeq.pl)
To maintain scientific compatibility with previous versions of SFT, this version uses a local installation of BLAST, rather than moving to one of the new services.


License
=======

The original files "getNcbiSeq.pl" and "supertree.pl" were downloaded from: http://www.tcdb.org/labsoftware.php .

They appear to be provided with no license, but as downloading is encouraged, this is assumed to be "fair use."

Modifications to these scripts, and the rest of the code in this project are licensed under the GNU GPL version 3.
This license is provided in the flie "gpl-3.0.txt", or can be downloaded from http://www.gnu.org/licenses/gpl-3.0.txt


(No) Scientific Endorsement by Updating Author
---------------------------------------------
In addition to the above license, governing the software itself, the developers of this version disavow any responsibility for the scientific outcomes of running these programs, including but not limited to:
* Incorrect results
* Becoming a scientific laughing-stock
* Being black-balled from scientific conferences
* End of bio-* career
* Death or Dismemberment


Requirements
============

These scripts expect to be in a PBS based batch environment.
You will have to alter things like the queue and requested resources to suit your installation.

These programs and scripts require the following:

* PERL (Probably with Bio-Perl)
* gnu parallel
* PHYLIP : http://evolution.gs.washington.edu/phylip/download/phylip-3.695.tar.gz
* ncbi BLAST : ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/LATEST/blast-2.2.26-x64-linux.tar.gz
* ncbi nr database for BLAST : ftp://ftp.ncbi.nih.gov/blast/db/FASTA/nr.gz

