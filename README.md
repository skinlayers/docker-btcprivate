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
    -rpcbind=127.0.0.1 \
    -rpcuser=btcprivaterpc \
    -rpcpassword=CHANGE_ME \
    -rpcallowip=127.0.0.1 \
    -addnode=dnsseed.btcprivate.org
```

## List Commands (From Host)
```
docker exec -it BitcoinPrivate \
    btcp-cli -rpcuser=btcprivaterpc -rpcpassword=CHANGE_ME help
```

## List Commands (Inside Container)
```
docker exec -it BitcoinPrivate bash
btcp-cli -rpcuser=btcprivaterpc -rpcpassword=CHANGE_ME help
exit
```
