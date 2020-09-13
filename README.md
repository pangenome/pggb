# pggb

## the pangenome graph builder

This pangenome graph construction pipeline renders a collection of sequences into a pangenome graph (in the variation graph model).
Its goal is to build a graph that is locally directed and acyclic while preserving large-scale variation.
Maintaining local linearity is important for the interpretation, visualization, and reuse of pangenome variation graphs.

It uses three phases:

1. _[edyeet](https://github.com/ekg/edyeet)_: (*alignment*) -- A probabilistic mash-map and edit-distance based mapper is used to scaffold the pangenome, using genome segments of a given length with a specified maximum level of sequence divergence.
All segments in the input are mapped to all others.
This step yields alignments represented in PAF, with cigars describing their base-exact alignment.

2. _[seqwish](https://github.com/ekg/seqwish)_: (*graph induction*) -- The pangenome graph is induced from the alignments.
The induction process implicitly builds the [alignment graph](https://doi.org/10.1186/1471-2105-15-99) in a memory-efficient disk-backed implicit interval tree.
It then computes the transitive closure of the bases in the input sequences through the alignments.
By tracing the paths of the input sequences through the graph, it produces a variation graph, which it emits in the restricted subset of GFAv1 used by variation-graph-based tools.

3. _[smoothxg](https://github.com/ekg/smoothxg)_: (*normalization*) -- The graph is then sorted with a form of multi-dimensional scaling in 1D, groomed, and topologically ordered locally.
The 1D order is then broken into "blocks" which are "smoothed" using the [spoa](https://github.com/rvaser/spoa) partial order alignment algorithm.
This normalizes their mutual alignment and remove artifacts of the edit-distance based alignment.
It ensures that the graph always has local partial order, which is essential for many applications and matches our prior expectations about small-scale variation in genomes.
This step yields a rebuilt graph, a consensus subgraph, and a whole genome alignment in MAF format.

Optional post-processing steps provide 1D and 2D diagnostic visualizations of the graph.

## usage

`pggb` requires at least an input sequence `-i`, a segment length `-s`, a mapping identity minimum `-p`, and an alignment identity minimum `-a`.
Other parameters may help in specific instances to shape the alignment set.

Using a test from the `data/HLA` directory in this repo:

```sh
pggb -i DRB1-3123.fa.gz -s 3000 -K 11 -p 70 -a 70 -n 10 -t 16 -v -l
```

This yields a variation graph in GFA format and several diagnostic images.
By default, it is named according to the input file and the construction parameters.
Adding `-v` and `-l` render 1D and 2D diagnostic images of the graph.

![odgi viz rendering of DRB1-3123 graph](https://raw.githubusercontent.com/pangenome/pggb/master/data/images/DRB1-3123.fa.gz.pggb-s3000-p70-n10-a70-K11-k8-w10000-j5000-W0-e100.smooth.og.viz.png)

![odgi layout rendering of DRB1-3123 graph](https://raw.githubusercontent.com/pangenome/pggb/master/data/images/DRB1-3123.fa.gz.pggb-s3000-p70-n10-a70-K11-k8-w10000-j5000-W0-e100.smooth.chop.og.lay.png)

## considerations

It is important to understand the key parameters of each phase and their affect on the resulting pangenome graph.
Each pangenome is different.
We may require different settings to obtain useful graphs for particular applications in different contexts.

### defining the base alignment with edyeet

Four parameters passed to `edyeet` are essential for establishing the basic structure of the pangenome:

* `-s[N], --segment-length=[N]` is the length of the mapped and aligned segment
* `-p[%], --map-pct-id=[%]` is the percentage identity minimum in the _mapping_ step
* `-n[N], --n-secondary=[N]` is the maximum number of mappings (and alignments) to report for each segment
* `-a[%], --align-pct-id=[%]` defines the minimum percentage identity allowed in the _alignment_ step

Crucially, `--segment-length` provides a kind of minimum alignment length filter.
The mashmap step in `edyeet` will only consider segments of this size, and require them to have an approximate pairwise identity of at least `--map-pct-id`.
For small pangenome graphs, or where there are few repeats, `--segment-length` can be set low (such as 1000 in the example above).
However, for larger contexts, with repeats, it can be very important to set this high (for instance 100000 in the case of human genomes).
A long segment length ensures that we represent long collinear regions of the input sequences in the structure of the graph.
Setting `--align-pct-id` near or below `--map-pct-id` ensures that we can derive a base-level alignment for the typical mapping.
However, setting it very low with a long `--segment-length` may result in long runtimes due to the quadratic costs of alignment.

### generating the initial graph with seqwish

The `-k` or `--min-match-length` parameter given to `seqwish` will drop any short matches from consideration.
In practice, these often occur in regions of low alignment quality, which are typical of areas with large indels and structural variation in the `edyeet` alignments.
In effect, setting `-k` to N means that we can tolerate a local pairwise difference rate of no more than 1/N.
Thus, indels which may be represented by complex series of edit operations will be opened into bubbles in the induced graph, and alignment regions with very low identity will be ignored.
Using affine-gapped alignment (such as with `minimap2`) may reduce the impact of this step by representing large indels more precisely in the input alignments.
However, it remains important due to local inconsistency in alignments in low-complexity sequence.

### homogenizing and ordering the graph with smoothxg

The "chunked" POA process attempts to build an MSA for each collinear region in the sorted graph.
This depends on a sorting pipeline implemented in `odgi`.
`smoothxg` greedily extends candidate blocks until they contain `-w[N], --max-block-weight=[N]` bp of sequence in the embedded paths.
The `--max-block-weight` parameter thus determines the average size of these blocks.
We expect their length in graph space to be approximately `max-block-weight` / `average_path_depth`.
Thus, it may be necessary to change this setting when the pangenome path depth (the number of genome sequences covering the average graph node) is higher or lower.
In effect, setting `--max-block-weight` higher will make the size of the blocks given to `spoa` larger, and this will result in larger regions of the graph having guaranteed local partial order.
Setting it higher can greatly increase runtime, beacuse `spoa` is quadratic in the length of the longest sequence and graph that it aligns, but it also tends to produce cleaner resulting graphs.

Other parameters to `smoothxg` help to shape the scope and boundaries of the blocks.
In particular, `-e[N], --max-edge-jump=[N]` breaks a growing block when an edge in the graph jumps more than the given distance `N` in the sort order of the graph.
This is designed to encourage spoa blocks to stop near the boundaries of structural variation.
When a path leaves and returns to a given block, we can pull in the sequence that lies outside the block if it is less than `-j[N], --max-path-jump=[N]`.
Paths that only travers a given block for `-W[N], --min-subpath=[N]` bp are removed from the block.

## extension

The pipeline is provided as a single script with configurable command-line options.
Users should consider taking this script as a starting point for their own pangenome project.
For instance, you might consider swapping out `edyeet` with `minimap2` or another PAF-producing long-read aligner.
If the graph is small, it might also be possible to use `spoa` to generate it directly.
On the other hand, maybe you're starting with an assembly overlap graph which can be converted to blunt-ended GFA using gimbricate.
You might have a validation process based on alignment of sequences to the graph, which should be added at the end of the process.

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
This allows us to define the base graph structure using a few free parameters: we consider the best-n candidate alignments for each N-bp segment, where the alignments must have at least a given identity threshold.

The edlib-based alignments can break down in the case of large indels, yielding ambiguous and difficult-to-interpret alignments.
But, we should not use such regions of the alignments directly in the graph construction, as this can increase graph complexity.
We ignore such regions by preventing `seqwish` from closing the graph through matches less than `-k, --min-match-len` bp.
In effect, this filter to the input to seqwish forces structural variations and regions of very low identity to be represented as bubbles.
This reduces the local topological complexity of the graph at the cost of increasing its redundancy.

The manifold nature of typical variation graphs means that they are very likely to look linear locally.
By running a stochastic 1D layout algorithm that attempts to match graph distances (as given by paths) between nodes and their distances in the layout, we execute a kind of multi-dimensional scaling (MDS).
In the aggregate, we see that regions that are linear (the chains of nodes and bubbles) in the graph tend to co-localize in the 1D sort.
Applying an MSA algorithm (in this case, spoa) to each of these chunks enforces a local linearity and homogenizes the alignment representation.
This smoothing step thus yields a graph that is locally as we expect: partially ordered, and linear as the base DNA molecules are, but globally can represent large structural variation.
The homogenization also rectifies issues with the initial edit-distance-based alignment.

## authors

Erik Garrison

## license

MIT
