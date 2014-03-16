#/bin/bash

INFILE=$1
OUTFILE=$(dirname ${INFILE})/groups.txt

cat ${INFILE} | awk  '/^>/ { sub(/^>/,"", $1); BAZ=$1; BAZ=gensub(/(.?\..?\..?\..?)(.*)/,"\\1","1",BAZ);    print $1, BAZ;}' > ${OUTFILE}
