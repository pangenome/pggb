.. _larger_pangenomes_parameters:

#################
Larger Pangenomes
#################

.. toctree::
    :maxdepth: 1

Although a nice example (:ref:`quick_start_example), the settings for the small, highly-diverse DRB1-3123 gene in the human HLA are typically too sensitive when building whole genomes.)

In practice, we usually need to keep ``-s`` in the 5-20kbp range, depending on context, to ensure that the resulting graphs maintain a structure reflective of the underlying homology of large regions of the genome, and not spurious matches caused by small repeats.

To ensure that we only get high-quality alignments, we might need to set ``-p`` higher, near the expected pairwise diversity of the sequences we're using (including structural variants in the diversity metric). In general, increasing ``-s``, and ``-p`` decreases runtime and memory usage. However, it also decreases the compression of the graph.

For instance, a good setting for 10-20 genomes from the same species, with diversity from 1-5% would be ``-s 10000 -p 95 [-n 10]``. However, if we wanted to include genomes from another species with higher divergence (say 20%), we might use ``-s 10000 -p 70 -n 10``. The exact configuration depends on the application, and testing must be used to determine what is appropriate for a given study.

When ``SPOA/abPOA`` digests very complex and deep blocks, it might consume a huge amount of memory. This can be addressed with ``-T`` to specifically control the number of threads during the POA step. This leads to a lower memory consumption.
