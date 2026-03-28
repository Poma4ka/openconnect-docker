#!/bin/bash
echo "Content-type: text/html"
echo ""

read -n "$CONTENT_LENGTH" POST_DATA

if [ -n "$POST_DATA" ]; then
    user=$(echo "$POST_DATA" | sed -n 's/.*VPN_USER=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
    pass=$(echo "$POST_DATA" | sed -n 's/.*VPN_PASS=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
    addr=$(echo "$POST_DATA" | sed -n 's/.*VPN_ADDR=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)

    if [ -n "$user" ]; then
      export VPN_USER="$user"
    fi

    if [ -n "$pass" ]; then
      export VPN_PASS="$pass"
    fi

    if [ -n "$addr" ]; then
      export VPN_ADDR="$addr"
    fi
fi

if [ -n "$VPN_USER" ] && [ -n "$VPN_PASS" ] && [ -n "$VPN_ADDR" ]; then
    pkill openconnect
    sleep 1

    echo "" > "$VPN_LOG_FILE"

    echo "$VPN_PASS" | openconnect \
      --background \
      --timestamp \
      --syslog \
      --passwd-on-stdin \
      -u "$VPN_USER" \
      -i "$VPN_TUN" \
      --non-inter \
      $VPN_ARGS \
      "$VPN_ADDR" > "$VPN_LOG_FILE" 2>&1

    for i in $(seq 1 "$VPN_CONNECT_TIMEOUT"); do
      if [ -z "$(pgrep openconnect)" ]; then
        break;
      fi

      if ip addr show "$VPN_TUN" > /dev/null 2>&1; then
        iptables -t nat -C POSTROUTING -o "$VPN_TUN" -j MASQUERADE >/dev/null 2>&1 || \
        iptables -t nat -A POSTROUTING -o "$VPN_TUN" -j MASQUERADE;
        break;
      fi;
      sleep 1;
    done;
fi

echo "<html><head><meta http-equiv='refresh' content='0;url=/'></head></html>"