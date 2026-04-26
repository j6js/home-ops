#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TERRAFORM_DIR="${TERRAFORM_DIR:-${ROOT_DIR}/terraform}"
TALCONFIG_FILE="${TALCONFIG_FILE:-${ROOT_DIR}/talos/talconfig.yaml}"
BOOTSTRAP_ENV_FILE="${BOOTSTRAP_ENV_FILE:-${ROOT_DIR}/kubernetes/bootstrap.env}"

if [[ -f "${BOOTSTRAP_ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${BOOTSTRAP_ENV_FILE}"
  set +a
fi

resolve_from_terraform() {
  command -v terraform >/dev/null 2>&1 || return 1
  [[ -d "${TERRAFORM_DIR}" ]] || return 1

  local nodes_json
  if ! nodes_json="$(terraform -chdir="${TERRAFORM_DIR}" output -json nodes 2>/dev/null)"; then
    return 1
  fi

  [[ -n "${nodes_json}" && "${nodes_json}" != "null" ]] || return 1

  NODES_JSON="${nodes_json}" python3 - <<'PY'
import json
import os
import sys

try:
    data = json.loads(os.environ["NODES_JSON"])
except Exception:
    sys.exit(1)

preferred_roles = ("control_plane", "shared")
for role in preferred_roles:
    for name in sorted(data):
        node = data[name]
        if node.get("role") == role and node.get("public_ipv6"):
            print(node["public_ipv6"])
            sys.exit(0)

for name in sorted(data):
    node = data[name]
    if node.get("public_ipv6"):
        print(node["public_ipv6"])
        sys.exit(0)

sys.exit(1)
PY
}

resolve_from_talconfig() {
  [[ -f "${TALCONFIG_FILE}" ]] || return 1

  python3 - "${TALCONFIG_FILE}" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as fh:
    lines = fh.readlines()

in_nodes = False
current_control_plane = False
control_plane_ips = []
fallback_ips = []

for raw_line in lines:
    line = raw_line.rstrip("\n")
    stripped = line.strip()

    if not in_nodes:
        if stripped == "nodes:":
            in_nodes = True
        continue

    if line and not line.startswith(" "):
        break

    if re.match(r"^\s*-\s+hostname:", line):
        current_control_plane = False
        continue

    cp_match = re.match(r"^\s+controlPlane:\s+(true|false)\s*$", line)
    if cp_match:
        current_control_plane = cp_match.group(1) == "true"
        continue

    ip_match = re.match(r"^\s+ipAddress:\s+(.+?)\s*$", line)
    if ip_match:
        ip = ip_match.group(1).strip().strip('"\'')
        fallback_ips.append(ip)
        if current_control_plane:
            control_plane_ips.append(ip)

if control_plane_ips:
    print(control_plane_ips[0])
elif fallback_ips:
    print(fallback_ips[0])
else:
    sys.exit(1)
PY
}

main() {
  if [[ -n "${TALOS_NODE:-}" ]]; then
    printf '%s\n' "${TALOS_NODE}"
    exit 0
  fi

  if resolve_from_terraform; then
    exit 0
  fi

  if resolve_from_talconfig; then
    exit 0
  fi

  echo "failed to resolve a Talos node address from terraform output or talconfig" >&2
  exit 1
}

main "$@"
