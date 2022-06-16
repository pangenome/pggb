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
                       g++ \
                       python3-dev \
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
                       libcairo2-dev

RUN git clone --recursive https://github.com/waveygang/wfmash \
    && cd wfmash \
    && git pull \
    && git checkout 5321ea68e8216e835aa1f70361d2ee24700e9a43 \
    && git submodule update --init --recursive \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    && cd ../

RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout f209482924bbb7763d927029ee63cd16c5ddb44c \
    && git submodule update --init --recursive \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../

RUN git clone --recursive https://github.com/pangenome/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout d32db9543427adcb9b762aced8ea3478cc6a4455 \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=haswell/g' deps/spoa/CMakeLists.txt \
    && sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
    && cmake -H. -DCMAKE_BUILD_TYPE=Generic -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi

# Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo --help

RUN git clone https://github.com/marschall-lab/GFAffix.git \
    && cd GFAffix \
    && git pull \
    && git checkout ae153555fa9aa29fbc6057a9bcda1bc6597170d1 \
    && cargo install --force --path . && mv /root/.cargo/bin/gfaffix /usr/local/bin/gfaffix

RUN pip install multiqc==1.11

RUN wget https://github.com/vgteam/vg/releases/download/v1.41.0/vg && chmod +x vg && mv vg /usr/local/bin/vg

# Community detection dependencies
RUN pip install igraph==0.9.10
RUN pip install pycairo==1.16.2

# Additional tools
RUN git clone https://github.com/ekg/fastix.git \
    && cd fastix \
    && git pull \
    && git checkout 331c1159ea16625ee79d1a82522e800c99206834 \
    && cargo install --force --path . && mv /root/.cargo/bin/fastix /usr/local/bin/fastix

RUN git clone https://github.com/ekg/pafplot.git \
    && cd pafplot \
    && git pull \
    && git checkout 7dda24c0aeba8556b600d53d748ae3103ec85501 \
    && cargo install --force --path . && mv /root/.cargo/bin/pafplot /usr/local/bin/pafplot

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
