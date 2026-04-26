# Kubernetes Bootstrap

This directory is the handoff between **Talos cluster lifecycle** and **Flux-managed cluster state**.

## Ownership

- `terraform/` owns cloud infrastructure and renders `talos/talconfig.yaml`
- `talos/` owns Talos machine + cluster configuration
- `kubernetes/` owns post-bootstrap Kubernetes state

## Bootstrap boundary

The bootstrap layer exists to do the minimum needed after Talos is up:

1. fetch kubeconfig from Talos
2. install/upgrade **Cilium**
3. bootstrap **Flux** against this repo
4. hand off ongoing cluster state to GitOps

That keeps ownership clean and avoids stuffing app-layer bootstrapping into `talconfig`.

## Layout

- `scripts/bootstrap-cilium.sh` — initial Cilium install/upgrade
- `scripts/bootstrap-flux.sh` — initial Flux bootstrap against GitHub
- `clusters/` — Flux entrypoints for cluster-specific state
- `apps/` — application manifests/HelmRelease definitions
- `infrastructure/` — cluster add-ons and shared infra components

## Tasks

Run from the repo root:

- `task k8s:kubeconfig`
- `task k8s:bootstrap-cilium`
- `task k8s:bootstrap-flux`
- `task k8s:bootstrap`

## Optional bootstrap config

Copy `kubernetes/bootstrap.env.example` to `kubernetes/bootstrap.env` if you want to override defaults such as the Cilium version, Flux path, or the Kubernetes API endpoint.
