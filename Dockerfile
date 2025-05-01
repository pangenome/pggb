FROM debian:bookworm-slim AS binary

LABEL authors="Erik Garrison, Simon Heumos, Andrea Guarracino"
LABEL description="Preliminary docker image containing all requirements for pggb pipeline"
LABEL base_image="debian:bookworm-slim"
LABEL software="pggb"
LABEL about.home="https://github.com/pangenome/pggb"
LABEL about.license="SPDX:MIT"

# dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
                       git \
                       bash \
                       cmake \
                       make \
                       g++-11 \
                       python3-dev \
                       python3-pip \
                       python3-venv \
                       pybind11-dev \
                       libbz2-dev \
                       bc \
                       libatomic-ops-dev \
                       autoconf \
                       libgsl-dev \
                       zlib1g-dev \
                       libzstd-dev \
                       libjemalloc-dev \
                       libhts-dev \
                       build-essential \
                       pkg-config \
                       time \
                       curl \
                       pigz \
                       tabix \
                       samtools \
                       wget \
                       pip \
                       libcairo2-dev \
                       unzip \
                       parallel \
                       r-base \
                       libclang-dev \
    && apt-get clean \
    && apt-get purge  \
    && rm -rf /var/lib/apt/lists/*

# current bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/1.19/bcftools-1.19.tar.bz2 \
    && tar xjf bcftools-1.19.tar.bz2 \
    && cd bcftools-1.19/ && ./configure --prefix=/usr/local/bin/ && make && make install && export PATH=/usr/local/bin/bin:$PATH && cd .. && cp /usr/local/bin/bin/* /usr/local/bin/

RUN git clone --recursive https://github.com/waveygang/wfmash \
    && cd wfmash \
    && git pull \
    && git checkout v0.13.1 \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=sandybridge/g' src/common/wflign/deps/WFA2-lib/Makefile \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    # Libraries aren't getting installed
    && cp build/lib/* /usr/local/lib/ \
    && cd ../ \
    && rm -rf wfmash

RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout 0eb6468be0814ab5a0cda10d12aa38cb87d086f1 \
    && git submodule update --init --recursive \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../ \
    && rm -rf seqwish

RUN git clone --recursive https://github.com/pangenome/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout 2a6f17f3cf14d0c927abdad2eeaaef83056fb5e6 \
    && git submodule update --init --recursive \
    && sed -i 's/-msse4.1/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt \
    && sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/spoa/CMakeLists.txt \
    && sed -i 's/-march=native/-march=sandybridge -Ofast/g' deps/abPOA/CMakeLists.txt \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi \
    && cd ../ \
    && rm -rf odgi

# Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo --help

RUN git clone https://github.com/marschall-lab/GFAffix.git \
    && cd GFAffix \
    && git pull \
    && git checkout e8872f40c2bd907d89f487ef83aa8d81904677e1 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/gfaffix /usr/local/bin/gfaffix \
    && cd ../ \
    && rm -rf GFAffix

RUN wget https://github.com/vgteam/vg/releases/download/v1.62.0/vg && chmod +x vg && mv vg /usr/local/bin/vg

RUN git clone https://github.com/pangenome/vcfbub \
    && cd vcfbub \
    && git pull \
    && git checkout db7775f63eab6891acb6000dddfa320146cd7c56 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/vcfbub /usr/local/bin/vcfbub \
    && cd ../ \
    && rm -rf vcfbub

RUN git clone --recursive https://github.com/vcflib/vcflib.git \
    && cd vcflib \
    && git checkout f8425d239e1bc406cdfe46a2e37f47ac3476dd8a \
    && mkdir -p build \
    && cd build \
    && cmake -DZIG=OFF -DCMAKE_BUILD_TYPE=Debug -DWFA_GITMODULE=ON .. && cmake --build . -- -j $(nproc) \
    && mv vcfwave /usr/local/bin/vcfwave \
    && mv vcfuniq /usr/local/bin/vcfuniq \
    && cd ../ \
    && rm -rf vcflib

# Additional tools
RUN git clone https://github.com/ekg/fastix.git \
    && cd fastix \
    && git pull \
    && git checkout 331c1159ea16625ee79d1a82522e800c99206834 \
    && cargo install --force --path . && \
    mv /root/.cargo/bin/fastix /usr/local/bin/fastix \
    && cd ../ \
    && rm -rf fastix

RUN git clone https://github.com/ekg/pafplot.git \
    && cd pafplot \
    && git pull \
    && git checkout 7dda24c0aeba8556b600d53d748ae3103ec85501 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/pafplot /usr/local/bin/ \
    && cd ../ \
    && rm -rf pafplot

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

COPY partition-before-pggb /usr/local/bin/partition-before-pggb
RUN chmod a+rx /usr/local/bin/partition-before-pggb


# MUMMER adjustments

RUN wget https://github.com/mummer4/mummer/releases/download/v4.0.0rc1/mummer-4.0.0rc1.tar.gz \
    && tar -xf mummer-4.0.0rc1.tar.gz && cd mummer-4.0.0rc1 && ./configure && make && make install && cd ../
RUN ldconfig

RUN wget https://github.com/RealTimeGenomics/rtg-tools/releases/download/3.12.1/rtg-tools-3.12.1-linux-x64.zip \
    && unzip rtg-tools-3.12.1-linux-x64.zip && sed -i 's/read -r -p "Would you like to enable automatic usage logging (y\/n)? " REPLY/REPLY="n"/g' /rtg-tools-3.12.1/rtg \
    && ln -s /rtg-tools-3.12.1/rtg /usr/local/bin/ && rtg help

# Install R package
RUN wget https://cran.r-project.org/src/contrib/Archive/data.table/data.table_1.15.2.tar.gz \
    && R CMD INSTALL data.table_1.15.2.tar.gz \
    && rm data.table_1.15.2.tar.gz

RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.0/bedtools.static \
    && mv bedtools.static /usr/local/bin/bedtools \
    && chmod +x /usr/local/bin/bedtools

# Set up Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python packages in virtual environment
RUN pip install multiqc==1.22.2 \
    && pip install igraph==0.11.5 \
    && pip install pycairo==1.26.1

# copy required scripts
COPY scripts/* /usr/local/bin/
COPY scripts /usr/local/bin/scripts/

# Hacky-way to easily get versioning info
COPY .git /usr/local/bin/

SHELL ["/bin/bash", "-c"]
