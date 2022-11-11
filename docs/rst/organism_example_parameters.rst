.. _organism_example_parameters:

###########################
Organism Example Parameters
###########################

.. toctree::
    :maxdepth: 1

Human
=====

The following parameters were used to build a 90-haplotype human pangenome graph from the HPRC data. 
Specifically, the graph built contains the human references GRCh38, CHM13, and the contigs of 44 diploid individuals
that encode all possible variations including those in telomeres and centromeres.

.. code-block:: bash

    pggb -p 98 -s 50000 -n 90 -k 79 ...

Major Histocompatibility Complex
================================

We built a pangenome graph from 9 MHC class II assemblies from vertebrate genomes which have 5-10% divergence.

.. code-block:: bash

    pggb -n 9 -k 29 ...

Helicobacter
============

Building a pangenome graph from 15 `helicobacter` genomes with 5% divergence.

.. code-block:: bash

    pggb -n 15 -k 79 ...
    
Building a pangenome graph from 15 `helicobacter` genomes with 10% divergence.

.. code-block:: bash
    
    pggb -n 15 -k 19 -P asm20 ...

Yeast
=====

Building a pangenome graph from 7 yeast genomes with 5% divergence.

.. code-block:: bash

    pggb -n 7 -k 29 ...

Bacterial genomes
=====

Building a pangenome graph from A few thousand bacterial genomes.

.. code-block:: bash

    pggb -x auto -n 2146 ...

In general mapping sparsification (``-x auto``) is a good idea when you have many hundreds to thousands of genomes.
