FROM debian:stretch-slim
MAINTAINER Stefan Großmann <39296252+stgrossmann@users.noreply.github.com>

RUN set -ex \
  && apt-get update \
  && apt-get install -qq --no-install-recommends dirmngr ca-certificates wget \
  && rm -rf /var/lib/apt/lists/*

ARG BTC_VERSION=0.20.1
ARG BTC_URL=https://bitcoincore.org/bin/bitcoin-core-0.20.1/bitcoin-0.20.1-x86_64-linux-gnu.tar.gz
ARG BTC_SHA256=376194f06596ecfa40331167c39bc70c355f960280bd2a645fdbf18f66527397

RUN set -ex \
  && cd /tmp \
  && wget -qO bitcoin-${BTC_VERSION}.tar.gz ${BTC_URL} \
  && echo ${BTC_SHA256} bitcoin-${BTC_VERSION}.tar.gz | sha256sum -c - \
  && tar -xzvf bitcoin-${BTC_VERSION}.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
  && rm -rf /tmp/*

RUN groupadd -g 1000 bitcoin && useradd -m -u 1000 -g bitcoin -s /bin/sh bitcoin

USER bitcoin

RUN mkdir -p /home/bitcoin/.bitcoin

VOLUME /home/bitcoin/.bitcoin

#8332 - jsonrpc, 8333 - bitcoind p2p, 18332 - testnet jsonrpc, 18333 - testnet bitcoind p2p
EXPOSE 8332 8333 18332 18333

ENTRYPOINT ["bitcoind"]
