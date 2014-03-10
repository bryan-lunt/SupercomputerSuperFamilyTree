export SFT_BLASTDB=${SFT_BLASTDB-'/home/blunt/bio/ncbi/db/nr'}
export NUM_TREES=${NUM_TREES-'100'}

#The number of CPUS per node, especially important if you are not running under PBS
export SINGLE_NODE_NUM_CPUS='8'


#Don't edit anything below this
export PBS_NUM_PPN=${PBS_NUM_PPN-"${SINGLE_NODE_NUM_CPUS}"}
