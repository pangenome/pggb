FROM debian:bullseye-slim AS binary

LABEL authors="Erik Garrison, Simon Heumos, Andrea Guarracino"
LABEL description="Preliminary docker image containing all requirements for pggb pipeline"
LABEL base_image="debian:buster-slim"
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
                       libatomic-ops-dev

RUN cd ../../
RUN git clone --recursive https://github.com/ekg/edyeet
RUN apt-get install -y \
                        autoconf \
                        libgsl-dev \
                        zlib1g-dev
RUN cd edyeet \
    && git pull \
    && git checkout 057b141 \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp build/bin/edyeet /usr/local/bin/edyeet

RUN cd ../
RUN git clone --recursive https://github.com/ekg/wfmash
RUN cd wfmash \
    && git pull \
    && git checkout 4bb309a \
    && bash bootstrap.sh \
    && bash configure \
    && make \
    && cp wfmash /usr/local/bin/wfmash

RUN cd ../
RUN git clone --recursive https://github.com/ekg/seqwish
RUN apt-get install -y \
                        build-essential
RUN cd seqwish \
    && git pull \
    && git checkout 9bbfa70 \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish

RUN cd ../
RUN git clone --recursive https://github.com/ekg/smoothxg
RUN cd smoothxg \
    && git pull \
    && git submodule update \
    && git checkout 9ed0d66 \
    && sed -i 's/-march=native/-march=haswell/g' deps/abPOA/CMakeLists.txt \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi

RUN apt-get install -y time

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

# Figure out the CPUINFO of the github action machine
RUN cat /proc/cpuinfo

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
