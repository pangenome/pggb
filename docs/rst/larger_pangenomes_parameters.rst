.. _larger_pangenomes_parameters:

#################
Larger Pangenomes
#################

.. toctree::
    :maxdepth: 1

Although a nice example, the settings for the small, highly-diverse DRB1-3123 gene in the human HLA are typically too sensitive when building whole genomes. # TODO add link to first quick start example.

In practice, we usually need to set ``-s`` much higher, up to 50000 or 100000 depending on context, to ensure that the resulting graphs maintain a structure reflective of the underlying 
homology of large regions of the genome, and not spurious matches caused by small repeats.

To ensure that we only get high-quality alignments, we might need to set ``-p`` higher, near the expected pairwise diversity of the sequences we're using (including structural variants 
in the diversity metric). In general, increasing ``-s``, and ``-p`` decreases runtime and memory usage. However, it also decreases the compression of the graph.

For instance, a good setting for 10-20 genomes from the same species, with diversity from 1-5% would be ``-s 100000 -p 90 -n 10``. However, if we wanted to include genomes from another 
species with higher divergence (say 20%), we might use ``-s 100000 -p 70 -n 10``. The exact configuration depends on the application, and testing must be used to determine what is appropriate for a given study.

When ``abPOA`` digests very complex and deep blocks, it might consume a huge amount of memory. This can be addressed with ``-T`` to specifically control the number of threads during the POA step. This leads to a lower memory consumption.