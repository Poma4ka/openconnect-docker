#!/bin/bash

read vpn_addr
read vpn_user
read vpn_pass

if [ -z "$vpn_user" ] || [ -z "$vpn_pass" ] || [ -z "$vpn_addr" ]; then
  echo "Missing credentials" >> "$VPN_LOG_FILE"
  exit 1
fi

echo "$vpn_pass" | openconnect \
  --background \
  --timestamp \
  --syslog \
  --passwd-on-stdin \
  -u "$vpn_user" \
  -i "$VPN_TUN" \
  --non-inter \
  $VPN_ARGS \
  "$vpn_addr" >> "$VPN_LOG_FILE" 2>&1

for i in $(seq 1 "$VPN_CONNECT_TIMEOUT"); do
  if [ -z "$(pgrep openconnect)" ]; then
    pkill -P $$
    break
  fi

  if ip addr show "$VPN_TUN" > /dev/null 2>&1; then
    iptables -t nat -C POSTROUTING -o "$VPN_TUN" -j MASQUERADE >/dev/null 2>&1 || \
    iptables -t nat -A POSTROUTING -o "$VPN_TUN" -j MASQUERADE
    echo "VPN connected $vpn_addr" >> "$VPN_LOG_FILE"
    exit 0
  fi;

  sleep 1;
done;

echo "Failed to connect to VPN $vpn_addr" >> "$VPN_LOG_FILE"
exit 1