#!/bin/bash
set -ex

confd -onetime -backend env

# if command starts with an option, prepend btcpd
if [ "${1:0:1}" = '-' ]; then
    set -- /usr/local/bin/btcpd "$@"
fi

exec "$@"
