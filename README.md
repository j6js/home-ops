# j6js-k8s
## Kubernetes Cluster in Homelab-style, but not really a homelab because it's in the Cloud.

This repo contains the Terraform, YAML, and other code/config for my personal k8s cluster.
It's deployed on Terraform, run on Talos Linux, and automated via:
- FluxCD
- GitHub Actions
- Renovate

---

The repo is split into 2 sections, `terraform` and `talos`. There will eventually be a `kubernetes` section, but I haven't got there yet.

- `terraform/` : Terraform Code
    - `syd/` : Sydney Module
    - `mel/` : Melbourne Module
    - `talos/` : Talos Linux Image (not included in git repo, too large)
    - `main.tf` : Root Module File
    - `talconfig.yaml.tftpl` : Talhelper config template, automated via Terraform