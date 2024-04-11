.. _optional_parameters:

###################
Optional parameters
###################

.. toctree::
    :maxdepth: 1


Set a match filter
--------------------------------

Graph induction with ``seqwish`` often works better when we filter very short matches out of the input alignments.
In practice, these often occur in regions of low alignment quality, which are typical of areas with large indels and structural variations in the ``wfmash`` alignments.
This underalignment is then resolved in the final ``smoothxg step``.
Removing short matches can simplify the graph and remove spurious relationships caused by short repeated homologies.

    - ``-k[N], --min-match-len=[N]`` filter exact matches below this length during graph induction

The default setting of ``-k 23`` is optimal up to around 5% divergence, and we suggest lowering it for higher divergence and increasing it for lower divergence.
Values up to ``-k 79`` work well for human haplotypes.
In effect, setting ``-k`` to ``N`` means that we can tolerate a local pairwise difference rate of no more than ``1/N``.
Thus, indels which may be represented by complex series of edit operations will be opened into `bubbles <https://www.liebertpub.com/doi/10.1089/cmb.2017.0251>`_ in the induced graph, and alignment regions with very low identity will be ignored.
Using affine-gapped alignment (such as with `minimap2 <https://github.com/lh3/minimap2>`_) may reduce the impact of this step by representing large indels more precisely in the input alignments.
However, it remains important due to local inconsistency in alignments in low-complexity sequence.


Homogenizing and ordering the graph
--------------------------------

The last step in ``pggb`` refines the graph by running a partial order alignment (POA) across segments, so called blocks.
The "chunked" POA process attempts to build an MSA for each collinear region in the sorted graph.
This depends on a sorting pipeline implemented in ` odgi <https://github.com/pangenome/odgi>_`.

    - ``-G[%], --poa-length-target=[N,M]`` target sequence length for POA step
    - ``-P[N], --poa-params=[PARAMS]`` score parameters for POA
    - ``-O[N], --poa-padding=[N]`` padding length of each sequence in POA

The length of these sub-problems greatly affects the total time and memory requirements of ``pggb``, and is defined by ``-G, --poa-length-target N,M``.
Several passes of refinement can be defined by lengths ``N``, ``M``, and so on.
Ideally, this target can be set above the length of transposon repeats in the pangenome, and base-level graph quality tends to improve as it is set higher.
Higher ``-G`` values makes sense for lower-diversity pangenomes, but can require several GB of RAM per thread.

Other parameters to `smoothxg` help to shape the scope and boundaries of the blocks.
`smoothxg` greedily extends candidate blocks until they contain `-w[N], --max-block-weight=[N]` bp of sequence in the embedded paths.
The `--max-block-weight` parameter thus determines the average size of these blocks.
We expect their length in graph space to be approximately `max-block-weight` / `average_path_depth`.
Thus, we set the `max-block-weight` to `-G, --poa-length-target` times the number of `-n, --n-mappings` or `-H, --n-haps`.
It may be necessary to change this setting when the pangenome path depth (the number of genome sequences covering the average graph node) is higher or lower.
In effect, setting `--poa-length-target` and therefore `--max-block-weight` higher will make the size of the blocks given to the POA algorithm larger, and this will result in larger regions of the graph having guaranteed local partial order.
Setting it higher can greatly increase runtime, because the POA algorithm is quadratic in the length of the longest sequence and graph that it aligns, but it also tends to produce cleaner resulting graphs.

In particular, `-e[N], --max-edge-jump=[N]` breaks a growing block when an edge in the graph jumps more than the given distance `N` in the sort order of the graph.
This is designed to encourage blocks to stop near the boundaries of structural variation.
When a path leaves and returns to a given block, we can pull in the sequence that lies outside the block if it is less than `-j[N], --max-path-jump=[N]`.

The POA parameters will determine how well the sequence can be aligned in a block given their assumed divergence.
The current default of ``1,19,39,3,81,1`` is for ``~0.1%`` divergence, as suggested by ``minimap2``:

.. list-table:: 
   :widths: 25 25 50
   :header-rows: 1

   * - asm mode
     - ``--poa-params``
     - divergence in %
   * - asm5
     - 1,19,39,3,81,1
     - ~0.1
   * - asm10
     - 1,9,16,2,41,1
     - ~1
   * - asm20 
     - 1,4,6,2,26,1
     - ~5 

When forming each block, ``smoothxg`` pads each end of the sequence in the POA step with ``N*longest_poa_seq`` bp.
This tries to ensure that at the boundaries of blocks, we smooth, too.
During our trials with the HPRC data, a default of ``0.03`` crystallized. But this could vary dependent on the data set. 


Variant Calling
---------------

    - ``-V[SPEC], --vcf-spec[SPEC]`` specify a set of references for variant calling with ``REF[:LEN][,REF[:LEN]]*``

The paths matching ``^REF`` are used as a reference, while the sample haplotypes are derived from path names, e.g. when ``DELIM=#`` and with ``'-V chm13'``, 
a path named ``HG002#1#ctg`` would be assigned to sample HG002 phase 1. Another example can be found at :ref:`quick_start_example`.
If ``LEN`` is specified and greater than 0, the VCFs are decomposed, filtering sites whose max allele length is greater than ``LEN``.


Reporting
---------

    - ``-S, --stats`` generate graph statistics
    - ``-m, --multiqc`` generate MultiQC report 

Graph features can highlight variation in the graph. ``-S, --stats`` generates general graph statistics using `odgi stats <https://odgi.readthedocs.io/en/latest/rst/commands/odgi_stats.html>`_.
MultiQC's ODGI module can process these graph stastics and present them in a nice report. If ``-v, --skip-viz`` was not set, then the created 1D and 2D visualizations are incorporated in the report, too.


Parallelization
---------------

Always set `-t` to the desired number of parallel threads. If the POA step of ```smoothxg`` blows up your memory, you can set the POA threads with ``-T``. 
A  good approximation can be half what was set in ``-t``.

..
    miscellaneous

    outdir
    input PAF
    resume
    keep temp files
    pigz
    transclose batch
    MAF
    Consensus
