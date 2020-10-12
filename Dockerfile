FROM debian:buster-slim AS binary

LABEL authors="Erik Garrison, Simon Heumos"
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
    && git checkout 4d77e10 \
    && bash bootstrap.sh \
    && bash configure \
    && make \
    && cp edyeet /usr/local/bin/edyeet

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
    && git checkout 04b587a \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg \
    && cp deps/odgi/bin/odgi /usr/local/bin/odgi

RUN apt-get install -y time

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
