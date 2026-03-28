#!/bin/bash

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
  pkill httpd
  pkill openconnect
  echo "Stopped"
  exit 0
}

trap stop SIGINT SIGTERM

httpd -f -p 80 -h /var/www &

PID="$!"

echo "Started. Press Ctrl+C to stop."

wait $PID