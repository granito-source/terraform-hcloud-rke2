#!/bin/bash -e

apt-get update -y
apt-get install -y nfs-common
curl -sSfL https://get.rke2.io/ | \
    INSTALL_RKE2_METHOD=tar \
    INSTALL_RKE2_TYPE=agent \
    INSTALL_RKE2_VERSION="${rke2_version}" sh -

systemctl stop multipathd.socket
systemctl disable multipathd.socket
systemctl stop multipathd.service
systemctl disable multipathd.service
systemctl enable rke2-agent.service

cat <<EOF >/etc/modules-load.d/dm-crypt.conf
dm-crypt
EOF
modprobe dm-crypt

SUPERVISOR_URL=https://${lb_ip}:9345

for ((i = 0; i < 30; i++)); do
    curl -ksSfL -u 'node:${token}' $SUPERVISOR_URL/v1-rke2/readyz && break
    sleep 10
done

sleep 30

NODE_IP=`ip route get ${lb_ip} | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}'`

umask 0077

mkdir -p /etc/rancher/rke2
cat <<EOF >/etc/rancher/rke2/config.yaml
server: $SUPERVISOR_URL
token: "${token}"
node-ip: $NODE_IP
cloud-provider-name: external
EOF

umask 0022

systemctl start rke2-agent.service || true
