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

## usage

`pggb` requires at least an input sequence `-i`, a segment length `-s`, a mapping identity minimum `-p`, and an alignment identity minimum `-a`.
Other parameters may help in specific instances to shape the alignment set.

Using a test from the `data/HLA` directory in this repo:

```sh
pggb -i B-3106.fa.gz -s 1000 -K 11 -p 70 -a 70 -n 10 -t 16 -w 10000 -v -l
```

This yields a variation graph in GFA format and several diagnostic images.
By default, it is named according to the input file and the construction parameters.
Adding `-v` and `-l` render 1D and 2D diagnostic images of the graph.

## downstream

The resulting graph can then be manipulated with odgi for visualization and interrogation.
It can also be loaded into any of the GFA-based mapping tools, including vg map, mpmap, giraffe, and GraphAligner.
Alignments to the graph can be used to make variant calls (vg call) and coverage vectors over the pangenome, which can be useful for phylogeny and association analyses.
Using `odgi matrix`, we can render the graph in a sparse matrix format suitable for direct use in a variety of statistical frameworks, including phylogenetic tree construction, PCA, or association studies.

## scalability

`pggb`'s initial use is as a mechanism to generate variation graphs from the contig sets produced by the human pangenome project.
Although its design represents efforts to scale these approaches to collections of many human genomes, it is not intended to be human-specific.

## principles

It's straightforward to generate a pangenome graph by the all-pairs alignment of a set of input sequences.
This can scale poorly, but it has ideal sensitivity.
The mashmap/edlib alignment algorithm in edyeet is a very fast way to generate alignments between the sequences.
Crucially, it is robust to repetitive sequences (the initial mash mapping step is linear in the space of the genome irrespective of its sequence context), and it can be adjusted using probabilistic thresholds for segment alignment identity.
This allows us to define the base graph structure using a few free parameters: we consider the best-n candidate alignments for each N-bp segment, where the alignmentss must have at least a given identity threshold.

Although the edlib-based alignments can break down in the case of large indels, yielding ambiguous and difficult-to-interpret alignments, we do not use them directly in the graph construction.
Preventing the graph to close through matches less than `-k, --min-match-len` bp prevents us from using these in the graph.
In effect, this filter to the input to seqwish forces structural variations and regions of very low identity to be represented as bubbles.
This reduces the local topological complexity of the graph at the cost of increasing its redundancy.

The manifold nature of typical variation graphs means that they are very likely to look linear locally.
By running a stochastic 1D layout algorithm that attempts to match graph distances (as given by paths) between nodes and their distances in the layout, we execute a kind of multi-dimensional scaling (MDS).
In the aggregate, we see that regions that are linear (the chains of nodes and bubbles) in the graph tend to co-localize in the 1D sort.
Applying an MSA algorithm (in this case, spoa) to each of these chunks enforces a local linearity and homogenizes the alignment representation.
This smoothing step thus yields a graph that is locally as we expect: partially ordered, and linear as the base DNA molecules are, but globally can represent large structural variation.
The homogenization also rectifies issues with the initial edit-distance-based alignment.

## license

MIT
