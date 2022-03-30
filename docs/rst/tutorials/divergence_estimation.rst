.. _divergence_estimation:

####################
Divergence estimation
####################

========
Synopsis
========

``pggb`` exposes parameters that allow users to influence the structure of the graph that will represents the input sequences.
In particular, reducing the mapping identity (``-p`` parameter) increases the sensitivity of the alignment, leading to more compressed graphs.
It is recommended to change this parameter depending on how divergent are the input sequences.

=====
Steps
=====

Here we show how to estimate the sequence divergence of 7 `Saccharomyces cerevisiae` assemblies (`Yue et al., 2016 <https://doi.org/10.1038/ng.3847>`_)
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


-------------------------
Sequence divergence
-------------------------

Assuming we will work with one chromosome at a time, we estimate the sequence divergence for each set of chromosomes.
To partition the sequences by chromosome, execute:

.. code-block:: bash

    cut -f 1 scerevisiae7.fasta.gz.fai | cut -f 3 -d '#' | sort | uniq | while read CHROM; do
        CHR_FASTA=scerevisiae7.$CHROM.fasta.gz
        samtools faidx scerevisiae7.fasta.gz $(grep -P $"$CHROM\t" scerevisiae7.fasta.gz.fai | cut -f 1) | bgzip -@ 4 > $CHR_FASTA

        echo "Generated $CHR_FASTA"
    done

For each set of chromosomes, to estimate the `distance <https://mash.readthedocs.io/en/latest/distances.html#distance-estimation>`_
of each input sequence to every other sequence in the set, we use `mash <https://doi.org/10.1186/s13059-016-0997-x>`_.
In particular, the ``mash triangle`` command outputs a lower-triangular distance matrix.
For example, to compute the distances between all mitochondrial sequences, execute:

.. code-block:: bash

    mash triangle scerevisiae7.chrMT.fasta.gz > scerevisiae7.chrMT.mash_triangle.txt
    cat scerevisiae7.chrMT.mash_triangle.txt | column -t

.. code-block:: none

    7
    DBVPG6044#1#chrMT
    DBVPG6765#1#chrMT    0.0192445
    S288C#1#chrMT        0.0151342  0.0182524
    SK1#1#chrMT          0.0023533  0.0202797  0.0144049
    UWOPS034614#1#chrMT  0.0186813  0.0210181  0.0185579  0.0179508
    Y12#1#chrMT          0.0188053  0.0208145  0.0126347  0.0178312  0.0148187
    YPS128#1#chrMT       0.0170687  0.0198213  0.0136991  0.0175939  0.0141502  0.0131603

The distance is between 0 (identical sequences) and 1.
This shows that we have 7 sequences and the distance is up to a few percent. To identify the maximum divergence, execute:

.. code-block:: bash

    sed 1,1d scerevisiae7.chrMT.mash_triangle.txt | tr '\t' '\n' | grep chr -v | sort -g -k 1nr | head -n 1

.. code-block:: none

    0.0210181

To compute the maximum divergence for each set of chromosomes, execute:

.. code-block:: bash

    ls scerevisiae7.*.fasta.gz | while read CHR_FASTA; do
        CHROM=$(echo CHR_FASTA | cut -f 2 -d '.')
        MAX_DIVERGENCE=$(mash triangle -p 4 CHR_FASTA | sed 1,1d | tr '\t' '\n' | grep chr -v | sort -g -k 1nr | head -n 1)

        echo -e "$CHROM\t$MAX_DIVERGENCE" >> scerevisiae7.divergence.txt
    done

    cat scerevisiae7.divergence.txt | column -t

.. code-block:: none

    chrI     0.0178312
    chrII    0.00804257
    chrIII   0.00981378
    chrIV    0.00759618
    chrIX    0.00985499
    chrMT    0.0210181
    chrV     0.00892796
    chrVI    0.00985499
    chrVII   0.00877107
    chrVIII  0.00924552
    chrX     0.00920555
    chrXI    0.00948708
    chrXII   0.00900687
    chrXIII  0.00804257
    chrXIV   0.00838426
    chrXV    0.000981871
    chrXVI   0.00838426

From this analysis, ``chrI`` and ``chrMT`` sets show the higher sequence divergence, with maximum value of ``0.0210181``.
In general, we should set a mapping identity value lower than or equal to ``100 - max_divergence * 100``. That is,
to analyze this Yeast panel, we have to specify ``-p`` lower than or equal to ``97.89819``.
