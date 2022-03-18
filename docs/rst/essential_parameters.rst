.. _essential_parameters:

####################
Essential Parameters
####################

.. toctree::
    :maxdepth: 1

essential

pggb requires that the user set a mapping identity minimum -p, a segment length -s, and a number of mappings -n per segment. 
These 3 key parameters define most of the structure of the pangenome graph. They can be set using some prior information about the sequences that you're using.

Estimate divergence: First, use mash dist or mash triangle to establish a typical level of divergence between the sequences in your input. 
Convert this to an approximate percent identity and provide it as -p, --map-pct-id PCT.

Define a homology scale: Select a segment length for the initial mapping -s, --segment-length LENGTH. This will structure the alignments 
and the resulting graph. In general, this should at least be larger than transposon and other common repeats in your pangenome. 
A filter -l, --block-length BLOCK by default requires that mappings be made of at least 3 segments, or else they are filtered.

Set a target number of alignments per segment and haplotype count: The pggb graph is defined by the number of mappings per segment 
of each genome -n, --n-mappings N. Ideally, you should set this to equal the number of haplotypes in the pangenome. 
Keep in mind that the total work of alignment is proportional to N*N, and these multimappings can be highly redundant. 
If you provide a N that is not equal to the number of haplotypes, provide the actual number of haplotypes to -H, which helps 
smoothxg determine the right POA problem size.

Always set -t to the desired number of parallel threads.