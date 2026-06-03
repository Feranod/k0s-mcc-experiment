#!/usr/bin/env bash
set -euo pipefail

echo "=== MCC bootstrap ==="

K0S="/usr/local/bin/k0s"

echo
echo "Checking k0s binary..."

if [ ! -x "$K0S" ]; then
    echo "ERROR: k0s binary not found"
    exit 1
fi

echo "OK"

echo
echo "Creating kubeconfig..."

mkdir -p "$HOME/.kube"

sudo cp /var/lib/k0s/pki/admin.conf "$HOME/.kube/config"
sudo chown "$(id -u)":"$(id -g)" "$HOME/.kube/config"

chmod 600 "$HOME/.kube/config"

echo
echo "Configuring aliases..."

grep -v 'alias kubectl=' ~/.bashrc > ~/.bashrc.tmp || true
mv ~/.bashrc.tmp ~/.bashrc

grep -v 'alias helm=' ~/.bashrc > ~/.bashrc.tmp || true
mv ~/.bashrc.tmp ~/.bashrc

echo 'alias kubectl="/usr/local/bin/k0s kubectl --kubeconfig=$HOME/.kube/config"' >> ~/.bashrc
echo 'alias helm="/usr/local/bin/helm --kubeconfig=$HOME/.kube/config"' >> ~/.bashrc

echo
echo "Testing cluster access..."

/usr/local/bin/k0s kubectl \
  --kubeconfig="$HOME/.kube/config" \
  get nodes

echo
echo "Bootstrap finished successfully."