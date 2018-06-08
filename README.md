# docker-btcprivate

## Build
```
docker build -t BitcoinPrivate:1.0.12-1 .
```

## Run
```
docker run \
    --init \
    -itd \
    --restart unless-stopped \
    --name BitcoinPrivate \
    -v BitcoinPrivate-data:/data \
    -p 7932:7932 \
    -p 7933:7933 \
    BitcoinPrivate:1.0.12-1 \
    -printtoconsole \
    -upnp \
    -addnode=dnsseed.btcprivate.org
```

## List Commands (From Host)
```
docker exec -it BitcoinPrivate \
    btcp-cli help
```

## List Commands (Inside Container)
```
docker exec -it BitcoinPrivate bash
btcp-cli help
exit
```
