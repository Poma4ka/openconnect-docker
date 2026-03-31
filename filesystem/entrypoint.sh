#!/bin/bash

if [ -z "$VPN_PORT" ]; then
    echo "VPN_PORT required" && exit 1;
fi

if [ -z "$VPN_TUN" ]; then
    echo "VPN_TUN required" && exit 1;
fi

if [ -z "$VPN_LOG_FILE" ]; then
    echo "VPN_LOG_FILE required" && exit 1;
fi

if [ -z "$VPN_CONNECT_TIMEOUT" ]; then
    echo "VPN_CONNECT_TIMEOUT required" && exit 1;
fi

stop() {
  echo "Stopping"
  pkill -9 -P $(pgrep httpd)
  echo "Stopped"
}

trap stop SIGINT SIGTERM

httpd -f -p $VPN_PORT -h /var/www &

wait $!