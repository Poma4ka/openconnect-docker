#!/bin/bash
echo "Content-type: text/html"
echo ""

read -n "$CONTENT_LENGTH" POST_DATA

if [ -n "$POST_DATA" ]; then
    user=$(echo "$POST_DATA" | sed -n 's/.*VPN_USER=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
    pass=$(echo "$POST_DATA" | sed -n 's/.*VPN_PASS=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
    addr=$(echo "$POST_DATA" | sed -n 's/.*VPN_ADDR=\([^&]*\).*/\1/p' | sed 's/%\([0-9A-F][0-9A-F]\)/\\x\1/g;s/+/ /g' | xargs -0 echo -e)
fi

pid_file="/run/connect_pid"

if [ -f "$pid_file" ]; then
  old_pid=$(cat "$pid_file")
  pkill -9 -P "$old_pid" 2>/dev/null
  rm -f "$pid_file"
fi

echo "" > "$VPN_LOG_FILE"

if echo -e "$addr\n$user\n$pass" | /start.sh; then
  {
    while true; do
      if ! pgrep -x openconnect > /dev/null; then
        echo -e "$addr\n$user\n$pass" | /start.sh > /dev/null 2>&1
      fi

      sleep 1
    done
  } >/dev/null 2>&1 </dev/null &

  echo "$!" > "$pid_file"
fi

echo "<html><head><meta http-equiv='refresh' content='0;url=/'></head></html>"