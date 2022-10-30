.. _escherichia-coli:

####################
Escherichia coli
####################

**Author**: `Andrea Guarracino <https://github.com/AndreaGuarracino>`_

========
Synopsis
========

`Escherichia coli` (`E. coli`) is a gram-negative bacillus known to be a part of normal intestinal flora but can also
be the cause of intestinal and extraintestinal illness in humans `Gill et al., 2006 <https://doi.org/10.1126/science.1124234>`_.
Here we study `E. coli` genomic diversity by analyzing a pangenome graph made with 2224 assemblies.

=====
Steps
=====


-------------------------
Download the assemblies
-------------------------

Assuming that your current working directory is the root of the ``pggb`` repository, to download 2224 assemblies of `E. coli`,
execute:

.. code-block:: bash

    mkdir -p assemblies/e_coli
    cd assemblies/e_coli
    cat ../../docs/data/ecoli.urls | parallel -j 4 'wget -q {} && echo got {}'


-------------------------
Pangenome Sequence Naming
-------------------------

To change the sequence names according to `PanSN-spec <https://github.com/pangenome/PanSN-spec>`_,
we use `fastix <https://github.com/ekg/fastix>`_:

.. code-block:: bash

    ls *.fna.gz | while read f; do
        sample_name=$(echo $f | cut -f 1,2 -d '_');
        echo ${sample_name}
        # 'cut -f 1' to trim the headers
        fastix -p "${sample_name}#1#" <(zcat $f | cut -f 1) | bgzip -@ 4 -c > ${sample_name}.fa.gz
    done

We specify ``haplotype_id`` equals to ``1`` for all the assemblies.
Indeed, most bacteria in general, including `E. coli`, contain one homolog of their single chromosome, and therefore are considered to be haploid.
