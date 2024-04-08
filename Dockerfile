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
                       samtools \
                       wget \
                       pip \
                       libcairo2-dev \
                       unzip \
                       parallel \
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
    && git checkout d7b696087f634f25e4b3de7dd521e1c4bfa3cf0e \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=sandybridge/g' src/common/wflign/deps/WFA2-lib/Makefile \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    # Libraries aren't getting installed
    && cp build/lib/libwfa2cpp.so.0 /usr/local/lib/ \
    && cp build/lib/libwfa2cpp.so /usr/local/lib/ \
    && cp build/lib/libwfa2.so.0 /usr/local/lib/ \
    && cp build/lib/libwfa2.so /usr/local/lib/ \
    && cd ../ \
    && rm -rf wfmash

RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout 75e807c7e3e92c84068cd3c2c7394eb313732a0a \
    && git submodule update --init --recursive \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -DEXTRA_FLAGS='-march=sandybridge -Ofast' -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../ \
    && rm -rf seqwish

RUN git clone --recursive https://github.com/pangenome/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout e91d6b358caa8c5adff9cd5e9b97c458f35d7600 \
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
    && git checkout d630eb7d9827340f5f292e57cb3cb5e31e6f86f0 \
    && cargo install --force --path . \
    && mv /root/.cargo/bin/gfaffix /usr/local/bin/gfaffix \
    && cd ../ \
    && rm -rf GFAffix

RUN pip install multiqc==1.21

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
    && git checkout 7c1a31a430d339adcb9a0c2fd3fd02d3b30e3549 \
    && mkdir -p build \
    && cd build \
    && cmake -DZIG=OFF -DCMAKE_BUILD_TYPE=Debug .. && cmake --build . -- -j $(nproc) \
    && mv vcfwave /usr/local/bin/vcfwave \
    && mv vcfuniq /usr/local/bin/vcfuniq \
    && cd ../ \
    && rm -rf vcflib

# Community detection dependencies
RUN pip install igraph==0.10.4
RUN pip install pycairo==1.23.0

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

# Install base R
# NOTE: we might have to go the conda way on the long run
# https://www.reddit.com/r/Rlanguage/comments/oi31xn/installing_r41_on_debian_bullseye_testing/
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key B8F25A8A73EACF41 \
    && echo "deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/" > /etc/apt/sources.list.d/r-packages.list \
    && apt update \
    && apt install -y r-base \
    && apt-get clean \
    && apt-get purge  \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://cran.r-project.org/src/contrib/Archive/data.table/data.table_1.14.8.tar.gz \
    && R CMD INSTALL data.table_1.14.8.tar.gz

RUN wget https://github.com/arq5x/bedtools2/releases/download/v2.31.0/bedtools.static \
    && mv bedtools.static /usr/local/bin/bedtools \
    && chmod +x /usr/local/bin/bedtools

# copy required scripts
COPY scripts/* /usr/local/bin/
COPY scripts /usr/local/bin/scripts/

# Hacky-way to easily get versioning info
COPY .git /usr/local/bin/

SHELL ["/bin/bash", "-c"]
