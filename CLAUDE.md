# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Helm chart monorepo** designed for GitOps workflows with Argo CD and Helmfile. Charts are organized under `charts/` with per-chart versioning and automated tagging.

### Directory Structure

```
charts/
├── common/              # Library chart with shared Helm template helpers
└── infra/              # Infrastructure application charts
    ├── letsencrypt-cloudflare-issuer/
    └── metallb-config/
```

## Core Architecture

### Common Library Chart

The `charts/common/` library chart provides reusable template helpers to reduce duplication across charts. It's a Helm library chart (type: library) that exports helpers like `common.labels`.

**Usage pattern**: Charts declare it as a file-based dependency in `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 0.1.0
    repository: file://../../common
```

Reference helpers in templates with `{{ include "common.labels" . }}`

### Chart Organization

- **Location**: All charts live under `charts/` subdirectories
- **Categories**: `common/` (library), `infra/` (infrastructure apps)
- **Structure**: Each chart contains:
  - `Chart.yaml` - metadata and dependencies
  - `values.yaml` - default configuration
  - `values.schema.json` - JSON Schema for value validation
  - `README.md` - auto-generated docs with helm-docs
  - `templates/` - Kubernetes resource templates
  - `NOTES.txt` - post-install instructions

### Versioning and Releases

- **Per-chart versioning**: Each chart has its own version in `Chart.yaml`
- **Git tag format**: `{chart-name}-v{version}` (e.g., `metallb-config-v1.0.0`)
- **Automated tagging**: On merge to main, CI detects changed `Chart.yaml` files and creates corresponding git tags via `.github/workflows/chart-tag.yml`

## Development Commands

### Linting and Validation

```bash
# Lint a specific chart (strict mode)
helm lint charts/infra/letsencrypt-cloudflare-issuer --strict

# Lint all charts (as CI does)
for c in charts/*/*; do
  [ -f "$c/Chart.yaml" ] && helm lint "$c" --strict || true
done

# Validate chart can be templated without a cluster
helm template test charts/infra/metallb-config
```

### Testing Charts

```bash
# Template a chart with custom values
helm template my-release charts/infra/metallb-config -f my-values.yaml

# Template all charts (CI validation)
for c in charts/*/*; do
  [ -f "$c/Chart.yaml" ] && helm template test "$c" || true
done
```

### Working with Dependencies

```bash
# Update chart dependencies (pulls common library)
cd charts/infra/letsencrypt-cloudflare-issuer
helm dependency update

# Build dependency packages
helm dependency build
```

### Pre-commit Hooks

The repository uses pre-commit for code quality:

```bash
# Install hooks
pre-commit install

# Run all checks manually
pre-commit run --all-files

# Run prettier with auto-fix (manual stage only)
pre-commit run --hook-stage manual --all-files
```

## Chart Development Guidelines

### Adding a New Chart

1. Create directory under appropriate category: `charts/{category}/{chart-name}/`
2. Create `Chart.yaml` with required fields (name, description, version, type)
3. Add common library dependency if needed
4. Create `values.yaml` with sensible defaults
5. Create `values.schema.json` for type validation
6. Build templates in `templates/` directory
7. Add `README.md` and `NOTES.txt`

### Updating Chart Versions

When modifying a chart, increment the version in `Chart.yaml` according to semantic versioning. On merge to main, the CI will automatically create a git tag.

### values.schema.json

All charts include JSON Schema validation for their values. This enables:
- Early validation before deployment
- IDE autocomplete and inline docs
- Type safety for complex configurations

## CI/CD Workflows

### chart-ci.yml (Pull Requests & Main)

Runs on changes to `charts/**`:
1. Lints all charts with `helm lint`
2. Validates templates render with `helm template`

### chart-tag.yml (After Main CI)

Triggers after successful CI on main:
1. Detects changed `Chart.yaml` files
2. Extracts name and version using yq
3. Creates and pushes git tags: `{name}-v{version}`

## Code Style

- **YAML**: 2-space indentation, 120 char line length (see `.yamllint.yaml`)
- **Prettier**: 120 char print width (see `.prettierrc`)
- **EditorConfig**: LF line endings, UTF-8, trim trailing whitespace

## GitOps Usage

Charts are designed to be consumed from Git by tools like Argo CD:

```yaml
# Argo CD Application example
source:
  repoURL: https://github.com/yourusername/halyard-charts
  targetRevision: letsencrypt-cloudflare-issuer-v1.0.0
  path: charts/infra/letsencrypt-cloudflare-issuer
```

Or via Helmfile:

```yaml
releases:
  - name: metallb-config
    chart: git+https://github.com/yourusername/halyard-charts@charts/infra/metallb-config?ref=metallb-config-v1.0.0
```
