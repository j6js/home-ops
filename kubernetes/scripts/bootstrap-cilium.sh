#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
BOOTSTRAP_ENV_FILE="${BOOTSTRAP_ENV_FILE:-${ROOT_DIR}/kubernetes/bootstrap.env}"
KUBECONFIG="${KUBECONFIG:-${ROOT_DIR}/kubernetes/kubeconfig}"

if [[ -f "${BOOTSTRAP_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${BOOTSTRAP_ENV_FILE}"
  set +a
fi

for bin in kubectl cilium python3; do
  command -v "${bin}" >/dev/null 2>&1 || {
    echo "missing required binary: ${bin}" >&2
    exit 1
  }
done

if [[ ! -f "${KUBECONFIG}" ]]; then
  echo "kubeconfig not found at ${KUBECONFIG}" >&2
  exit 1
fi

api_parts="$({ KUBECONFIG="${KUBECONFIG}" python3 - <<'PY'
from urllib.parse import urlparse
import os
import subprocess

server = subprocess.check_output(
    ["kubectl", "config", "view", "--minify", "-o", "jsonpath={.clusters[0].cluster.server}"],
    env=os.environ,
    text=True,
).strip()
parsed = urlparse(server)
print(parsed.hostname or "")
print(parsed.port or 6443)
PY
} )"

api_host=""
api_port=""
while IFS= read -r line; do
  if [[ -z "${api_host}" ]]; then
    api_host="${line}"
  elif [[ -z "${api_port}" ]]; then
    api_port="${line}"
    break
  fi
done <<EOF
${api_parts}
EOF

KUBERNETES_SERVICE_HOST="${KUBERNETES_SERVICE_HOST:-${api_host}}"
KUBERNETES_SERVICE_PORT="${KUBERNETES_SERVICE_PORT:-${api_port:-6443}}"
CILIUM_VERSION="${CILIUM_VERSION:-1.18.2}"

if [[ -z "${KUBERNETES_SERVICE_HOST}" ]]; then
  echo "failed to determine Kubernetes API host" >&2
  exit 1
fi

cilium_args=(
  --version "${CILIUM_VERSION}"
  --set "ipam.mode=kubernetes"
  --set "kubeProxyReplacement=true"
  --set "k8sServiceHost=${KUBERNETES_SERVICE_HOST}"
  --set "k8sServicePort=${KUBERNETES_SERVICE_PORT}"
  --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
)

if KUBECONFIG="${KUBECONFIG}" kubectl -n kube-system get daemonset cilium >/dev/null 2>&1; then
  echo "Cilium already present; running upgrade"
  KUBECONFIG="${KUBECONFIG}" cilium upgrade "${cilium_args[@]}"
else
  echo "Installing Cilium"
  KUBECONFIG="${KUBECONFIG}" cilium install "${cilium_args[@]}"
fi

KUBECONFIG="${KUBECONFIG}" cilium status --wait
