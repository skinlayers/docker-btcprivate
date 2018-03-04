#!/bin/bash
set -ex

# if command starts with an option, prepend btcpd
if [ "${1:0:1}" = '-' ]; then
    set -- /usr/local/bin/btcpd "$@"
fi

exec "$@"
