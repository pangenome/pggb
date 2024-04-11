.. _faqs:

####
FAQs
####

.. toctree::
    :maxdepth: 1

How are non-common nucleotide sequences treated?
================================================

The supported canonical bases are `A`, `C`, `T`, `G`. All other `nucleotide symbols <http://www.hgmd.cf.ac.uk/docs/nuc_lett.html>`_ are treated as `N`.
In particular, in ``wfmash``, non-canonical bases are treated as mismatches when guiding the local base-level alignments.
