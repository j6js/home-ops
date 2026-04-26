#!/usr/bin/env bash
set -euo pipefail

KUBECONFIG_PATH="${1:-}"
TALOS_NODE="${2:-}"
API_PORT="${3:-6443}"

if [[ -z "${KUBECONFIG_PATH}" || -z "${TALOS_NODE}" ]]; then
  echo "usage: $0 <kubeconfig-path> <talos-node> [api-port]" >&2
  exit 1
fi

for bin in kubectl python3; do
  command -v "${bin}" >/dev/null 2>&1 || {
    echo "missing required binary: ${bin}" >&2
    exit 1
  }
done

if [[ ! -f "${KUBECONFIG_PATH}" ]]; then
  echo "kubeconfig not found at ${KUBECONFIG_PATH}" >&2
  exit 1
fi

cluster_name="$(KUBECONFIG="${KUBECONFIG_PATH}" kubectl config view --minify -o jsonpath='{.clusters[0].name}')"
current_server="$(KUBECONFIG="${KUBECONFIG_PATH}" kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')"

if [[ -z "${cluster_name}" || -z "${current_server}" ]]; then
  echo "failed to inspect kubeconfig cluster server" >&2
  exit 1
fi

should_rewrite="$(CURRENT_SERVER="${current_server}" python3 - <<'PY'
from urllib.parse import urlparse
import ipaddress
import os

server = os.environ["CURRENT_SERVER"]
host = urlparse(server).hostname
if not host:
    print("no")
    raise SystemExit(0)

try:
    ip = ipaddress.ip_address(host)
except ValueError:
    print("no")
    raise SystemExit(0)

print("yes" if ip.is_private else "no")
PY
)"

if [[ "${should_rewrite}" == "yes" ]]; then
  if [[ "${TALOS_NODE}" == *:* ]]; then
    new_server="https://[${TALOS_NODE}]:${API_PORT}"
  else
    new_server="https://${TALOS_NODE}:${API_PORT}"
  fi

  echo "Rewriting kubeconfig server from ${current_server} to ${new_server}"
  KUBECONFIG="${KUBECONFIG_PATH}" kubectl config set-cluster "${cluster_name}" --server="${new_server}" >/dev/null
else
  echo "Keeping kubeconfig server ${current_server}"
fi
