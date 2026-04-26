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

for bin in flux git gh kubectl; do
  command -v "${bin}" >/dev/null 2>&1 || {
    echo "missing required binary: ${bin}" >&2
    exit 1
  }
done

if [[ ! -f "${KUBECONFIG}" ]]; then
  echo "kubeconfig not found at ${KUBECONFIG}" >&2
  exit 1
fi

if KUBECONFIG="${KUBECONFIG}" kubectl get namespace flux-system >/dev/null 2>&1; then
  echo "Flux already bootstrapped; nothing to do"
  exit 0
fi

remote_url="$(git -C "${ROOT_DIR}" remote get-url origin)"
GITHUB_OWNER="${GITHUB_OWNER:-$(printf '%s' "${remote_url}" | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+)(\.git)?#\1#')}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$(printf '%s' "${remote_url}" | sed -E 's#.*github.com[:/]([^/]+)/([^/.]+)(\.git)?#\2#')}"
GITHUB_BRANCH="${GITHUB_BRANCH:-$(git -C "${ROOT_DIR}" branch --show-current)}"
FLUX_PATH="${FLUX_PATH:-kubernetes/clusters/main}"
GITHUB_PERSONAL="${GITHUB_PERSONAL:-true}"

if [[ -z "${GITHUB_OWNER}" || -z "${GITHUB_REPOSITORY}" || -z "${GITHUB_BRANCH}" ]]; then
  echo "failed to determine GitHub bootstrap settings" >&2
  exit 1
fi

if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo "gh is not authenticated for github.com" >&2
  exit 1
fi

export GITHUB_TOKEN="${GITHUB_TOKEN:-$(gh auth token)}"

KUBECONFIG="${KUBECONFIG}" flux check --pre
KUBECONFIG="${KUBECONFIG}" flux bootstrap github \
  --owner="${GITHUB_OWNER}" \
  --repository="${GITHUB_REPOSITORY}" \
  --branch="${GITHUB_BRANCH}" \
  --path="${FLUX_PATH}" \
  $( [[ "${GITHUB_PERSONAL}" == "true" ]] && printf '%s' '--personal' ) \
  --token-auth

KUBECONFIG="${KUBECONFIG}" flux get sources git -A
KUBECONFIG="${KUBECONFIG}" flux get kustomizations -A
