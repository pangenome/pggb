.. _wfmash:

######
wfmash
######

.. toctree::
    :maxdepth: 1

`wfmash <https://github.com/waveygang/wfmash>`_ uses a modified version of mashmap to obtain approximate mappings, and then applies a
`wavefront-guided global alignment algorithm for long sequences <https://github.com/ekg/wflign>`_ to derive an alignment for each mapping. 
`wfmash` uses the `wavefront alignment algorithm <https://github.com/smarco/WFA>`_ for base-level alignment. This mapper is used to scaffold 
the pangenome, using genome segments of a given length with a specified maximum level of sequence divergence. All segments in the input are mapped 
to all others. This step yields alignments represented in the `PAF <https://github.com/lh3/miniasm/blob/master/PAF.md>`_ output format, with cigars 
describing their base-exact alignment.