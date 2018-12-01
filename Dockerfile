FROM debian:stretch-slim
MAINTAINER Stefan Großmann <39296252+stgrossmann@users.noreply.github.com>

RUN set -ex \
  && apt-get update \
  && apt-get install -qq --no-install-recommends dirmngr ca-certificates wget \
  && rm -rf /var/lib/apt/lists/*

ARG BTC_VERSION=0.17.0.1
ARG BTC_URL=https://bitcoin.org/bin/bitcoin-core-0.17.0.1/bitcoin-0.17.0.1-x86_64-linux-gnu.tar.gz
ARG BTC_SHA256=6ccc675ee91522eee5785457e922d8a155e4eb7d5524bd130eb0ef0f0c4a6008

RUN set -ex \
  && cd /tmp \
  && wget -qO bitcoin-${BTC_VERSION}.tar.gz ${BTC_URL} \
  && echo ${BTC_SHA256} bitcoin-${BTC_VERSION}.tar.gz | sha256sum -c - \
  && tar -xzvf bitcoin-${BTC_VERSION}.tar.gz -C /usr/local --strip-components=1 --exclude=*-qt \
  && rm -rf /tmp/*

RUN groupadd -r -g 555 bitcoin && useradd -r -m -u 555 -g bitcoin bitcoin
ENV DATADIR /data

RUN mkdir "$DATADIR" \
  && chown -R 555:555 "$DATADIR" \
  && ln -sfn "$DATADIR" /home/bitcoin/.bitcoin \
  && chown -h 555:555 /home/bitcoin/.bitcoin

VOLUME /data

EXPOSE 8332 8333 18332 18333 28332 28333

USER 555:555
ENTRYPOINT ["bitcoind"]
