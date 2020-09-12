# pggb

## the pangenome graph builder

This pangenome graph construction pipeline renders a collection of sequences into a pangenome graph (in the variation graph model).
Its goal is to build a graph that 

It uses three phases:

1. _[edyeet](https://github.com/ekg/edyeet)_: A probabilistic mash-map and edit-distance based mapper is used to scaffold the pangenome, using genome segments of a given length with a specified maximum level of sequence divergence.
All segments in the input are mapped to all others.
This step yields alignments represented in PAF, with cigars describing their base-exact alignment.

2. _[seqwish](https://github.com/ekg/seqwish)_: The pangenome graph is induced from the alignments.
The induction process implicitly builds the [alignment graph](https://doi.org/10.1186/1471-2105-15-99) in a memory-efficient disk-backed implicit interval tree.
It then computes the transitive closure of the bases in the input sequences through the alignments.
By tracing the paths of the input sequences through the graph, it produces a variation graph, which it emits in the restricted subset of GFAv1 used by variation-graph-based tools.

3. _[smoothxg](https://github.com/ekg/smoothxg)_: The graph is then sorted with a form of multi-dimensional scaling in 1D, groomed, and topologically ordered locally.
The 1D order is then broken into "blocks" which are "smoothed" using the [spoa](https://github.com/rvaser/spoa) partial order alignment algorithm.
This normalizes their mutual alignment and remove artifacts of the edit-distance based alignment.
It ensures that the graph always has local partial order, which is essential for many applications and matches our prior expectations about small-scale variation in genomes.
This step yields a rebuilt graph, a consensus subgraph, and a whole genome alignment in MAF format.

## parameters



## usage


The resulting graph can then be manipulated with odgi for visualization and interrogation.

It can also be loaded into any of the GFA-based mapping tools, including vg map, mpmap, giraffe, and GraphAligner.

Alignments to the graph can be used to make variant calls (vg call) and coverage vectors over the pangenome, which can be useful for phylogeny and association analyses.

## scalability

`pggb`'s initial use is as a mechanism to generate variation graphs from the contig sets produced by the human pangenome project.
Although its design represents efforts to scale these approaches to collections of many human genomes, it is not intended to be human-specific.

