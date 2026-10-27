# postgresql

![Version: 1.2.1](https://img.shields.io/badge/Version-1.2.1-informational?style=flat-square)
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

## Database Provisioning

`databases` creates a login role and a database it owns, on every Argo CD sync (a PostSync Job, idempotent).
Passwords come from secrets in the release namespace.

```yaml
databases:
  - name: myapp
    user: myapp                  # becomes the database OWNER
    passwordSecret: myapp-db-credentials
    passwordSecretKey: MYAPP_PASSWORD
    extraRoles:                  # optional, since 1.1.0
      - name: myapp_web
        passwordSecret: myapp-db-credentials
        passwordSecretKey: MYAPP_WEB_PASSWORD
```

### Extra roles

A table owner bypasses row-level security and can disable policies and triggers. Apps that rely on RLS should
connect with **extra roles** instead: login roles that own nothing. On every sync each extra role is:

- created if missing, and its password set from its secret (passed as a psql variable, so any characters work);
- forced to `NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`;
- granted `CONNECT` on its database.

Table and schema privileges are **not** granted by the chart: the owner grants them (typically in the app's
migrations).

Safety checks:

- At render time, names must match `^[a-z_][a-z0-9_]{0,62}$`. They must not equal `auth.username` or any
  database `user`, and must be unique across all databases (PostgreSQL roles are cluster-wide). Both secret
  fields are required.
- At run time, the job fails instead of modifying an existing role that is a superuser or owns a database.

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

## Backups

`backup.enabled: true` adds a nightly CronJob (03:00 UTC) that dumps every database to a volume of its own,
`<fullname>-backups`, so a file backup such as restic can copy that volume and skip the live data folder:

```yaml
backup:
  enabled: true
```

- Each database the server accepts connections to gets `pg_dump -Fc -Z0` (uncompressed, so the file backup
  compresses and deduplicates it), and the roles get `pg_dumpall --globals-only`. They run as `auth.username`, a
  superuser, so row-level security never hides rows.
- The newest `backup.keep` dumps (3) are kept per database: the file backup keeps the history, and these cover the
  nights it missed. A database that is dropped keeps its old dumps.
- Each dump is written as `<timestamp>.dump.partial` and renamed once complete. When every dump succeeded, the job
  writes the run's timestamp to `done`; a file backup can compare it with its last snapshot.
- The volume uses `primary.persistence.storageClass` unless `backup.persistence.storageClass` is set.

Volume layout:

```text
globals/20261028T030000Z.sql      roles and tablespaces
<database>/20261028T030000Z.dump  one per database
done                              20261028T030000Z
```

To restore a database, roles first if they are missing:

```bash
psql -f globals/20261028T030000Z.sql      # errors for roles that already exist are harmless
pg_restore --clean --if-exists --create -d postgres myapp/20261028T030000Z.dump
```

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
