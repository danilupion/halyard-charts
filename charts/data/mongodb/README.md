# mongodb

![Version: 1.1.3](https://img.shields.io/badge/Version-1.1.3-informational?style=flat-square)
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

## Backups

`backup.enabled: true` adds a nightly CronJob (03:00 UTC) that dumps every database to a volume of its own,
`<fullname>-backups`, so a file backup such as restic can copy that volume and skip the live data folder:

```yaml
backup:
  enabled: true
```

- Each database but `local` and `config` gets `mongodump --archive`, uncompressed (no `--gzip`, so the file backup
  compresses and deduplicates it), as `auth.rootUsername`. `admin` holds the users and roles.
- The newest `backup.keep` dumps (3) are kept per database: the file backup keeps the history, and these cover the
  nights it missed. A database that is dropped keeps its old dumps.
- Each dump is written as `<timestamp>.archive.partial` and renamed once complete. When every dump succeeded, the
  job writes the run's timestamp to `done`; a file backup can compare it with its last snapshot.
- The volume uses `primary.persistence.storageClass` unless `backup.persistence.storageClass` is set.
- Dumps are readable by their owner only. The job's pod gets `fsGroupChangePolicy: OnRootMismatch` unless
  `primary.podSecurityContext` sets one, so the kubelet doesn't add group access to the older dumps on every run.

Volume layout:

```text
admin/20261028T030000Z.archive    users and roles
<database>/20261028T030000Z.archive
done                              20261028T030000Z
```

To restore a database (`--drop` replaces its collections):

```bash
mongorestore --username root --authenticationDatabase admin --drop --archive=myapp/20261028T030000Z.archive
```

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
