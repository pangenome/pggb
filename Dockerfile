FROM debian:bullseye-slim AS binary

LABEL authors="Erik Garrison, Simon Heumos, Andrea Guarracino"
LABEL description="Preliminary docker image containing all requirements for pggb pipeline"
LABEL base_image="debian:bullseye-slim"
LABEL software="pggb"
LABEL about.home="https://github.com/pangenome/pggb"
LABEL about.license="SPDX:MIT"

# dependencies
RUN apt-get update \
    && apt-get install -y \
                       git \
                       bash \
                       cmake \
                       make \
                       g++-11 \
                       python3-dev \
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
                       bcftools \
                       samtools \
                       wget \
                       pip \
                       libcairo2-dev \
    && apt-get clean \
    && apt-get purge  \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/waveygang/wfmash \
    && cd wfmash \
    && git pull \
    && git checkout cb0ce952a9bec3f2c8c78b98679375e5275e05db \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=sandybridge/g' src/common/wflign/deps/WFA2-lib/Makefile \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    && cd ../ \
    && rm -rf wfmash

RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout f362f6f5ea89dbb6a0072a8b8ba215e663301d33 \
    && git submodule update --init --recursive \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../ \
    && rm -rf seqwish

RUN git clone --recursive https://github.com/pangenome/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout a8a0e9ebc24e0915902ca412598ab67fdb266719 \
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
    && git checkout ff282ca53ed53337e22eabc3b41e86df6ca0dc66 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/gfaffix /usr/local/bin/gfaffix \
    && cd ../ \
    && rm -rf GFAffix

RUN pip install multiqc==1.13

RUN wget https://github.com/vgteam/vg/releases/download/v1.40.0/vg && chmod +x vg && mv vg /usr/local/bin/vg

RUN git clone https://github.com/pangenome/vcfbub \
    && cd vcfbub \
    && git pull \
    && git checkout 26a1f0cb216a423f8547c4ad0e0ce38cb9d324b9 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/vcfbub /usr/local/bin/vcfbub \
    && cd ../ \
    && rm -rf vcfbub

RUN git clone --recursive https://github.com/vcflib/vcflib.git \
    && cd vcflib \
    && git checkout 4f2bce873bc520449ec549f36aaaad65bace51ca \
    && mkdir -p build \
    && cd build \
    && cmake -DZIG=OFF -DCMAKE_BUILD_TYPE=Debug .. && cmake --build . -- -j $(nproc) \
    && mv vcfwave /usr/local/bin/vcfwave \
    && cd ../ \
    && rm -rf vcflib

# Community detection dependencies
RUN pip install igraph==0.10.2
RUN pip install pycairo==1.20.1

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

# Hacky-way to easily get versioning info
COPY .git /usr/local/bin/

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
