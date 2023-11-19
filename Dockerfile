ARG         base=ossrs/srs
ARG         version=

###

FROM        ${base}:${version}

RUN         apt-get update && \
            apt-get install -y \
                curl \
                jq
