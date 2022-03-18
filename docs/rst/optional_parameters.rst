.. _optional_parameters:

###################
Optional Parameters
###################

.. toctree::
    :maxdepth: 1

Set a match filter: Graph induction with seqwish often works better when we filter very short matches out of the input alignments. 
This underalignment is then resolved in the final smoothxg step. Removing short matches can simplify the graph and remove spurious 
relationships caused by short repeated homologies. The default setting of -k 29 is optimal for around 5% divergence, and we suggest 
lowering it for higher divergence and increasing it for lower divergence (values up to -k 311 work well for human haplotypes).

Define a partial order alignment (POA) target length: The last step in pggb refines the graph by running a partial order alignment 
across segments. The length of these sub-problems greatly affects the total time and memory requirements of pggb, and is defined 
by -G, --poa-length-target N,M. Two passes of refinement are defined by lengths N and M. Ideally, this target can be set above the length 
of transposon repeats in the pangenome, and base-level graph quality tends to improve as it is set higher. The default setting of 
-G 13117,13219 makes sense for lower-diversity pangenomes, but can require several GB of RAM per thread. A setting like -G 3079,3559 will be significantly faster.

Always set -t to the desired number of parallel threads.