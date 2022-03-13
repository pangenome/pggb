.. meta::
   :description: pggb: the pangenome graph builder
   :keywords: variation graph, pangenome graph

==================================
Welcome to the PGGB documentation!
==================================

In standard genomic approaches sequences are related to a single linear reference genome introducing reference bias.
`Pangenome graphs <https://pangenome.github.io/>`__ encoded in the variation graph data model describe the all versus all alignment of many sequences.

`pggb <https://github.com/pangenome/pggb>`_ renders a collection of sequences into a pangenome graph, in the variation graph model.
Its goal is to build a graph that is locally directed and acyclic while preserving large-scale variation.
Maintaining local linearity is important for the interpretation, visualization, and reuse of pangenome variation graphs.

``pggb`` consists of three phases:

  1. `wfmash <https://github.com/ekg/wfmash>`_: the probabilistic mash-map mapper ``wfmash`` is used to create all versus all alignments of all input segments.
  2. `seqwish <https://github.com/ekg/seqwish>`_: the pangenome graph is induced from the alignments and emitted as a GFAv1.
  3. `smoothxg <https://github.com/pangenome/smoothxg>`_: the graph is then sorted with a form of multi-dimensional scaling in 1D, groomed, and topologically ordered locally. The 1D order is then broken into "blocks" which are "smoothed" using the partial order alignment (POA) algorithm implemented in abPOA.

Moreover, the pipeline supports identification and collapse of redundant structure with `GFAffix <https://github.com/marschall-lab/GFAffix>`_.
Optional post-processing steps  with `ODGI <https://github.com/pangenome/odgi>`_ provide 1D and 2D diagnostic visualizations of the graph and basic graph metrics.
Variant calling is also possible with ```vg <https://github.com/vgteam/vg>`_ deconstruct`` to obtain a VCF file relative to any set of reference sequences used in the construction

A Nextflow version of ``pggb`` is currently developed on `nf-core/pangenome <https://github.com/nf-core/pangenome>`_.
This pipeline presents an implementation that scales better on a cluster.


.. toctree::
    :maxdepth: 1
    :hidden:

    Welcome <self>
    rst/installation
    rst/quick_start
    rst/tutorials
    rst/faqs

Citation
--------

| **IN PREPARATION**

Core Functionalities
--------------------

**Click on the images below for more details.**

.. |tutorial_one| image:: img/tutorial_one.png
    :target: rst/tutorials/tutorial_one.html


.. list-table::
    :widths: 40 60
    :align: center

    * - |tutorial_one|
      - **Tutorial one**

        + Step 1
        + Step 2
        + Step 3

------
Index
------

* :ref:`genindex`
* :ref:`search`
