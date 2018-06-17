FROM buildpack-deps:bionic as btcp-builder
LABEL maintainer="skinlayers@gmail.com"

ARG BUILD_DEPENDENCIES=" \
        autoconf \
        automake \
        bsdmainutils \
        build-essential \
        g++-multilib \
        pkg-config \
        libc6-dev \
        libtool \
        m4 \
        ncurses-dev \
        python \
        unzip \
        wget \
        zlib1g-dev \
        libzmq5-dev \
"

RUN apt-get update && \
    apt-get -y install $BUILD_DEPENDENCIES

ARG GIT_URL=https://github.com/BTCPrivate/BitcoinPrivate.git

RUN git clone -b master --single-branch "$GIT_URL" && \
    cd BitcoinPrivate && \
    ./btcputil/build.sh -j$(nproc)


FROM ubuntu:bionic
LABEL maintainer="skinlayers@gmail.com"

ARG RUNTIME_DEPENDENCIES=" \
        libgomp1 \
        libzmq5 \
"

COPY --from=skinlayers/docker-zcash-sprout-keys /sprout-proving.key /
COPY --from=skinlayers/docker-zcash-sprout-keys /sprout-verifying.key /
COPY ./docker-entrypoint.sh /

ARG BUILDER_PATH=/BitcoinPrivate/src
COPY --from=btcp-builder $BUILDER_PATH/btcp-cli /usr/local/bin
COPY --from=btcp-builder $BUILDER_PATH/btcpd /usr/local/bin

RUN set -eu && \
    adduser --system -u 400 --group --home /data btcprivate && \
    mkdir -m 0700 /data/.btcprivate && \
    chmod +x /docker-entrypoint.sh && \
    apt-get update && \
    apt-get -y install $RUNTIME_DEPENDENCIES && \
    rm -r /var/lib/apt/lists/*

COPY --from=btcp-builder /BitcoinPrivate/contrib/debian/examples/btcprivate.conf /data/.btcprivate

RUN chmod 0600 /data/.btcprivate/btcprivate.conf && \
    chown -R btcprivate:btcprivate /data/.btcprivate

USER btcprivate

WORKDIR /data

RUN mkdir -m 0700 .zcash-params && \
    ln -s /sprout-proving.key .zcash-params/sprout-proving.key && \
    ln -s /sprout-verifying.key .zcash-params/sprout-verifying.key

VOLUME ["/data"]

EXPOSE 7932 7933

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/local/bin/btcpd", "-printtoconsole"]
