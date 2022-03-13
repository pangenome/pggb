# pggb

![Publish container to github container registry](https://github.com/pangenome/pggb/workflows/Publish%20container%20to%20github%20container%20registry/badge.svg)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](https://anaconda.org/bioconda/pggb)

## the pangenome graph builder

This pangenome graph construction pipeline renders a collection of sequences into a pangenome graph (in the variation graph model).
Its goal is to build a graph that is locally directed and acyclic while preserving large-scale variation.
Maintaining local linearity is important for the interpretation, visualization, and reuse of pangenome variation graphs.

[**WORK IN PROGRESS**] Read the full documentation at [https://pggb.readthedocs.io/](https://pggb.readthedocs.io/).


## quick start

First, [install `pggb`](https://github.com/pangenome/pggb#installation) using Docker, guix, or by manually building its dependencies.

Put your sequences in one FASTA file and index it with `samtools faidx`.
If you have many genomes, we suggest using the [PanSN prefix naming pattern](https://github.com/pangenome/PanSN-spec).

To build a graph from `input.fa`, which contains 9 haplotypes, in the directory `output`, scaffolding the graph using 5kb matches at >= 90% identity, and using 16 parallel threads for processing, execute:

```
pggb \ 
    -i input.fa \
    -o output \
    -t 16 \
    -p 90 \
    -s 5000 \
    -n 9 \
    -v
```

The final process output will be called `outdir/input.fa*smooth.gfa`.
By default, several intermediate files are produced.
We add `-v` to render 1D and 2D visualizations of the graph with `odgi`.
These are generally useful but do require some processing time, so they are not currently done by default.

## establishing parameters

### essential

`pggb` requires that the user set a mapping identity minimum `-p`, a segment length `-s`, and a number of mappings `-n` per segment.
These 3 key parameters define most of the structure of the pangenome graph.
They can be set using some prior information about the sequences that you're using.

_Estimate divergence_:
First, use `mash dist` or `mash triangle` to establish a typical level of divergence between the sequences in your input.
Convert this to an approximate percent identity and provide it as `-p, --map-pct-id PCT`.

_Define a homology scale_:
Select a segment length for the initial mapping `-s, --segment-length LENGTH`.
This will structure the alignments and the resulting graph.
In general, this should at least be larger than transposon and other common repeats in your pangenome.
A filter `-l, --block-length BLOCK` by default requires that mappings be made of at least 3 segments, or else they are filtered.

_Set a target number of alignments per segment and haplotype count_: 
The `pggb` graph is defined by the number of mappings per segment of each genome `-n, --n-mappings N`.
Ideally, you should set this to equal the number of haplotypes in the pangenome.
Keep in mind that the total work of alignment is proportional to `N*N`, and these multimappings can be highly redundant.
If you provide a `N` that is not equal to the number of haplotypes, provide the actual number of haplotypes to `-H`, which helps `smoothxg` determine the right POA problem size.

### optional

_Set a match filter_:
Graph induction with `seqwish` often works better when we filter very short matches out of the input alignments.
This underalignment is then resolved in the final `smoothxg` step.
Removing short matches can simplify the graph and remove spurious relationships caused by short repeated homologies.
The default setting of `-k 29` is optimal for around 5% divergence, and we suggest lowering it for higher divergence and increasing it for lower divergence (values up to `-k 311` work well for human haplotypes).

_Define a partial order alignment (POA) target length_:
The last step in `pggb` refines the graph by running a partial order alignment across segments.
The length of these sub-problems greatly affects the total time and memory requirements of `pggb`, and is defined by `-G, --poa-length-target N,M`.
Two passes of refinement are defined by lengths `N` and `M`.
Ideally, this target can be set above the length of transposon repeats in the pangenome, and base-level graph quality tends to improve as it is set higher.
The default setting of `-G 13117,13219` makes sense for lower-diversity pangenomes, but can require several GB of RAM per thread.
A setting like `-G 3079,3559` will be significantly faster.

Always set `-t` to the desired number of parallel threads.

## suggested settings for different organisms

Human, whole genome, 90 haplotypes: `pggb -p 98 -s 100000 -n 90 -k 311 -G 13117,13219 ...`

15 helicobacter genomes, 5% divergence: `-p 90 -s 20000 -n 15 -H 15 -k 79 -G 7919,8069 ...`, and 15 at higher (10%) divergence `pggb -p 90 -s 20000 -n 15 -k 19 -P 1,7,11,2,33,1 -G 4457,4877,5279 ...`

Yeast genomes, 5% divergence: `pggb -p 95 -s 20000 -n 7 -k 29 -G 7919,8069 ...`

Aligning 9 MHC class II assemblies from vertebrate genomes (5-10% divergence): `pggb -p 90 -s 5000 -n 9 -k 29 -G 3079,3559 ...`

## example build using MHC class II ALTs from GRCh38

Using a test from the `data/HLA` directory in this repo:

```sh
git clone --recursive https://github.com/pangenome/pggb
cd pggb
./pggb -i data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o out -M -C cons,100,1000,10000
```

This yields a variation graph in GFA format, a multiple sequence alignment in MAF format, a series of consensus graphs at different levels of variant resolution, and several diagnostic images (all in the directory `out/`).
By default, the outputs are named according to the input file and the construction parameters.
Adding `-v` render 1D and 2D diagnostic images of the graph.
(These are not enabled by default because they sometimes require manual configuration. Additionally, the 2D layout can take a while.)
By default, redundant structures in the graph are collapsed by applying [GFAffix](https://github.com/marschall-lab/GFAffix).
We also call variants with `-V` with respect to the reference `gi|568815561:#`.

### 1D graph visualization

![odgi viz rendering of DRB1-3123 graph](https://raw.githubusercontent.com/pangenome/pggb/master/data/images/DRB1-3123.fa.gz.pggb-E-s5000-l15000-p80-n10-a0-K16-k8-w50000-j5000-e5000-I0-R0-N.smooth.og.viz_mqc.png)

- The graph nodes’ are arranged from left to right forming the pangenome’s sequence.
- The colored bars represent the binned, linearized renderings of the embedded paths versus this pangenome sequence in a binary matrix.
- The black lines under the paths, so called links, represent the topology of the graph.

### 2D graph visualization

![odgi layout rendering of DRB1-3123 graph](https://raw.githubusercontent.com/pangenome/pggb/master/data/images/DRB1-3123.fa.gz.pggb-E-s5000-l15000-p80-n10-a0-K16-k8-w50000-j5000-e5000-I0-R0-N.smooth.chop.og.lay.draw_mqc.png)

- Each colored rectangle represents a node of a path. The node’s x-coordinates are on the x-axis and the y-coordinates are on the y-axis, respectively.
- A bubble indicates that here some paths have a diverging sequence or it can represent a repeat region.

### suggestions for larger pangenomes

Although it makes for a nice example, the settings for this small, highly-diverse gene in the human HLA are typically too sensitive for application to whole genomes.

In practice, we usually need to set `-s` much higher, up to 50000 or 100000 depending on context, to ensure that the resulting graphs maintain a structure reflective of the underlying homology of large regions of the genome, and not spurious matches caused by small repeats.

To ensure that we only get high-quality alignments, we might need to set `-p` higher, near the expected pairwise diversity of the sequences we're using (including structural variants in the diversity metric).
In general, increasing `-s`, and `-p` decreases runtime and memory usage.

For instance, a good setting for 10-20 genomes from the same species, with diversity from 1-5% would be `-s 100000 -p 90 -n 10`.
However, if we wanted to include genomes from another species with higher divergence (say 20%), we might use `-s 100000 -p 70 -n 10`.
The exact configuration depends on the application, and testing must be used to determine what is appropriate for a given study.

When `abpoa` digests very complex and deep blocks, it might consume a huge amount of memory. This can be addressed with `-T` to specifically control the number of threads during the POA step. This leads to a lower memory consumption.

## installation

### manual-mode

You'll need `wfmash`, `seqwish`, `smoothxg`, `odgi`, `gfaffix`, and `vg` in your shell's `PATH`.
These can be individually built and installed.
Then, put the `pggb` bash script in your path to complete installation.

### Bioconda

`pggb` recipes for Bioconda are available at https://anaconda.org/bioconda/pggb.
To install the latest version using `Conda` execute:

``` bash
conda install -c bioconda pggb
```

### guix

```
git clone https://github.com/ekg/guix-genomics
cd guix-genomics
GUIX_PACKAGE_PATH=. guix package -i pggb
```

### docker

To simplify installation and versioning, we have an automated GitHub action that pushes the current docker build to the GitHub registry.
To use it, first pull the actual image:

```sh
docker pull ghcr.io/pangenome/pggb:latest
```

Or if you want to pull a specific snapshot from [https://github.com/orgs/pangenome/packages/container/package/pggb](https://github.com/orgs/pangenome/packages/container/package/pggb):

```sh
docker pull ghcr.io/pangenome/pggb:TAG
```

Going in the `pggb` directory

```sh
git clone --recursive https://github.com/pangenome/pggb.git
cd pggb
```

you can run the container using the example [human leukocyte antigen (HLA) data](data/HLA) provided in this repo:

```sh
docker run -it -v ${PWD}/data/:/data ghcr.io/pangenome/pggb:latest "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o /data/out -M -C cons,100,1000,10000 -m"
```

The `-v` argument of `docker run` always expects a full path: `If you intended to pass a host directory, use absolute path.` This is taken care of by using `${PWD}`.

If you want to experiment around, you can build a docker image locally using the `Dockerfile`:

```sh
docker build --target binary -t ${USER}/pggb:latest .
```

Staying in the `pggb` directory, we can run `pggb` with the locally build image:

```sh
docker run -it -v ${PWD}/data/:/data ${USER}/pggb "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o /data/out -M -C cons,100,1000,10000 -m"
```

#### AVX

`abPOA` of `pggb` uses SIMD instructions which require AVX. The currently built docker image has `-march=haswell` set. This means the docker image can be run by processors that support AVX256 or later. If you have a processor that supports AVX512, it is recommended to rebuild the docker image locally, removing the line

```sh
&& sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
```

from the `Dockerfile`. This can lead to better performance in the `abPOA` step on machines which have AVX512 support.

### nextflow

A nextflow DSL2 port of `pggb` is developed by the [nf-core](https://nf-co.re/) community. See [nf-core/pangenome](https://github.com/nf-core/pangenome) for more details.


## parameter considerations

It is important to understand the key parameters of each phase and their effect on the resulting pangenome graph.
Each pangenome is different.
We may require different settings to obtain useful graphs for particular applications in different contexts.

### defining the base alignment with wfmash

Three parameters passed to `wfmash` are essential for establishing the basic structure of the pangenome:

- `-s[N], --segment-length=[N]` is the length of the mapped and aligned segment
- `-p[%], --map-pct-id=[%]` is the percentage identity minimum in the _mapping_ step
- `-n[N], --n-mappings=[N]` is the maximum number of mappings (and alignments) to report for each segment

Crucially, `--segment-length` provides a kind of minimum alignment length filter.
The mashmap step in `wfmash` will only consider segments of this size, and require them to have an approximate pairwise identity of at least `--map-pct-id`.
For small pangenome graphs, or where there are few repeats, `--segment-length` can be set low (such as 3000 in the example above).
However, for larger contexts, with repeats, it can be very important to set this high (for instance 100000 in the case of human genomes).
A long segment length ensures that we represent long collinear regions of the input sequences in the structure of the graph. As a general rule of thump, `-n` should be set to the number of haplotypes given in the input sequences. Because that's the maximum number of secondary mappings and alignments that we expect.

### generating the initial graph with seqwish

The `-k` or `--min-match-length` parameter given to `seqwish` will drop any short matches from consideration.
In practice, these often occur in regions of low alignment quality, which are typical of areas with large indels and structural variations in the `wfmash` alignments.
In effect, setting `-k` to N means that we can tolerate a local pairwise difference rate of no more than 1/N.
Thus, indels which may be represented by complex series of edit operations will be opened into [bubbles](https://doi.org/10.1089/cmb.2017.0251) in the induced graph, and alignment regions with very low identity will be ignored.
Using affine-gapped alignment (such as with _[minimap2](https://github.com/lh3/minimap2)_) may reduce the impact of this step by representing large indels more precisely in the input alignments.
However, it remains important due to local inconsistency in alignments in low-complexity sequence.

### homogenizing and ordering the graph with smoothxg

The "chunked" POA process attempts to build an MSA for each collinear region in the sorted graph.
This depends on a sorting pipeline implemented in _[odgi](https://github.com/vgteam/odgi)_.
`smoothxg` greedily extends candidate blocks until they contain `-w[N], --max-block-weight=[N]` bp of sequence in the embedded paths.
The `--max-block-weight` parameter thus determines the average size of these blocks.
We expect their length in graph space to be approximately `max-block-weight` / `average_path_depth`.
Thus, we set the `max-block-weight` to `-G, --poa-length-target` times the number of `-n, --n-mappings` or `-H, --n-haps`. It may be necessary to change this setting when the pangenome path depth (the number of genome sequences covering the average graph node) is higher or lower.
In effect, setting `--poa-length-target` and therefore `--max-block-weight` higher will make the size of the blocks given to the POA algorithm larger, and this will result in larger regions of the graph having guaranteed local partial order.
Setting it higher can greatly increase runtime, because the POA algorithm is quadratic in the length of the longest sequence and graph that it aligns, but it also tends to produce cleaner resulting graphs. \
When forming each block, `smoothxg` pads each end of the sequence in the POA step with `N*longest_poa_seq` bp. This tries to ensure that at the boundaries of blocks, we smooth, too. During our trials with the HPRC data, a default of `0.03` crystallized. But this could vary dependent on the data set.
The POA parameters will determine how well the sequence can be aligned in a block given their assumed divergence. The current default of `1,19,39,3,81,1` is for ~0.1% divergence, as suggested by `minimap2`:

| asm mode  | `--poa-params` | divergence in % |
| ------------- | ------------- | ------------- |
| asm5  | 1,19,39,3,81,1  | ~0.1 |
| asm10  | 1,9,16,2,41,1  | ~1 |
| asm20  | 1,4,6,2,26,1 | ~5 |

Other parameters to `smoothxg` help to shape the scope and boundaries of the blocks.
In particular, `-e[N], --max-edge-jump=[N]` breaks a growing block when an edge in the graph jumps more than the given distance `N` in the sort order of the graph.
This is designed to encourage blocks to stop near the boundaries of structural variation.
When a path leaves and returns to a given block, we can pull in the sequence that lies outside the block if it is less than `-j[N], --max-path-jump=[N]`.

## reporting

### MultiQC

Many thanks go to [@Zethson](https://github.com/zethson) and [@Imipenem](https://github.com/Imipenem) who started to implemented a MultiQC module for `odgi stats`. Using `-m, --multiqc` statistics are generated automatically, and summarized in a MultiQC report. If created, visualizations and layouts are integrated into the report, too. In the following an example excerpt:

![MultiQC example report](./data/images/multiqc_report.png)

#### installation

```sh
pip install multiqc --user
```

The docker image already contains v1.11 of `MultiQC`.

## example parameter settings by organism

### human

For the HPRCy1 data we currently run `pggb` with the following parameters on all chromosomes:

`pggb -i chr'$i'.pan.fa -o chr'$i'.pan -t 48 -p 98 -s 100000 -n 90 -k 311 -O 0.03 -T 48 -v -V chm13:#,grch38:# -Z`

### other organisms

If you are building graphs with `pggb` using other organisms, please report back to us. We are happy to find the best parameter settings for your experiment and help out!

## extension

The pipeline is provided as a single script with configurable command-line options.
Users should consider taking this script as a starting point for their own pangenome project.
For instance, you might consider swapping out `wfmash` with `minimap2` or another PAF-producing long-read aligner.
If the graph is small, it might also be possible to use `abPOA` or `spoa` to generate it directly.
On the other hand, maybe you're starting with an assembly overlap graph which can be converted to blunt-ended GFA using _[gimbricate](https://github.com/ekg/gimbricate)_.
You might have a validation process based on alignment of sequences to the graph, which should be added at the end of the process.

## downstream

The resulting graph can then be manipulated with `odgi` for transformation, analysis, simplification, validation, interrogation, and visualization.
It can also be loaded into any of the GFA-based mapping tools, including _[vg](https://github.com/vgteam/vg)_ `map`, `mpmap`, `giraffe`, and _[GraphAligner](https://github.com/maickrau/GraphAligner)_.
Alignments to the graph can be used to make variant calls (`vg call`) and coverage vectors over the pangenome, which can be useful for phylogeny and association analyses.
Using `odgi matrix`, we can render the graph in a sparse matrix format suitable for direct use in a variety of statistical frameworks, including phylogenetic tree construction, PCA, or association studies.

## scalability

`pggb`'s initial use is as a mechanism to generate variation graphs from the contig sets produced by the human pangenome project.
Although its design represents efforts to scale these approaches to collections of many human genomes, it is not intended to be human-specific.

## principles

It's straightforward to generate a pangenome graph by the all-pairs alignment of a set of input sequences.
This can scale poorly, but it has ideal sensitivity.
The mashmap/wfa alignment algorithm in `wfmash` is a very fast way to generate alignments between the sequences.
Crucially, it is robust to repetitive sequences (the initial mash mapping step is linear in the space of the genome 
irrespective of its sequence context), and it can be adjusted using probabilistic thresholds for segment alignment identity.
This allows us to define the base graph structure using a few free parameters: we consider the best-n candidate alignments
for each N-bp segment, where the alignments must have at least a given identity threshold.

The wfa-based alignments can break down in the case of large indels, yielding ambiguous and difficult-to-interpret alignments.
But, we should not use such regions of the alignments directly in the graph construction, as this can increase graph complexity.
We ignore such regions by preventing `seqwish` from closing the graph through matches less than `-k, --min-match-len` bp.
In effect, this filter to the input to `seqwish` forces structural variations and regions of very low identity to be 
represented as bubbles. This reduces the local topological complexity of the graph at the cost of increasing its redundancy.

The manifold nature of typical variation graphs means that they are very likely to look linear locally.
By running a stochastic 1D layout algorithm that attempts to match graph distances (as given by paths) between nodes and 
their distances in the layout, we execute a kind of multi-dimensional scaling (MDS). In the aggregate, we see that 
regions that are linear (the chains of nodes and bubbles) in the graph tend to co-localize in the 1D sort.
Applying an MSA algorithm (in this case, `abPOA` or `spoa`) to each of these chunks enforces a local linearity and 
homogenizes the alignment representation. This smoothing step thus yields a graph that is locally as we expect: partially
ordered, and linear as the base DNA molecules are, but globally can represent large structural variation. The homogenization
also rectifies issues with the initial wfa-based alignment.

## authors

Erik Garrison,
Simon Heumos,
Andrea Guarracino,
Yan Gao

## license

MIT
