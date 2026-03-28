FROM alpine:latest

RUN set -xe \
    && apk add --no-cache \
      openconnect \
      bash \
      jq \
      busybox-extras \
      iptables

COPY filesystem /
RUN chmod +x /entrypoint.sh /var/www/cgi-bin/connect.sh /var/www/cgi-bin/index.sh

ENV VPN_PORT="80"
ENV VPN_TUN="tun0"
ENV VPN_LOG_FILE="/var/log/openconnect.log"
ENV VPN_CONNECT_TIMEOUT="30"

# Required variables, should be passed to container, Or filled in form
ENV VPN_ADDR=""
ENV VPN_USER=""
ENV VPN_PASS=""
ENV VPN_ARGS=""

CMD ["/bin/bash", "/entrypoint.sh"]