.. _essential_parameters:

####################
Essential Parameters
####################

.. toctree::
    :maxdepth: 1

It is important to understand the key parameters of each phase and their effect on the resulting pangenome graph. 
Each pangenome is different. We may require different settings to obtain useful graphs for particular applications in different contexts.

``pggb`` requires that the user sets a mapping identity minimum ``-p``, a segment length ``-s``, and a number of secondary mappings ``-n`` per segment. 
These three parameters passed to wfmash are essential for establishing the basic structure of the pangenome:

    - ``-s[N], --segment-length=[N]`` length of the mapped and aligned segment
    - ``-p[%], --map-pct-id=[%]`` percentage identity minimum in the mapping step
    - ``-n[N], --n-mappings=[N]`` maximum number of mappings and alignments reported for each segment

Crucially, ``--segment-length`` provides a kind of minimum alignment length filter. The ``mashmap`` step in ``wfmash`` will only consider segments of this size, 
and require them to have an approximate pairwise identity of at least ``--map-pct-id``. For small pangenome graphs, or where there are few repeats, ``--segment-length``
can be set low ( for example 3000 as in :ref:`quick_start_example`). However, for larger contexts, with repeats, it can be very important to set this high (for instance 100000 in the case of human genomes). 
A long segment length ensures that we represent long collinear regions of the input sequences in the structure of the graph. In general, this should at least be larger than transposon and other common repeats in your pangenome. 
By default, ``wfmash`` only keeps mappings with at least 3 times the size of a segment. This can be adjusted with ``-l, --block-length BLOCK``.

Use ``mash dist`` or ``mash triangle`` to explore the typical level of divergence between the sequences in your input. Convert this to an approximate percent identity and provide it as ``-p, --map-pct-id PCT``.

Set a target number of alignments per segment and haplotype count: The ``pggb graph`` is defined by the number of mappings per segment 
of each genome ``-n, --n-mappings N``. Ideally, you should set this to equal the number of haplotypes in the pangenome.  
Because that's the maximum number of secondary mappings and alignments that we expect.
Keep in mind that the total work of alignment is proportional to ``N*N``, and these multimappings can be highly redundant. 
If you provide a ``N`` that is not equal to the number of haplotypes, provide the actual number of haplotypes to ``-H``.This helps 
``smoothxg`` to determine the right POA problem size.

Always set ``-t`` to the desired number of parallel threads. 