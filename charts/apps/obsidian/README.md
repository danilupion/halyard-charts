# obsidian

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.5.3](https://img.shields.io/badge/AppVersion-1.5.3-informational?style=flat-square)

Web-accessible Obsidian MD desktop client packaged by LinuxServer.io

## Description

This chart deploys the [LinuxServer.io Obsidian container](https://github.com/linuxserver/docker-obsidian). The container provides an Obsidian desktop environment that is accessible via any modern browser using noVNC.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://../../common | common | 0.1.0 |

## Installation

### Prerequisites

- Kubernetes 1.24+
- Persistent volume for `/config` (stores application configuration and vaults)
- Ingress controller or port-forward access to reach the web UI

### Install the chart

```bash
helm repo add halyard-charts https://example.com/halyard-charts
helm upgrade --install my-obsidian ./charts/apps/obsidian \
  --namespace apps \
  --create-namespace
```

The service exposes port `3000/TCP` (noVNC web UI) and `3001/TCP` (websocket relay). By default the chart creates a `ClusterIP` service; configure an Ingress or port-forward to access the UI.

## Configuration

All configuration values are documented in `values.yaml`. Key settings:

- `linuxserver.puid` / `linuxserver.pgid` – filesystem ownership for the mounted volume.
- `persistence.config` – PersistentVolumeClaim options for storing your vault data.
- `service` / `ingress` – networking configuration for exposing the noVNC interface.
- `extraEnv` / `extraEnvFrom` – supply additional environment variables or references.

Override values by supplying a custom `values.yaml` or `--set` flags at install time.

### Example: bring your own PVC

```bash
helm upgrade --install my-obsidian ./charts/apps/obsidian \
  --namespace apps \
  --set persistence.config.existingClaim=obsidian-data
```

### Example: expose through an Ingress

```bash
helm upgrade --install my-obsidian ./charts/apps/obsidian \
  --namespace apps \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=obsidian.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

## Persistence

The chart creates a PVC named `<release>-obsidian-config` unless `persistence.config.existingClaim` is specified. Mount the claim at `/config` to retain vault content across pod restarts.

## Uninstalling the Chart

```bash
helm uninstall my-obsidian --namespace apps
```

Removing the release does not delete persistent volumes. Manually remove the PVC if you no longer need the stored data.
