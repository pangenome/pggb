FROM debian:bullseye-slim AS binary

LABEL authors="Erik Garrison, Simon Heumos, Andrea Guarracino"
LABEL description="Preliminary docker image containing all requirements for pggb pipeline"
LABEL base_image="debian:bullseye-slim"
LABEL software="pggb"
LABEL about.home="https://github.com/pangenome/pggb"
LABEL about.license="SPDX:MIT"

# odgi's dependencies
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
                       build-essential \
                       time \
                       pigz
                        
RUN git clone --recursive https://github.com/ekg/wfmash \
    && cd wfmash \
    && git pull \
    && git checkout d1f3cb6 \
    && git submodule update --init --recursive \
    && sed -i 's/-mcx16 //g' CMakeLists.txt \
    && sed -i 's/-march=native //g' CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/deps/WFA/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/deps/WFA/CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/deps/wflambda/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/deps/wflambda/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    && cd ../

RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout d29ea57 \
    && git submodule update --init --recursive \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../

RUN git clone --recursive https://github.com/ekg/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout 005761d \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
    && sed -i 's/-mcx16 //g' deps/WFA/CMakeLists.txt \
    && sed -i 's/-march=native //g' deps/WFA/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi

RUN apt-get install -y pip

RUN cd ../
RUN git clone https://github.com/Imipenem/MultiQC
RUN cd MultiQC \
    && git checkout 5684a0c \
    && pip install .

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
