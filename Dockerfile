FROM buildpack-deps:stretch as btcp-builder
LABEL maintainer="skinlayers@gmail.com"

ARG SPROUT_PKEY_NAME=sprout-proving.key
ARG SPROUT_PKEY_URL=https://z.cash/downloads/$SPROUT_PKEY_NAME
ARG SPROUT_PKEY_SHA256=8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7
ARG SPROUT_PKEY_SHA256_FILE=sprout-proving-sha256.txt
RUN set -eu && \
    curl -L "$SPROUT_PKEY_URL" -o "$SPROUT_PKEY_NAME" && \
    echo "$SPROUT_PKEY_SHA256  $SPROUT_PKEY_NAME" \
        > "$SPROUT_PKEY_SHA256_FILE" && \
    sha256sum -c "$SPROUT_PKEY_SHA256_FILE"

ARG SPROUT_VKEY_NAME=sprout-verifying.key
ARG SPROUT_VKEY_URL=https://z.cash/downloads/$SPROUT_VKEY_NAME
ARG SPROUT_VKEY_SHA256=4bd498dae0aacfd8e98dc306338d017d9c08dd0918ead18172bd0aec2fc5df82
ARG SPROUT_VKEY_SHA256_FILE=sprout-verifying-sha256.txt
RUN curl -L "$SPROUT_VKEY_URL" -o "$SPROUT_VKEY_NAME" && \
    echo "$SPROUT_VKEY_SHA256  $SPROUT_VKEY_NAME" \
        > "$SPROUT_VKEY_SHA256_FILE" && \
    sha256sum -c "$SPROUT_VKEY_SHA256_FILE"

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
ARG GIT_BRANCH=master
ARG GIT_COMMIT=4045199486c8182500572447b659209b5d274994

RUN git clone -b "$GIT_BRANCH" --single-branch "$GIT_URL" && \
    cd BitcoinPrivate && \
    git reset --hard "$GIT_COMMIT" && \
    ./btcputil/build.sh -j$(nproc)


FROM debian:stretch
LABEL maintainer="skinlayers@gmail.com"

ARG RUNTIME_DEPENDENCIES=" \
        libgomp1 \
        libzmq5 \
"

COPY --from=btcp-builder /sprout-proving.key /
COPY --from=btcp-builder /sprout-verifying.key /
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
