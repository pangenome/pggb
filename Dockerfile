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
                       autoconf \
                       libgsl-dev \
                       zlib1g-dev \
                       libzstd-dev \
                       libatomic-ops-dev \
                       autoconf \
                       libgsl-dev \
                       zlib1g-dev \
                       build-essential \
                       time \
                       pigz
                        
RUN git clone --recursive https://github.com/ekg/edyeet \
    && cd edyeet \
    && git pull \
    && git checkout 03a28af \
    && git submodule update --init --recursive \
    && sed -i 's/-mcx16 //g' CMakeLists.txt \
    && sed -i 's/-march=native //g' CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/edyeet /usr/local/bin/edyeet \
    && cd ../

RUN git clone --recursive https://github.com/ekg/wfmash \
    && cd wfmash \
    && git pull \
    && git checkout a932d64 \
    && git submodule update --init --recursive \
    && sed -i 's/-mcx16 //g' CMakeLists.txt \
    && sed -i 's/-march=native //g' CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/wfmash /usr/local/bin/wfmash \
    && cd ../

RUN git clone --recursive https://github.com/urbanslug/mashz
RUN cd mashz \
    && git pull \
    && git checkout 68ec4b6 \
    && sed -i 's/-mcx16 //g' CMakeLists.txt \
    && sed -i 's/-march=native //g' CMakeLists.txt \
    && sed -i 's/-mcx16 //g' src/common/wflign/CMakeLists.txt \
    && sed -i 's/-march=native //g' src/common/wflign/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/mashz /usr/local/bin/mashz

RUN cd ../
RUN git clone --recursive https://github.com/ekg/seqwish \
    && cd seqwish \
    && git pull \
    && git checkout cbab96f \
    && git submodule update --init --recursive \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish \
    && cd ../

RUN git clone --recursive https://github.com/ekg/smoothxg \
    && cd smoothxg \
    && git pull \
    && git checkout 669d92b \
    && git submodule update --init --recursive \
    && sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi

RUN apt-get install -y pip

RUN cd ../
RUN git clone https://github.com/Imipenem/MultiQC
RUN cd MultiQC \
    && git checkout adacbcb490baa5304443ea8532e7fc6964ecc358 \
    && pip install .

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
