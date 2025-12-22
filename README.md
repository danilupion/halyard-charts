# halyard-charts

**Monorepo of Kubernetes Helm charts, built for GitOps workflows.**

Halyard Charts is a curated catalogue of reusable Helm charts for infrastructure and application workloads. It's designed to be consumed from **Git** (Argo CD & Helmfile) and is **OCI-ready** for registries like Harbor.

## Highlights

- **GitOps-first**: works cleanly with Argo CD Applications and Helmfile releases.
- **DRY by design**: optional **library chart** for shared helpers.
- **Typed values**: charts include `values.schema.json` for early validation.
- **Per-chart versioning**: tag releases per chart (e.g., `letsencrypt-cloudflare-issuer-v1.2.3`).
- **Production-ready**: charts follow Kubernetes and Helm best practices.

## Chart Catalogue

### Infrastructure Charts (`charts/infra/`)

Infrastructure components for cluster setup and management:

- **[letsencrypt-cloudflare-issuer](charts/infra/letsencrypt-cloudflare-issuer)** - Cert-Manager ClusterIssuer backed by Let's Encrypt + Cloudflare DNS-01
- **[metallb-config](charts/infra/metallb-config)** - Generic MetalLB configuration with multiple pools and L2 advertisements

### Data Charts (`charts/data/`)

Stateful data services for production use:

- **[mysql](charts/data/mysql)** - MySQL standalone database server with Prometheus metrics
- **[mongodb](charts/data/mongodb)** - MongoDB standalone database server with Prometheus metrics
- **[postgresql](charts/data/postgresql)** - PostgreSQL standalone database server with Prometheus metrics

### Application Charts (`charts/apps/`)

Application deployments ready for production use:

- **[civicrm](charts/apps/civicrm)** - CiviCRM Standalone - open source CRM for nonprofits, NGOs and advocacy organizations
- **[obsidian](charts/apps/obsidian)** - Web-based Obsidian MD desktop experience packaged by LinuxServer.io

### Library Charts (`charts/common/`)

Reusable template helpers for building charts:

- **[common](charts/common)** - Shared Helm template helpers (labels, metadata, resources, etc.)

## Common Library Chart

Shared helpers are provided by the [`common`](charts/common) library chart. To use them, declare the dependency in your chart's `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 0.1.0
    repository: file://../../common
```

Then reference the helpers with the chart name, for example:

```yaml
{{ include "common.labels" . }}
```

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
