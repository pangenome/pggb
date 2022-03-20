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
This might unnecessarily complicate the computational load, as well as compromise the downstream analyzes.
Therefore, it is recommended to split up the input into `communities` in order to find the latent structure of the mutual relationship between the sequences.
For example, the communities can represent the different chromosomes of the input genomes.

=====
Steps
=====
