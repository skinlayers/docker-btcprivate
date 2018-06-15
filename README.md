# docker-btcprivate

## Build
```
docker build -t BitcoinPrivate:latest .
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
    BitcoinPrivate:latest \
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
