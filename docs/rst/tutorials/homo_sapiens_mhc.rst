.. _homo-sapiens-mhc:

####################
Homo sapiens MHC
####################

========
Synopsis
========

The `major histocompatibility complex <https://en.wikipedia.org/wiki/Major_histocompatibility_complex>`_ (MHC) is a large
locus in vertebrate DNA containing a set of closely linked polymorphic genes that code for cell surface proteins essential
for the adaptive immune system. In humans, the MHC region occurs on chromosome 6.

=====
Steps
=====

-------------------------
Data collection
-------------------------

We map HPRC chromosome 6 contigs to the MHC ALT haplotypes from GRCh38:

.. code-block:: bash

    wfmash -t 16 -m -s 5000 -p 98 MHC.fa.gz chr6.pan.fa > HPRCy1.pan.chr6_vs_MHC.paf

Then, we make a BED file for the mappings and merge the regions in it to make a single BED record per matching contig:

.. code-block:: bash

    awk '{ print $1, $3, $4 }' HPRCy1.pan.chr6_vs_MHC.paf | tr ' ' '\t' | sort -V > HPRCy1.MHC.bed
    bedtools merge -d 1000000 -i HPRCy1.MHC.bed > HPRCy1.MHC.merge.bed

Finally, we extract the FASTA file for the regions:

.. code-block:: bash

    bedtools getfasta -fi /lizardfs/erikg/HPRC/year1/parts/chr6.pan+refs.fa -bed HPRCy1.MHC.merge.bed | bgzip -c -@ 16 > HPRCy1.MHC.fa.gz
    samtools faidx HPRCy1.MHC.fa.gz

-------------------------
Pangenome Sequence Naming
-------------------------

Contigs already respect the Pangenome Sequence Naming specification (`PanSN-spec <https://github.com/pangenome/PanSN-spec>`_).

.. code-block:: bash

    head HPRCy1.MHC.fa.gz.fai | cut -f 1

.. code-block:: none

    HG00438#1#JAHBCB010000040.1:22870000-27725000
    HG00438#2#JAHBCA010000042.1:22875000-27895000
    HG00621#1#JAHBCD010000020.1:22865000-27905000
    HG00621#2#JAHBCC010000005.1:28460000-33400000
    HG00673#1#JAHBBZ010000030.1:28480000-33310000
    HG00673#2#JAHBBY010000018.1:0-2900000
    HG00673#2#JAHBBY010000031.1:0-1965000
    HG00733#1#JAHEPQ010000070.1:28535000-33420000
    HG00733#2#JAHEPP010000008.1:0-3285000
    HG00733#2#JAHEPP010000060.1:26405000-27483925

-------------------------
Divergence estimation
-------------------------

To estimate the divergence between all sequences (see the :ref:`divergence_estimation` tutorial for more information),
execute:

.. code-block:: bash

    mash triangle HPRCy1.MHC.fa.gz -s 100000 -p 16 > HPRCy1.MHC.mash_triangle.txt
    head HPRCy1.MHC.mash_triangle.txt | column -t

.. code-block:: none

    HG00438#1#JAHBCB010000040.1:22870000-27725000
    HG00438#2#JAHBCA010000042.1:22875000-27895000  0.00415114
    HG00621#1#JAHBCD010000020.1:22865000-27905000  0.00361058  0.00215927
    HG00621#2#JAHBCC010000005.1:28460000-33400000  0.00298612  0.00360171  0.00358989
    HG00673#1#JAHBBZ010000030.1:28480000-33310000  0.00327667  0.0032361   0.00319563  0.00250515
    HG00673#2#JAHBBY010000018.1:0-2900000          0.0169134   0.0160476   0.0160145   0.0166797   0.0154757
    HG00673#2#JAHBBY010000031.1:0-1965000          0.0291794   0.0309845   0.0305785   0.0296791   0.0300142   0.16322
    HG00733#1#JAHEPQ010000070.1:28535000-33420000  0.0025218   0.00407202  0.00387278  0.00234231  0.00244425  0.0165496   0.0292262
    HG00733#2#JAHEPP010000008.1:0-3285000          0.0134574   0.0129725   0.0132524   0.0129533   0.0129964   0.00548677  0.0884189  0.0130782


To identify the maximum divergence, execute:

.. code-block:: bash

    sed 1,1d HPRCy1.MHC.mash_triangle.txt  | tr '\t' '\n' | grep '#' -v | LC_ALL=C sort -g -k 1nr | uniq | head -n 1

.. code-block:: none

    0.23895


The MHC locus presents a high sequence divergence.
We recommend setting the mapping identity (``-p`` parameter) in ``pggb`` to ``80`` to take into account such a divergence.

-------------------------
Sequence partitioning
-------------------------

As the dataset is small, we do not need to partition sequences (see the :ref:`sequence_partitioning` tutorial for more information).

-------------------------
Pangenome graph building
-------------------------

To build the MHC pangenome graph, execute:

.. code-block:: bash

    pggb -i HPRCy1.MHC.fa.gz -p 80 -n 90 -t 16 -G 13117,13219 -o HPRCy1.MHC.s10k.p80.output

To call variants for each contig, execute:

.. code-block:: bash

    vg deconstruct -P chm13 -H '?' -e -a -t 16 HPRCy1.MHC.s10k.p80.output/HPRCy1.MHC.fa.gz.715ccc4.e34d4cd.0a020b5.smooth.final.gfa | \
        bgzip -c -@ 16 > HPRCy1.MHC.s10k.p80.output/HPRCy1.MHC.fa.gz.715ccc4.e34d4cd.0a020b5.smooth.final.chm13.vcf.gz


``-H '?'`` avoids managing the path name hierarchy when calling variants, then emitting variants for each contig.

-------------------------
Graph statistics
-------------------------

To collect basic graph statistics, execute:

.. code-block:: bash

    odgi stats -i HPRCy1.MHC.s10k.p80.output/*.final.gfa -t 16 -S

.. code-block:: none

    #length	nodes	edges	paths
    4895344	492539	710886	126

-------------------------
Small variants evaluation
-------------------------

Prepare the reference FASTA file:

.. code-block:: bash

    samtools faidx HPRCy1.MHC.fa.gz chm13#chr6:28380000-33300000 > chm13#chr6:28380000-33300000.fa

Align each sequence against the reference with `nucmer <10.1186/gb-2004-5-2-r12>`_:

.. code-block:: bash

    REF=chm13#chr6:28380000-33300000.fa
    NAMEREF=chm13

    mkdir -p nucmer/

    cut -f 1 HPRCy1.MHC.fa.gz.fai | grep chm13 -v | while read CONTIG; do
        echo $CONTIG

        PREFIX=nucmer/${CONTIG}_vs_${NAMEREF}
        samtools faidx HPRCy1.MHC.fa.gz $CONTIG > $CONTIG.fa

        nucmer $REF $CONTIG.fa --prefix "$PREFIX"

        show-snps -THC "$PREFIX".delta > "$PREFIX".var.txt

        rm $CONTIG.fa
    done

Generate VCF files for each sequence against the reference with `nucmer <10.1186/gb-2004-5-2-r12>`_:

.. code-block:: bash

    REF=chm13#chr6:28380000-33300000.fa
    NAMEREF=chm13

    NUCMER_VERSION="4.0.0beta2"
    cut -f 1 HPRCy1.MHC.fa.gz.fai | grep chm13 -v | while read CONTIG; do
        echo $CONTIG

        PREFIX=nucmer/${CONTIG}_vs_${NAMEREF}
        Rscript nucmer2vcf.R "$PREFIX".var.txt $CONTIG $REF $NUCMER_VERSION $PREFIX.vcf
        bgzip -@ 16 $PREFIX.vcf
        tabix $PREFIX.vcf.gz
    done

Take SNPs from the PGGB VCF file:

.. code-block::bash

    REF=chm13#chr6:28380000-33300000.fa
    NAMEREF=chm13

    cut -f 1 HPRCy1.MHC.fa.gz.fai | grep chm13 -v | while read CONTIG; do
        echo $CONTIG

        bash vcf_preprocess.sh \
            HPRCy1.MHC.s10k.p80.output/HPRCy1.MHC.fa.gz.715ccc4.e34d4cd.0a020b5.smooth.final.chm13.vcf.gz \
            $CONTIG \
            1 \
            $REF
    done

Prepare ``SGF`` format for variant evaluation with ``rtg vcfeval``:

.. code-block::bash

    rtg format -o chm13#chr6:28380000-33300000.sdf chm13#chr6:28380000-33300000.fa

Compare nucmer-based SNPs with PGGB-based SNPs:

.. code-block::bash

    REFSDF=chm13#chr6:28380000-33300000.sdf
    NAMEREF=chm13

    cut -f 1 HPRCy1.MHC.fa.gz.fai | grep chm13 -v | while read CONTIG; do
        echo $CONTIG

        PREFIX=nucmer/${CONTIG}_vs_${NAMEREF}

        rtg vcfeval \
                -t $REFSDF \
                -b $PREFIX.vcf.gz \
                -c HPRCy1.MHC.s10k.p80.output/HPRCy1.MHC.fa.gz.715ccc4.e34d4cd.0a020b5.smooth.final.chm13.${CONTIG}.max1.vcf.gz \
                -T 16 \
                -o vcfeval/${CONTIG}
    done

Collect statistics:

.. code-block::

    (echo contig precision recall f1.score; grep None */*txt | sed 's,/summary.txt:,,' | tr -s ' ' | cut -f 1,7,8,9 -d ' ' ) | tr ' ' '\t' > statistics.tsv

Plot ``F1.scores``:

.. code-block:: R

    stat_df <- read.table('statistics.tsv', sep = '\t', header = T, comment.char = '?')

    ggplot(stat_df,aes(x=contig,y=f1.score,fill=contig))+
      geom_bar(stat="identity") +
      theme_bw() +
      theme(
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank()
      ) +
      theme(legend.position="none")

.. image:: /img/MHC.nucmer_vs_pggb.F1scores.png
