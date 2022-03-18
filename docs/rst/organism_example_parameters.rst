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

    pggb -p 98 -s 100000 -n 90 -k 311 -G 13117,13219 ...

Major Histocompatibility Complex
================================

We built a pangenome graph from 9 MHC class II assemblies from vertebrate genomes which have 5-10% divergence.

.. code-block:: bash

    pggb -p 90 -s 5000 -n 9 -k 29 -G 3079,3559 ...

Helicobacter
============

Building a pangenome graph from 15 `helicobacter` genomes with 5% divergence.

.. code-block:: bash

    -p 90 -s 20000 -n 15 -H 15 -k 79 -G 7919,8069 ...
    
Building a pangenome graph from 15 `helicobacter` genomes with 10% divergence.

.. code-block:: bash
    
    pggb -p 90 -s 20000 -n 15 -k 19 -P 1,7,11,2,33,1 -G 4457,4877,5279 ...

Yeast
=====

Building a pangenome graph from 7 yeast genomes with 5% divergence. 

.. code-block:: bash
    
    pggb -p 95 -s 20000 -n 7 -k 29 -G 7919,8069 ...