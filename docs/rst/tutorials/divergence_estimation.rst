.. _divergence_estimation:

####################
Divergence estimation
####################

**Author**: `Andrea Guarracino <https://github.com/AndreaGuarracino>`_

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
        fastix -p "${sample_name}#1#" $f >> scerevisiae7.fasta
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
This shows that we have 7 sequences and the distances are up to a few percent. To identify the maximum divergence, execute:

.. code-block:: bash

    sed 1,1d scerevisiae7.chrMT.mash_triangle.txt | tr '\t' '\n' | grep chr -v | LC_ALL=C sort -g -k 1nr | uniq | head -n 1

.. code-block:: none

    0.0210181

To compute the maximum divergence for each set of chromosomes, execute:

.. code-block:: bash

    ls scerevisiae7.*.fasta.gz | while read CHR_FASTA; do
        CHROM=$(echo $CHR_FASTA | cut -f 2 -d '.')
        MAX_DIVERGENCE=$(mash triangle -p 4 $CHR_FASTA | sed 1,1d | tr '\t' '\n' | grep chr -v | LC_ALL=C  sort -g -k 1nr | uniq | head -n 1)

        echo -e "$CHROM\t$MAX_DIVERGENCE" >> scerevisiae7.divergence.txt
    done

    cat scerevisiae7.divergence.txt | column -t

.. code-block:: none

    chrI     0.0178312
    chrII    0.00804257
    chrIII   0.0121679
    chrIV    0.00759618
    chrIX    0.0106545
    chrMT    0.0210181
    chrV     0.00892796
    chrVI    9.55247e-05
    chrVII   0.0639874
    chrVIII  0.0385787
    chrX     0.0357395
    chrXI    0.0324062
    chrXII   0.00900687
    chrXIII  0.052117
    chrXIV   0.00838426
    chrXV    0.0081558
    chrXVI   0.00838426


From this analysis, `chrVII`, `chrVIII`, and `chrXIII` sets show the higher sequence divergence, with maximum value of ``0.0639874``.
In general, we should set a mapping identity value lower than or equal to ``100 - max_divergence * 100``. That is,
to analyze this `YPRP` panel, we have to specify ``-p`` lower than or equal to ``93.60126``.
However, in order to account for possible underestimates of sequence divergence, and medium/large structural variants
leading locally to greater divergence, we recommend setting an even smaller mapping identity, like ``-p 90``.

-------------------------
Inter-chromosome estimations
-------------------------

The `YPRP` panel presents known structural inter-chromosome rearrangements, for example between chromosomes `chrVII` and `chrVIII`
(see the :ref:`sequence_partitioning` tutorial for more information). This can explain why those sets present a higher
intra-chromosome divergence.

To estimate the sequence divergence between `chrVII` and `chrVIII` chromosomes, execute:

.. code-block:: bash

    mash triangle scerevisiae7.community.0.fa.gz -s 10000 > scerevisiae7.community.0.mash_triangle.txt
    cat scerevisiae7.community.0.mash_triangle.txt | column -t

.. code-block:: none

    14
    DBVPG6044#1#chrVII
    S288C#1#chrVII         0.00811043
    SK1#1#chrVII           0.00160605  0.00759986
    Y12#1#chrVII           0.00721034  0.00710972  0.00740957
    YPS128#1#chrVII        0.00641651  0.00659004  0.00659004  0.00505504
    DBVPG6044#1#chrVIII    0.243761    0.222464    0.23782     0.215016    0.221466
    S288C#1#chrVIII        0.222464    0.203604    0.217673    0.194429    0.214163    0.00928959
    SK1#1#chrVIII          0.250557    0.221466    0.242205    0.215016    0.216771    0.000911163  0.00912584
    UWOPS034614#1#chrVII   0.0625263   0.0623939   0.0627391   0.0625528   0.0610962   0.0635756    0.0649949   0.0635211
    UWOPS034614#1#chrVIII  0.0512793   0.0517248   0.0514142   0.049118    0.0496087   0.0358693    0.0373731   0.0359997   0.258493
    Y12#1#chrVIII          0.236445    0.222464    0.236445    0.216771    0.231311    0.00815958   0.0081861   0.00759251  0.0625528  0.0354817
    YPS128#1#chrVIII       0.239237    0.199716    0.213325    0.208588    0.191209    0.00728616   0.00790009  0.006864    0.0628727  0.0345966  0.00614217
    DBVPG6765#1#chrVII     0.00890041  0.00474338  0.0079113   0.00866976  0.00768463  0.26803      0.256381    0.270747    0.0628995  0.0512793  0.26546     0.23011
    DBVPG6765#1#chrVIII    0.273629    0.26546     0.273629    0.26803     0.270747    0.00861155   0.0060471   0.00853035  0.0656244  0.0360829  0.00873594  0.00826588  0.26546


The ``scerevisiae7.community.0.fa.gz`` file contains the sequences of `chrVII` and `chrVIII` sets in FASTA format
(follow the :ref:`sequence_partitioning` tutorial to obtain the FASTA files for all the communities detectable in the `YPRP` panel).
The ``-s 10000`` value in ``mash triangle`` specifies a bigger sketch size for each sequence to compare: a higher value allows for more accurate estimates
(see `here <https://mash.readthedocs.io/en/latest/distances.html#distance-estimation>`_ how the distance estimation works).

The output shows that, generally, sequences from different chromosomes present a very high sequence divergence (greater than ~0.20).
However, for example, the ``UWOPS034614#1#chrVIII`` sequence presents a much lower divergence with respect to the other `chrVII` sequences;, as
shown by the following row of the lower-triangular distance matrix:

.. code-block:: none

    UWOPS034614#1#chrVIII  0.0512793   0.0517248   0.0514142   0.049118    0.0496087   0.0358693    0.0373731   0.0359997   0.258493

Similar considerations hold true for the ``DBVPG6765#1#chrVII`` sequence.
Such lower sequence divergences are due to the structural rearrangements between these chromosomes (`Yue et al., 2016 <https://doi.org/10.1038/ng.3847>`_).
