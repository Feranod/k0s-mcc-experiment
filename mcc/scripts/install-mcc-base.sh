#!/usr/bin/env bash
set -euo pipefail

echo "=== MCC base installer experiment ==="

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

KUBECTL="/usr/local/bin/k0s kubectl --kubeconfig=$HOME/.kube/config"
HELM="/usr/local/bin/helm"

POSTGRES_RELEASE="mcc-postgres"
POSTGRES_CHART="$ROOT_DIR/mcc/helm/mcc-postgres"

LIQUIBASE_RELEASE="mcc-liquibase"
LIQUIBASE_CHART="$ROOT_DIR/mcc/helm/mcc-liquibase"

NAMESPACE="mcc-db"

echo
echo "Checking tools..."
$KUBECTL version --client
$HELM version

echo
echo "Installing/upgrading PostgreSQL..."
$HELM upgrade --install "$POSTGRES_RELEASE" "$POSTGRES_CHART"

echo
echo "Waiting for PostgreSQL pod to be ready..."
$KUBECTL wait \
  --namespace "$NAMESPACE" \
  --for=condition=ready pod \
  --selector app=mcc-postgres \
  --timeout=180s

echo
echo "PostgreSQL status:"
$KUBECTL get all -n "$NAMESPACE"

echo
echo "Preparing Liquibase job..."
if $HELM status "$LIQUIBASE_RELEASE" >/dev/null 2>&1; then
  echo "Previous Liquibase release exists, uninstalling it..."
  $HELM uninstall "$LIQUIBASE_RELEASE"
fi

$KUBECTL delete job "$LIQUIBASE_RELEASE" -n "$NAMESPACE" --ignore-not-found
$KUBECTL delete pod -n "$NAMESPACE" -l app=mcc-liquibase --ignore-not-found

echo
echo "Running Liquibase migration..."
$HELM install "$LIQUIBASE_RELEASE" "$LIQUIBASE_CHART"

echo
echo "Waiting for Liquibase job to complete..."
$KUBECTL wait \
  --namespace "$NAMESPACE" \
  --for=condition=complete job/mcc-liquibase \
  --timeout=180s

echo
echo "Liquibase logs:"
$KUBECTL logs -n "$NAMESPACE" -l app=mcc-liquibase

echo
echo "Final Helm releases:"
$HELM list -A

echo
echo "Final MCC DB namespace state:"
$KUBECTL get all -n "$NAMESPACE"

echo
echo "=== MCC base installer experiment finished successfully ==="