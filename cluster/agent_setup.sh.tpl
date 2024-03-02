#!/bin/bash -e

SUPERVISOR_URL=https://${lb_ip}:9345

umask 0077
mkdir -p /etc/rancher/rke2
cat <<EOF >/etc/rancher/rke2/config.yaml
server: $SUPERVISOR_URL
token: "${cluster_token}"
EOF

umask 0022
curl -sSfL https://get.rke2.io/ | INSTALL_RKE2_METHOD=tar INSTALL_RKE2_TYPE=agent INSTALL_RKE2_VERSION="${rke2_version}" sh -

for ((i = 0; i < 30; i++)); do
    curl -ksfL -u 'node:${cluster_token}' \
        $SUPERVISOR_URL/v1-rke2/readyz >/dev/null 2>&1 && break
    sleep 10
done

sleep 30

systemctl enable rke2-agent.service
systemctl start rke2-agent.service || true
