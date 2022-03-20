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
