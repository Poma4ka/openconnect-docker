# openconnect-docker

## Запуск

Предоставлены минимальные конфигурации запуска с разными сетевыми драйверами

### macvlan (Для сильных)

```bash
docker network create -d macvlan --subnet=192.168.1.0/24 --gateway=192.168.1.1 -o parent=eth0 my_net

docker run -d \
  --name openconnect-faithnode-client \
  --privileged \
  --cap-add=NET_ADMIN \
  --sysctl net.ipv4.ip_forward=1 \
  --network my_net \
  --ip 192.168.1.11 \
  -e VPN_ADDR=vpn.example.com \
  -e VPN_USER=user \
  ghcr.io/poma4ka/openconnect-docker:latest
```

### host (Для слабых)

```bash
docker run -d \
  --privileged \
  --cap-add=NET_ADMIN \
  --sysctl net.ipv4.ip_forward=1 \
  --network host \
  -e VPN_PORT=3000 \
  ghcr.io/poma4ka/openconnect-docker:latest
```