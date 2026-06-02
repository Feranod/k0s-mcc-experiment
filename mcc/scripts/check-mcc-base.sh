#!/usr/bin/env bash
set -euo pipefail

echo "=== MCC base status check ==="

KUBECTL="/usr/local/bin/k0s kubectl --kubeconfig=$HOME/.kube/config"
HELM="/usr/local/bin/helm"

NAMESPACE="mcc-db"

echo
echo "Kubernetes nodes:"
$KUBECTL get nodes

echo
echo "Helm releases:"
$HELM list -A

echo
echo "Namespace state:"
$KUBECTL get namespace "$NAMESPACE"

echo
echo "MCC DB resources:"
$KUBECTL get all -n "$NAMESPACE"

echo
echo "PostgreSQL service:"
$KUBECTL get svc mcc-postgres -n "$NAMESPACE"

echo
echo "PostgreSQL pod:"
$KUBECTL get pods -n "$NAMESPACE" -l app=mcc-postgres

echo
echo "Liquibase job:"
$KUBECTL get jobs -n "$NAMESPACE" | grep mcc-liquibase || true

echo
echo "Liquibase logs:"
$KUBECTL logs -n "$NAMESPACE" -l app=mcc-liquibase --tail=50 || true

echo
echo "Verifying DB content..."

VERIFY_POD="mcc-db-check-$(date +%s)"

$KUBECTL run "$VERIFY_POD" \
  --rm -i \
  --namespace "$NAMESPACE" \
  --image=postgres:16 \
  --env PGPASSWORD=mcc-local-password \
  --restart=Never \
  -- psql -h mcc-postgres -U mcc -d mcc -c "select * from installer_liquibase_test;"

echo
echo "=== MCC base status check finished ==="