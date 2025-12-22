# postgresql

![Version: 1.0.1](https://img.shields.io/badge/Version-1.0.1-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 18](https://img.shields.io/badge/AppVersion-18-informational?style=flat-square)

PostgreSQL standalone database server

## Description

PostgreSQL is an open-source relational database management system. This Helm chart deploys a standalone PostgreSQL
instance using a StatefulSet with persistent storage and optional Prometheus metrics.

## Requirements

| Repository          | Name   | Version |
| ------------------- | ------ | ------- |
| file://../../common | common | 0.1.0   |

## Installation

### Prerequisites

Create a Kubernetes secret with the PostgreSQL password:

```bash
kubectl create secret generic postgresql-auth \
  --from-literal=POSTGRES_PASSWORD='your-secure-password'
```

**Required secret keys:**
- `POSTGRES_PASSWORD` - Database password (required)

### Basic Installation

```bash
helm install my-postgresql ./charts/data/postgresql \
  --set auth.existingSecret=postgresql-auth
```

### Production Installation

```bash
helm install my-postgresql ./charts/data/postgresql \
  --set auth.existingSecret=postgresql-auth \
  --set primary.persistence.size=50Gi \
  --set primary.persistence.storageClass=fast-ssd \
  --set primary.resources.requests.memory=2Gi \
  --set primary.resources.limits.memory=4Gi
```

## Configuration

### Key Values

| Parameter                         | Description                             | Default     |
| --------------------------------- | --------------------------------------- | ----------- |
| `auth.existingSecret`             | Secret name with password               | `""`        |
| `auth.existingSecretKey`          | Secret key name for password            | `POSTGRES_PASSWORD` |
| `auth.username`                   | Database superuser name                 | `postgres`  |
| `auth.database`                   | Default database name                   | `postgres`  |
| `image.repository`                | Image repository                        | `postgres`  |
| `image.tag`                       | Image tag                               | `18`        |
| `primary.persistence.enabled`     | Enable persistent storage               | `true`      |
| `primary.persistence.size`        | Volume size                             | `8Gi`       |
| `metrics.enabled`                 | Enable Prometheus metrics               | `true`      |
| `service.type`                    | Service type                            | `ClusterIP` |
| `service.port`                    | PostgreSQL service port                 | `5432`      |

See `values.yaml` for the complete list of configurable values.

## Custom PostgreSQL Configuration

You can provide custom PostgreSQL configuration via the `primary.configuration` value:

```yaml
primary:
  configuration: |
    max_connections = 200
    shared_buffers = 2GB
    work_mem = 64MB
```

You can also provide a custom `pg_hba.conf` using `primary.hbaConfiguration`.

## Persistence

The chart uses a StatefulSet with a VolumeClaimTemplate for persistent storage.

**Data location:** `/var/lib/postgresql/<major>/data` (the volume is mounted at `/var/lib/postgresql`)

To use a specific storage class:

```yaml
primary:
  persistence:
    enabled: true
    storageClass: fast-ssd
    size: 50Gi
```

**WARNING:** Disabling persistence will result in data loss when the pod restarts.

## Metrics

The chart includes an optional Prometheus postgres_exporter sidecar for collecting PostgreSQL metrics.

### Prometheus Operator Integration

To enable automatic scraping by Prometheus Operator:

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
    labels:
      prometheus: kube-prometheus
```

Metrics are exposed on port `9187` at `/metrics`.

## Exposing PostgreSQL with NodePort

```yaml
service:
  type: NodePort
  nodePort: 30432
```

## Resources

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- PostgreSQL Docker Hub: https://hub.docker.com/_/postgres
- postgres_exporter: https://github.com/prometheus-community/postgres_exporter

## Values

See `values.yaml` for detailed configuration options.
