<img src="https://raw.githubusercontent.com/pangenome/pggb/master/data/images/PGGB_logo_a34ab696.text.png" height=50% width=50% alt="PanGenome Graph Builder">

![Publish container to github container registry](https://github.com/pangenome/pggb/workflows/Publish%20container%20to%20github%20container%20registry/badge.svg)
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](https://anaconda.org/bioconda/pggb)

# pggb

## the PanGenome Graph Builder

This pangenome graph construction pipeline renders a collection of sequences into a pangenome graph (in the variation graph model).
Its goal is to build a graph that is locally directed and acyclic while preserving large-scale variation.
Maintaining local linearity is important for the interpretation, visualization, and reuse of the pangenome graphs.

[**WORK IN PROGRESS**] Read the full documentation at [https://pggb.readthedocs.io/](https://pggb.readthedocs.io/).


## quick start

First, [install `pggb`](https://github.com/pangenome/pggb#installation) using Docker, `guix`, or by manually building its dependencies.

Put your sequences in one FASTA file and index it with `samtools faidx`.
If you have many genomes, we recommend using the [PanSN prefix naming pattern](https://github.com/pangenome/PanSN-spec).

To build a graph from `input.fa`, which contains 9 haplotypes, in the directory `output`, scaffolding the graph using 10kb matches at >= 90% identity, and using 16 parallel threads for processing, execute:

```
pggb \
    -i input.fa \
    -o output \
    -t 16 \
    -p 90 \
    -s 10000 \
    -n 9 \
    -v
```

The final output will be called `outdir/input.fa*smooth.gfa`.
By default, several intermediate files are produced.
We render 1D and 2D visualizations of the graph with `odgi`, which are very useful to understand the result of the build.

See also [this step-by-step example](https://pggb.readthedocs.io/en/latest/rst/quick_start.html) for more information.


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
./pggb -i data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o out -M
```

[comment]: <> (a series of consensus graphs at different levels of variant resolution)
This yields a variation graph in GFA format, a multiple sequence alignment in MAF format, and several diagnostic images (all in the directory `out/`).
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

### docker / Singularity

To simplify installation and versioning, we have an automated GitHub action that pushes the current docker build to the GitHub registry.
To use it, first pull the actual image:

```sh
docker pull ghcr.io/pangenome/pggb:latest
```

Or if you want to pull a specific snapshot from [https://github.com/orgs/pangenome/packages/container/package/pggb](https://github.com/orgs/pangenome/packages/container/package/pggb):

```sh
docker pull ghcr.io/pangenome/pggb:TAG
```

You can pull the docker image also from [dockerhub](https://hub.docker.com/r/pangenome/pggb):

```shell
docker pull pangenome/pggb
```

Going in the `pggb` directory

```sh
git clone --recursive https://github.com/pangenome/pggb.git
cd pggb
```

you can run the container using the example [human leukocyte antigen (HLA) data](data/HLA) provided in this repo:

```sh
docker run -it -v ${PWD}/data/:/data ghcr.io/pangenome/pggb:latest "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o /data/out -M -m"
```

The `-v` argument of `docker run` always expects a full path: `If you intended to pass a host directory, use absolute path.` This is taken care of by using `${PWD}`.

If you want to experiment around, you can build a docker image locally using the `Dockerfile`:

```sh
docker build --target binary -t ${USER}/pggb:latest .
```

Staying in the `pggb` directory, we can run `pggb` with the locally build image:

```sh
docker run -it -v ${PWD}/data/:/data ${USER}/pggb "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o /data/out -M -m"
```
#### Singularity

Many managed HPCs utilize Singularity as a secure alternative to docker. Fortunately, docker images can be run through Singularity seamlessly.

First pull the docker file and create a Singularity SIF image from the dockerfile. This might take a few minutes.

```sh
singularity pull docker://ghcr.io/pangenome/pggb:latest
```

Next clone the `pggb` repo and `cd` into it

```sh
git clone --recursive https://github.com/pangenome/pggb.git
cd pggb
```

Finally, run `pggb` from the Singularity image. For Singularity to be able to read and write files to a directory on the host operating system, we need to 'bind' that directory using the `-B` option and pass the `pggb` command as an argument.

```sh
singularity run -B ${PWD}/data:/data ../pggb_latest.sif "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -v -V 'gi|568815561:#' -o /data/out -M -m"
```



#### AVX

`abPOA` of `pggb` uses SIMD instructions which require AVX. The currently built docker image has `-march=haswell` set. This means the docker image can be run by processors that support AVX256 or later. If you have a processor that supports AVX512, it is recommended to rebuild the docker image locally, removing the line

```sh
&& sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
```

from the `Dockerfile`. This can lead to better performance in the `abPOA` step on machines which have AVX512 support.

### nextflow

A nextflow DSL2 port of `pggb` is developed by the [nf-core](https://nf-co.re/) community. See [nf-core/pangenome](https://github.com/nf-core/pangenome) for more details.


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
