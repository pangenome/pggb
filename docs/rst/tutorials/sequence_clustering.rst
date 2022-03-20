.. _sequence_clustering:

####################
Sequence clustering
####################

========
Synopsis
========

Pangenome graphs can represent all mutual alignments of collections of sequences.
However, we can't really expect to pairwise map all sequences together and obtain well separated connected components.
It is likely to get a giant connected component, and probably a few smaller ones, due to incorrect mappings or false homologies.
This might unnecessarily increase the computational burden, as well as complicate the downstream analyzes.
Therefore, it is recommended to split up the input sequences into `communities` in order to find the latent structure of their mutual relationship.
For example, the communities can represent the different chromosomes of the input genomes.

.. warning::

	If you know in advance that your sequences present particular rearrangements (like rare chromosome translocations), you might consider skipping this step or tuning it accordingly to your biological questions.

=====
Steps
=====

Here we show how to detect the communities in the `Yeast Population Reference Panel (YPRP) <https://yjx1217.github.io/Yeast_PacBio_2016/welcome/>`_
composed of 13 assemblies, 7 of `Saccharomyces cerevisiae` and 5 of `Saccharomyces paradoxus` (`Yue et al., 2016 <https://doi.org/10.1038/ng.3847>`_).

-------------------------
Install the dependencies
-------------------------

We applies the ``Leiden`` algorithm (`Trag et al., 2018 <https://doi.org/10.1038/s41598-019-41695-z>`_) implemented in
the ``leidenalg`` `package <https://github.com/vtraag/leidenalg>`_:

.. code-block:: bash

    pip3 install leidenalg
    pip3 install pycairo # Only needed for visualization

-------------------------
Download the assemblies
-------------------------

Assuming that your current working directory is the root of the ``pggb`` repository, to download the ``YPRP panel``,
execute:

.. code-block:: bash

    mkdir -p assemblies/yprp_panel
    cd assemblies/yprp_panel
    cat ../../docs/data/saccharomyces.yprp.urls | parallel -j 4 'wget -q {} && echo got {}'

For each sample, to put genome and mitochondrial sequences together, execute:

.. code-block:: bash

    ls *.fa.gz | cut -f 1 -d '.' | uniq | while read f; do
        echo $f
        zcat $f.* > $f.fa
    done

-------------------------
Pangenome Sequence Naming
-------------------------

To change the sequence names according to `PanSN-spec <https://github.com/pangenome/PanSN-spec>`_,
we use `fastix <https://github.com/ekg/fastix>`_:

.. code-block:: bash

    ls *.fa | while read f; do
        sample_name=$(echo $f | cut -f 1 -d '.');
        echo ${sample_name}
        fastix -p "${sample_name}#1#" $f >> saccharomyces13.fasta
    done
    bgzip -@ 4 saccharomyces13.fasta
    samtools faidx saccharomyces13.fasta.gz

We specify ``haplotype_id`` equals to ``1`` for all the assemblies, as they are all haploid.

