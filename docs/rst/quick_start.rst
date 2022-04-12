.. _quick_start:

===========
Quick Start
===========

.. toctree::
    :maxdepth: 1

A pangenome models the full set of genomic elements in a given species or clade. It can efficiently be encoded in the
form of a variation graph, a type of sequence graph that embeds the linear sequences as paths in the graphs themselves.

To exchange pangenomes, the community frequently uses a strict subset of the Graphical Fragment Assembly ``GFA`` format
version 1 (`GFAv1 <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8006571/#FN8>`_).

In the following, a generic quick start guide for the ``pggb`` pipeline is described.
The input is a FASTA file (e.g. ``input.fa``) containing all sequences to build a pangenome graph from.

-----------------------------
Step 1 - Sequence Preparation
-----------------------------

Put your sequences in one FASTA file ``input.fa`` and index it with ``samtools faidx input.fa``. If you have many genomes, we suggest using the `PanSN-spec <https://github.com/pangenome/PanSN-spec>`_ naming pattern.

-----------------------
Step 2 - Graph Building
-----------------------

To build a graph from a 9-haplotype ``input.fa``, in the directory ``output``, scaffolding the graph using 5kb matches at >= 90% identity, and using 16 parallel threads for processing, execute:

.. code-block:: bash

    pggb \
    -i input.fa \ #the input FASTA file
    -o output \   #the output directory
    -p 90 \       #the sequence identity
    -s 5000 \     #the segment length
    -n 9  \       #the number of haplotypes
    -t 16         #the number of threads

The final process output will be called ``outdir/input.fa*smooth.fix.gfa``. By default, several intermediate files are produced.

.. _quick_start_example:

-----------------------------------------
Example - Building an MHC Pangenome Graph
-----------------------------------------

We build a MHC class II ALTs GRCh38 pangenome graph from 10 haplotypes using test data from this repository's ``data/HLA`` directory.

.. code-block:: bash

    git clone --recursive https://github.com/pangenome/pggb
    cd pggb
    ./pggb -i data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -G 2000 -n 10 -t 16 -V 'gi|568815561:#' -o out -M -C cons,100,1000,10000 -m

..
    This writes to directory ``out``: a variation graph in GFA format, a multiple sequence alignment in MAF format, a series of consensus graphs at different levels of variant resolution,

This writes to directory ``out``: a variation graph in GFA format, a multiple sequence alignment in MAF format,
and several diagnostic images. By default, the outputs are named according to the input file and a hash of the construction parameters.
Adding -v prohibits the rendering of 1D and 2D diagnostic images of the graph. This can reduce running time, because the calculation of the 2D layout can take a while. 
By default, redundant structures in the graph are collapsed by applying GFAffix. We also call variants with ``-V`` with respect to the reference ``gi|568815561:#``.

----------------------
1D Graph Visualization
----------------------

.. image:: ../img/DRB1-3123.fa.gz.pggb-E-s5000-l15000-p80-n10-a0-K16-k8-w50000-j5000-e5000-I0-R0-N.smooth.og.viz_mqc.png

Explanation of this 1D visualization:

    - The graph nodes are arranged from left to right forming the pangenome sequence.
    - The colored bars represent the binned, linearized renderings of the embedded paths versus this pangenome sequence in a binary matrix.
    - The path names are visualized on the left.
    - The black lines under the paths, so called links, represent the topology of the graph.


----------------------
2D Graph Visualization
----------------------

.. image:: ../img/DRB1-3123.fa.gz.pggb-E-s5000-l15000-p80-n10-a0-K16-k8-w50000-j5000-e5000-I0-R0-N.smooth.chop.og.lay.draw_mqc.png

Explanation of this 2D visualization:

    - Each colored rectangle represents a node of a path. The node’s x-coordinates are on the x-axis and the y-coordinates are on the y-axis, respectively.
    - A bubble indicates that here some paths have a diverging sequence or it can represent a repeat region.

For more information about the layout, please visit https://odgi.readthedocs.io/en/latest/rst/tutorials/sort_layout.html.