.. _installation:

############
Installation
############

Manual-mode
===========

.. |br| raw:: html

   <br />

You'll need `wfmash <https://github.com/waveygang/wfmash>`_, `seqwish <https://github.com/ekg/seqwish>`_, `smoothxg <https://github.com/pangenome/smoothxg>`_,
`odgi <https://github.com/pangenome/odgi>`_, and `gfaffix <https://github.com/marschall-lab/GFAffix>`_ in your shell's ``PATH``. They can be build from source or installed via Bioconda. Then, add the ``pggb`` bash script to your ``PATH`` to complete the installation. 
`How to add a binary to my path? <https://zwbetz.com/how-to-add-a-binary-to-your-path-on-macos-linux-windows/>`_ |br|
Optionally, install `bcftools <https://github.com/samtools/bcftools>`_, `vcfbub <https://github.com/pangenome/vcfbub>`_, `vcfwave <https://github.com/vcflib/vcflib>`, and `vg <https://github.com/vgteam/vg>`_ for calling and normalizing variants, `MultiQC <https://multiqc.info/>`_ for generating summarized statistics in a MultiQC report, or `pigz <https://zlib.net/pigz/>`_ to compress the output files of the pipeline.


Docker
======

To simplify installation and versioning, we have an automated GitHub action that pushes the current docker build to the GitHub registry.
To use it, first pull the actual image (**IMPORTANT**: see also how to :ref:`build_docker_locally`):


.. code-block:: bash

    docker pull ghcr.io/pangenome/pggb:latest


Or if you want to pull a specific snapshot from `https://github.com/orgs/pangenome/packages/container/package/pggb <https://github.com/orgs/pangenome/packages/container/package/pggb>`_:

.. code-block:: bash

    docker pull ghcr.io/pangenome/pggb:TAG


You can pull the docker image also from `dockerhub <https://hub.docker.com/r/pangenome/pggb>`_:

.. code-block:: bash

    docker pull pangenome/pggb


As an example, going in the ``pggb`` directory

.. code-block:: bash

    git clone --recursive https://github.com/pangenome/pggb.git
    cd pggb

you can run the container using the human leukocyte antigen (HLA) data provided in this repo:

.. code-block:: bash

    docker run -it -v ${PWD}/data/:/data ghcr.io/pangenome/pggb:latest /bin/bash -c "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -n 10 -t 16 -V 'gi|568815561' -o /data/out"


The ``-v`` argument of ``docker run`` always expects a full path.
**If you intended to pass a host directory, use absolute path.**
This is taken care of by using ``${PWD}``.


.. _build_docker_locally:

build docker locally
--------------------------

Multiple ``pggb``'s tools use SIMD instructions that require AVX (like ``abPOA``) or need it to improve performance.
The currently built docker image has ``-Ofast -march=sandybridge`` set.
This means that the docker image can run on processors that support AVX or later, improving portability, but preventing your system hardware from being fully exploited.
In practice, this could mean that specific tools are up to 9 times slower.
And that a pipeline runs ~30% slower compared to when using a native build docker image.

To achieve better performance, it is **STRONGLY RECOMMENDED** to build the docker image locally after replacing ``-march=sandybridge`` with ``-march=native`` and the ``Generic` build type with `Release`` in the ``Dockerfile``:

.. code-block:: bash

    sed -i 's/-march=sandybridge/-march=native/g' Dockerfile
    sed -i 's/Generic/Release/g' Dockerfile

To build a docker image locally using the ``Dockerfile``, execute:

.. code-block:: bash

    docker build --target binary -t ${USER}/pggb:latest .


Staying in the ``pggb`` directory, we can run ``pggb`` with the locally build image:

.. code-block:: bash

    docker run -it -v ${PWD}/data/:/data ${USER}/pggb /bin/bash -c "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -n 10 -t 16 -V 'gi|568815561' -o /data/out"

A script that handles the whole building process automatically can be found at `https://github.com/nf-core/pangenome#building-a-native-container <https://github.com/nf-core/pangenome#building-a-native-container>`_`.


Singularity
======

Many managed HPCs utilize Singularity as a secure alternative to docker.
Fortunately, docker images can be run through Singularity seamlessly.

First pull the docker file and create a Singularity SIF image from the dockerfile.
This might take a few minutes.

.. code-block:: bash

    singularity pull docker://ghcr.io/pangenome/pggb:latest


Next clone the `pggb` repo and `cd` into it

.. code-block:: bash

    git clone --recursive https://github.com/pangenome/pggb.git
    cd pggb


Finally, run `pggb` from the Singularity image.
For Singularity to be able to read and write files to a directory on the host operating system, we need to 'bind' that directory using the `-B` option and pass the `pggb` command as an argument.

.. code-block:: bash
    singularity run -B ${PWD}/data:/data ../pggb_latest.sif "pggb -i /data/HLA/DRB1-3123.fa.gz -p 70 -s 3000 -n 10 -t 16 -V 'gi|568815561' -o /data/out"

A script that handles the whole building process automatically can be found at `https://github.com/nf-core/pangenome#building-a-native-container <https://github.com/nf-core/pangenome#building-a-native-container>`_`.


Bioconda
========

A ``pggb`` recipe for ``Bioconda`` is available at https://anaconda.org/bioconda/pggb.
To install the latest version using ``Conda`` execute:

.. code-block:: bash

    conda install -c bioconda pggb


GUIX
====

.. code-block:: bash

    git clone https://github.com/ekg/guix-genomics
    cd guix-genomics
    GUIX_PACKAGE_PATH=. guix package -i pggb


Nextflow
========

A Nextflow DSL2 port of ``pggb`` is actively developed by the `nf-core <https://nf-co.re/>`_ community.
See `nf-core/pangenome <https://github.com/nf-core/pangenome>`_ for more details. The aim is to implement a cluster-scalable version of ``pggb``. 
The Nextflow version can run the precise base-level alignment step of ``wfmash`` in parallel across the nodes of a cluster. 
This makes it already faster than this `bash` implementation.
