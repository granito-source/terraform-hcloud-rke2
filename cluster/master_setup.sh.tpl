#!/bin/bash -e

SUPERVISOR_URL=https://${lb_ip}:9345

umask 0077
mkdir -p /etc/rancher/rke2
cat <<EOF >/etc/rancher/rke2/config.yaml
%{ if initial }
#server: $SUPERVISOR_URL
%{ else }
server: $SUPERVISOR_URL
%{ endif }
token: "${cluster_token}"
cloud-provider-name: external
tls-san:
  - ${fqdn}
  - ${lb_ip}
  - ${lb_ext_v4}
  - ${lb_ext_v6}
EOF

mkdir -p /var/lib/rancher/rke2/server/manifests
cat <<EOF >/var/lib/rancher/rke2/server/manifests/rke2-ingress-nginx-config.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      nodeSelector:
        kubernetes.io/os: linux
        node-role.kubernetes.io/master: "true"
      config:
        use-forwarded-headers: "true"
EOF

umask 0022
curl -sSfL https://get.rke2.io/ | INSTALL_RKE2_METHOD=tar INSTALL_RKE2_TYPE=server INSTALL_RKE2_VERSION="${rke2_version}" sh -
systemctl enable rke2-server.service
%{ if !initial }
for ((i = 0; i < 30; i++)); do
    curl -ksfL -u 'node:${cluster_token}' \
        $SUPERVISOR_URL/v1-rke2/readyz >/dev/null 2>&1 && break
    sleep 10
done

sleep 30
%{ endif }
systemctl start rke2-server.service && \
    sed -i -e 's/^# *//' /etc/rancher/rke2/config.yaml
