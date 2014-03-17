Running The Program
===================

There are two protocols embodied in these programs: "SFT1" and "SFT2" (following the naming convention of the original authors).

These both take a FASTA format file containing UNaligned sequences as intput.

SFT1 builds a phylogenetic tree with a leaf representing each sequence int the input file.
SFT2 builds a phylogenetic tree where each leaf represents a group of sequences in the input file.

The steps for both are similar, and you must understand how to run SFT1 before you can understand SFT2.


SFT1
====

- Create a directory to contain the output of your run.
- Copy your intput file there. (Use a descriptive name, avoid "blast_input.faa")
- cd to that directory
- type: /whereverer/you/installed/SSFT/submit.bash INPUTFILE.faa
	(Where INPUTFILE.faa is the path to your input file.)

The scripts will submit all necessary jobs with an appropriate dependency graph.

When the job is finished, the final consensus tree will be stored a the top level of the containment directory,
in a file named "FINAL_CONSENSUS_TREE.newick"

SFT2
====

The implementation of SFT2 is totally general. You can group any sequences into any groups you like. (But each sequence must belong to one and only one group.)
This is accomplished by creating a file "groups.txt" that lists which group each sequence falls into.

For TCDB family-level SFT2, a conveninence script is provided to automatically generate "groups.txt" .

To use custom groups, see the section titled "GROUPING" .

To use the simple generator:

- Create a directory to contain the output of your run. 
- Copy your intput file there. (Use a descriptive name, avoid "blast_input.faa")
- cd to that directory
- type: /whereverer/you/installed/SSFT/simple_groupgen.bash INPUTFILE.faa
- type: /whereverer/you/installed/SSFT/submit.bash INPUTFILE.faa
        (Where INPUTFILE.faa is the path to your input file.)


Leaves will be named after the groups.

GROUPING
========

To create custom groups, in the directory that you will run SFT in, you must create a file named "groups.txt" that lists group membership.
Each line of this file has the following format:

<sequence name> <group name>

For example:

myFirstSequenceWithAnArbitrarilyLongName myFirstGroup
mySecondSequence myFirstGroup
sequence_3 group2


Will produce two groups; "myFirstGroup" and "group2", with two sequences in the former, and one in the latter.

By putting a custom "groups.txt" file in place, instead of using "simple_groupgen.bash", you can run SFT2 with any arbitrary grouping.
