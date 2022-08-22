ARG         base=ubuntu:22.04

###

FROM        ${base} as srs

ARG         version=
ARG         repo=ossrs/srs
ARG         jobs=8
ARG         MAKEFLAGS=-j${jobs}

ENV         MAKEFLAGS=${MAKEFLAGS}
ENV         DEBIAN_FRONTEND=noninteractive
ENV         TZ=Etc/UTC

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

WORKDIR     /usr/local/srs

ENTRYPOINT  ["./objs/srs"]
CMD         ["-c", "conf/docker.conf"]

EXPOSE      1935/tcp 1985/tcp 8080/tcp 8000/udp 10080/udp

COPY        --from=srs /usr/local/srs /usr/local/srs