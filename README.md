# halyard-charts

**Monorepo of Kubernetes Helm charts, built for GitOps workflows.**

Halyard Charts is a collection of reusable Helm charts for infrastructure and application workloads. It’s designed to be consumed from **Git** (Argo CD & Helmfile) and is **OCI-ready** for registries like Harbor.

## Highlights

- **GitOps-first**: works cleanly with Argo CD Applications and Helmfile releases.
- **DRY by design**: optional **library chart** for shared helpers.
- **Typed values**: charts include `values.schema.json` for early validation.
- **Per-chart versioning**: tag releases per chart (e.g., `letsencrypt-cloudflare-issuer-v1.2.3`).

## Contributing

This repository uses [pre-commit](https://pre-commit.com) to enforce consistent formatting and linting.
Install the Git hooks and run all checks with:

## Pre-commit hooks

Install git hooks with:

```bash
pre-commit install
```

## Manually running prettier wiht "fix"

Install git hooks with:

```bash
pre-commit run --hook-stage manual --all-file
```
