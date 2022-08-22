ARG         base=ubuntu:20.04

###

FROM        ${base} as srs

ARG         version=
ARG         repo=ossrs/srs
ARG         jobs=8
ARG         MAKEFLAGS=-j${jobs}

ENV         MAKEFLAGS=${MAKEFLAGS}

RUN         apt-get update && \
            apt-get install -y \
                gcc \
                g++ \
                make \
                patch \
                unzip \
                perl \
                git \
                tcl \
                cmake \
                pkg-config \
                wget && \
            wget -O - https://github.com/${repo}/archive/refs/tags/v${version}.tar.gz | tar xz

WORKDIR     srs-${version}/trunk

#             # HACK: Increase RTMP URL length to 256bytes
# RUN         sed -i 's|char url_sz\[128\];|char url_sz\[256\];|g' src/srt/srt_to_rtmp.cpp

RUN         ./configure \
                --jobs=${jobs} \
                --srt=on \
                --hls=off \
                --dvr=off \
                --transcode=off \
                --rtc=off \
                --ffmpeg-fit=off \
                --log-verbose=on \
                --log-info=on \
                --log-trace=on && \
            make && \
            make install

###

FROM        ${base}

# ENV         LIBRARY_PATH=/usr/local/lib64
# ENV         LD_LIBRARY_PATH=/usr/local/lib64

WORKDIR     /usr/local/srs

ENTRYPOINT  ["./objs/srs"]
CMD         ["-c", "./conf/docker.conf"]

EXPOSE      1935/tcp 1985/tcp 8080/tcp 8000/udp 10080/udp

COPY        --from=srs /usr/local/srs /usr/local/srs