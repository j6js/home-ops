# j6js-k8s
## Kubernetes Cluster in Homelab-style, but not really a homelab because it's in the Cloud.

This repo contains the Terraform, YAML, and other code/config for my personal k8s cluster.
It's deployed on Terraform, run on Talos Linux, and automated via:
- FluxCD
- GitHub Actions
- Renovate

---

The repo is split into 3 sections:

- `terraform/` : Terraform Code
    - `syd/` : Sydney Module
    - `mel/` : Melbourne Module
    - `talos/` : Talos Linux Image (not included in git repo, too large)
    - `main.tf` : Root Module File
    - `talconfig.yaml.tftpl` : Talhelper config template, automated via Terraform
- `talos/` : Talos cluster lifecycle
    - decrypt/apply Talos config
    - generate cluster config artifacts
- `kubernetes/` : Post-Talos bootstrap + GitOps-managed cluster state
    - bootstrap Cilium
    - bootstrap Flux
    - host future cluster apps and infrastructure manifests

## Bootstrap flow

1. `task tf:deploy`
2. `task talos:full-deploy`
3. `task k8s:bootstrap`

That keeps infrastructure, Talos, and GitOps ownership separate instead of cramming Flux bootstrap into Talos machine config.
