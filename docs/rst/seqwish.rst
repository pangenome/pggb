.. _seqwish:

#######
seqwish
#######

.. toctree::
    :maxdepth: 1

With `seqwish <https://github.com/ekg/seqwish>`_, the graph induction process implicitly builds the 
`alignment graph <https://github.com/pangenome/pggb#:~:text=The%20pangenome%20graph%20is,variation%2Dgraph%2Dbased%20tools.>`_ 
in a memory-efficient disk-backed implicit interval tree. It then computes the transitive closure of the bases in the input sequences 
through the alignments. By tracing the paths of the input sequences through the graph, it produces a variation graph, which it emits in 
the restricted subset of `GFAv1 <https://github.com/GFA-spec/GFA-spec/blob/master/GFA1.md>`_ format used by variation-graph-based tools.