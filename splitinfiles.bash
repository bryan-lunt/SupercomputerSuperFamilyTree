#!/bin/bash

awk -v n=1 '/^ *$/{close("infile"n);n++;next} {print > "infile"n}' $*
