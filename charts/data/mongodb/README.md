# mongodb

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 8.0](https://img.shields.io/badge/AppVersion-8.0-informational?style=flat-square)

MongoDB standalone database server

## Description

MongoDB is a document-oriented NoSQL database. This Helm chart deploys a standalone MongoDB instance using a
StatefulSet with persistent storage and optional Prometheus metrics.

## Requirements

| Repository          | Name   | Version |
| ------------------- | ------ | ------- |
| file://../../common | common | 0.1.0   |

## Installation

### Prerequisites

Create a Kubernetes secret with the MongoDB root password:

```bash
kubectl create secret generic mongodb-auth \
  --from-literal=MONGO_INITDB_ROOT_PASSWORD='your-secure-password'
```

**Required secret keys:**
- `MONGO_INITDB_ROOT_PASSWORD` - Root user password (required)

### Basic Installation

```bash
helm install my-mongodb ./charts/data/mongodb \
  --set auth.existingSecret=mongodb-auth
```

### Production Installation

```bash
helm install my-mongodb ./charts/data/mongodb \
  --set auth.existingSecret=mongodb-auth \
  --set primary.persistence.size=50Gi \
  --set primary.persistence.storageClass=fast-ssd \
  --set primary.resources.requests.memory=2Gi \
  --set primary.resources.limits.memory=4Gi
```

## Configuration

### Key Values

| Parameter                         | Description                             | Default     |
| --------------------------------- | --------------------------------------- | ----------- |
| `auth.existingSecret`             | Secret name with root password          | `""`        |
| `auth.existingSecretKey`          | Secret key name for root password       | `MONGO_INITDB_ROOT_PASSWORD` |
| `auth.rootUsername`               | Root username                           | `root`      |
| `auth.database`                   | Initial database to create (optional)   | `""`        |
| `image.repository`                | Image repository                        | `mongo`     |
| `image.tag`                       | Image tag                               | `8.0`       |
| `primary.persistence.enabled`     | Enable persistent storage               | `true`      |
| `primary.persistence.size`        | Volume size                             | `8Gi`       |
| `metrics.enabled`                 | Enable Prometheus metrics               | `true`      |
| `service.type`                    | Service type                            | `ClusterIP` |
| `service.port`                    | MongoDB service port                    | `27017`     |

See `values.yaml` for the complete list of configurable values.

## Persistence

The chart uses a StatefulSet with a VolumeClaimTemplate for persistent storage.

**Data location:** `/data/db`

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

The chart includes an optional Prometheus mongodb_exporter sidecar for collecting MongoDB metrics.

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

Metrics are exposed on port `9216` at `/metrics`.

## Exposing MongoDB with NodePort

```yaml
service:
  type: NodePort
  nodePort: 32017
```

## Resources

- MongoDB Documentation: https://www.mongodb.com/docs/
- MongoDB Docker Hub: https://hub.docker.com/_/mongo
- mongodb_exporter: https://github.com/percona/mongodb_exporter

## Values

See `values.yaml` for detailed configuration options.
