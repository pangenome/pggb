.. _essential_parameters:

####################
Essential parameters
####################

.. toctree::
    :maxdepth: 1

It is important to understand the key parameters of each phase and their effect on the resulting pangenome graph.
Each pangenome is different. We may require different settings to obtain useful graphs for particular applications in different contexts.


-------------------------
Mapping
-------------------------

In ``pggb``, the main parameters in mainly shaping pangenome graph structure are the mapping identity minimum ``-p`` and the segment length ``-s``.
These three parameters passed to ``wfmash`` are essential for establishing the basic structure of the pangenome:

    - ``-s[N], --segment-length=[N]`` length of the mapped and aligned segment
    - ``-p[%], --map-pct-id=[%]`` percentage identity minimum in the mapping step

Thse parameters can be set using some prior information about the sequences that you're using.
Crucially, ``--segment-length`` provides a kind of minimum alignment length filter. The ``mashmap`` step in ``wfmash`` will only consider segments of this size, 
and require them to have an approximate pairwise identity of at least ``--map-pct-id``. For small pangenome graphs, or where there are few repeats, ``--segment-length``
can be set low (for example 3000 as in :ref:`quick_start_example` for the MHC pangenome graph).
However, for larger contexts, with repeats, it can be useful to set this high (for instance, even 10/20 kbps in the case of human genomes).
A long segment length ensures that we represent long collinear regions of the input sequences in the structure of the graph.
In general, this should at least be larger than transposon and other common repeats in your pangenome.
By default, ``wfmash`` only keeps mappings with at least 5 times the size of a segment.
This can be adjusted with ``-l, --block-length BLOCK``.

Although the defaults (``-p 95 -s 10k``) should work for most pangenome contexts, it is recommended to set suitable minimum mapping identity ``-p`` and segment length ``-s``.
In particular, for high divergence problems (e.g. models built from separate species) it can be necessary to set ``-p`` and ``-s`` to different levels.
Increasing ``-p`` and ``-s`` will increase the stringency of the initial alignment, while reducing them will make this more sensitive.
Moreover, ``pggb`` requires that the user set a number of mappings ``-n`` per segment.
``-n`` represents the number of haplotypes in the input pangenome.
This is automatically computed if sequence names follow `PanSN-spec <https://github.com/pangenome/PanSN-spec>`_.


-------------------------
Estimate divergence
-------------------------

Use ``mash dist`` or ``mash triangle`` to explore the typical level of divergence between the sequences in your input (see the :ref:`divergence_estimation` tutorial for more information).
Convert this to an approximate percent identity and provide it as ``-p, --map-pct-id PCT``.

-------------------------
Target number of alignment
-------------------------

The ``pggb`` graph is defined by the number of mappings per segment of each genome. ``-c, --n-mappings N``.
Ideally, you should set this to equal to 1 to have each genome mapped against all others once.
Because that's the maximum number of secondary mappings and alignments that we expect.
Howver, in case of pangenome with copy number variation, you may want to set this to a higher number.
Keep in mind that the total work of alignment is proportional to ``N*N``, and these multimappings can be highly redundant. 
In general, it is recommended to set this to 1, and only increase it if you have a good reason to do so.
