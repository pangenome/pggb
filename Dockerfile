FROM debian:buster-slim AS binary

RUN apt-get update \
    && apt-get install -y \
                       git \
                       bash \
                       cmake \
                       make \
                       g++ \
                       python3-dev \
                       libatomic-ops-dev
RUN git clone --recursive https://github.com/vgteam/odgi.git
RUN cd odgi \
    && cmake -H. -Bbuild \
    && cmake --build build -- -j $(nproc) \
    && cd build \
    && cp ../bin/odgi /usr/local/bin/odgi 

RUN cd ../../
RUN git clone --recursive https://github.com/ekg/edyeet
RUN apt-get install -y \
                        autoconf \
                        libgsl-dev \
                        zlib1g-dev
RUN cd edyeet \
    && bash bootstrap.sh \
    && bash configure \
    && make \
    && cp edyeet /usr/local/bin/edyeet

RUN cd ../
RUN git clone --recursive https://github.com/ekg/seqwish
RUN apt-get install -y \
                        build-essential
RUN cd seqwish \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/seqwish /usr/local/bin/seqwish

RUN cd ../
RUN git clone --recursive https://github.com/ekg/smoothxg
RUN cd smoothxg \
    && cmake -H. -Bbuild && cmake --build build -- -j $(nproc) \
    && cp bin/smoothxg /usr/local/bin/smoothxg

RUN apt-get install -y time

COPY pggb /usr/local/bin/pggb
RUN chmod 777 /usr/local/bin/pggb

LABEL base_image="debian:buster-slim"
LABEL software="pggb"
LABEL about.home="https://github.com/pangenome/pggb"
LABEL about.license="SPDX:MIT"

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]