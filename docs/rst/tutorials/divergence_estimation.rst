.. _divergence_estimation:

####################
Divergence estimation
####################

========
Synopsis
========

``pggb`` exposes parameters that allow users to influence the structure of the graph that represents the input sequences.
In particular, reducing the mapping identity (``-p`` parameter) increases the sensitivity of the alignment, leading to more compressed graphs.
It is recommended to change this parameter depending on how divergent are the input sequences.

=====
Steps
=====

Here we show how to detect estimate the sequence divergence of 7 `Saccharomyces cerevisiae` assemblies (`Yue et al., 2016 <https://doi.org/10.1038/ng.3847>`_)
from the `Yeast Population Reference Panel (YPRP) <https://yjx1217.github.io/Yeast_PacBio_2016/welcome/>`_.

-------------------------
Download the assemblies
-------------------------

Assuming that your current working directory is the root of the ``pggb`` repository, to download the ``YPRP panel``,
execute:

.. code-block:: bash

    mkdir -p assemblies/yprp_panel
    cd assemblies/yprp_panel
    cat ../../docs/data/scerevisiae.yprp.urls | parallel -j 4 'wget -q {} && echo got {}'

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
        ~/git/fastix/target/release/fastix -p "${sample_name}#1#" $f >> scerevisiae7.fasta
    done
    bgzip -@ 4 scerevisiae7.fasta
    samtools faidx scerevisiae7.fasta.gz

We specify ``haplotype_id`` equals to ``1`` for all the assemblies, as they are all haploid.

