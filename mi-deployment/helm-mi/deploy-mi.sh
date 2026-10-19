#!/usr/bin/env bash
# =============================================================================
# deploy-mi.sh — WSO2 Micro Integrator 4.4.0, Sybyl Internal Lab
# Namespace   : wso2-mi
# Image       : docker.wso2.com/wso2mi:4.4.0
# Ingress     : Envoy Gateway (Gateway API) — mi.sybyl.int
# Storage     : NFS / nfs-csi StorageClass (Nimble-backed)
# Certs       : *.sybyl.int wildcard from Sybyl Internal CA
#
# Usage:
#   ./deploy-mi.sh            # install or upgrade
#   ./deploy-mi.sh --uninstall
# =============================================================================
set -euo pipefail

NAMESPACE="wso2-mi"
RELEASE="mi"
CHART_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/mi" && pwd)"
BOOTSTRAP_YAML="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/mi-gateway-resources.yaml"
CERT_DIR="${HOME}/intlabcrt"

# ---- Colours ----------------------------------------------------------------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ---- Uninstall --------------------------------------------------------------
if [[ "${1:-}" == "--uninstall" ]]; then
  warn "Uninstalling MI release '${RELEASE}' from namespace '${NAMESPACE}'..."
  helm uninstall "${RELEASE}" -n "${NAMESPACE}" || true
  kubectl delete -f "${BOOTSTRAP_YAML}" --ignore-not-found
  warn "Namespace '${NAMESPACE}' retained. Delete manually if desired."
  exit 0
fi

# ---- Pre-flight checks ------------------------------------------------------
command -v kubectl &>/dev/null || die "kubectl not found"
command -v helm    &>/dev/null || die "helm not found"
[[ -f "${CERT_DIR}/sybyl-int-wildcard-1yr.crt" ]] || die "Cert not found: ${CERT_DIR}/sybyl-int-wildcard-1yr.crt"
[[ -f "${CERT_DIR}/sybyl-int-wildcard-1yr.key" ]] || die "Key not found:  ${CERT_DIR}/sybyl-int-wildcard-1yr.key"

# ---- 1. Namespace -----------------------------------------------------------
info "Ensuring namespace '${NAMESPACE}' exists..."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# ---- 2. TLS Secret ----------------------------------------------------------
info "Creating/updating wildcard TLS secret 'wso2-mi-wildcard-tls'..."
kubectl create secret tls wso2-mi-wildcard-tls \
  --cert="${CERT_DIR}/sybyl-int-wildcard-1yr.crt" \
  --key="${CERT_DIR}/sybyl-int-wildcard-1yr.key" \
  -n "${NAMESPACE}" \
  --dry-run=client -o yaml | kubectl apply -f - 2>/dev/null || \
kubectl create secret tls wso2-mi-wildcard-tls \
  --cert="${CERT_DIR}/sybyl-int-wildcard-1yr.crt" \
  --key="${CERT_DIR}/sybyl-int-wildcard-1yr.key" \
  -n "${NAMESPACE}"

# ---- 3. Keystores Secret ----------------------------------------------------
info "Creating/updating keystore secret 'mi-keystores'..."
SECURITY_DIR="${CHART_DIR}/security"
kubectl create secret generic mi-keystores \
  --from-file=wso2carbon.jks="${SECURITY_DIR}/wso2carbon.jks" \
  --from-file=client-truststore.jks="${SECURITY_DIR}/client-truststore.jks" \
  -n "${NAMESPACE}" \
  --dry-run=client -o yaml > /tmp/mi-keystores.yaml 2>/dev/null || true

if [[ -s /tmp/mi-keystores.yaml ]]; then
  kubectl apply -f /tmp/mi-keystores.yaml
  rm -f /tmp/mi-keystores.yaml
else
  # Fallback: delete and recreate (JKS files are too large for dry-run annotation)
  kubectl delete secret mi-keystores -n "${NAMESPACE}" --ignore-not-found
  kubectl create secret generic mi-keystores \
    --from-file=wso2carbon.jks="${SECURITY_DIR}/wso2carbon.jks" \
    --from-file=client-truststore.jks="${SECURITY_DIR}/client-truststore.jks" \
    -n "${NAMESPACE}"
fi

# ---- 4. Gateway + NFS PVC (bootstrap) --------------------------------------
info "Applying Gateway API and NFS PVC resources..."
kubectl apply -f "${BOOTSTRAP_YAML}"

info "Waiting for Gateway to be programmed..."
kubectl wait gateway/wso2-mi-gateway \
  -n "${NAMESPACE}" \
  --for=condition=Programmed \
  --timeout=90s || warn "Gateway not yet Programmed (check 'kubectl describe gateway wso2-mi-gateway -n ${NAMESPACE}')"

# ---- 5. Helm install/upgrade ------------------------------------------------
info "Running Helm install/upgrade for release '${RELEASE}'..."
helm upgrade --install "${RELEASE}" "${CHART_DIR}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --atomic \
  --timeout 5m \
  --wait

# ---- 6. Verify --------------------------------------------------------------
info "Deployment status:"
kubectl get pods -n "${NAMESPACE}" -o wide
echo ""
info "Service:"
kubectl get svc -n "${NAMESPACE}"
echo ""
info "HTTPRoute:"
kubectl get httproute -n "${NAMESPACE}"
echo ""
info "Gateway:"
kubectl get gateway -n "${NAMESPACE}"
echo ""
info "Done! Access MI at: https://mi.sybyl.int"
info "Management API:     https://mi.sybyl.int/management"
