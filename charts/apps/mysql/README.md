# mysql

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 9.4.0](https://img.shields.io/badge/AppVersion-9.4.0-informational?style=flat-square)

MySQL standalone database server

## Description

MySQL is an open-source relational database management system. This Helm chart deploys a standalone MySQL instance using a StatefulSet with persistent storage and optional Prometheus metrics.

## Requirements

| Repository          | Name   | Version |
| ------------------- | ------ | ------- |
| file://../../common | common | 0.1.0   |

## Installation

### Prerequisites

Create a Kubernetes secret with MySQL credentials:

```bash
kubectl create secret generic mysql-auth \
  --from-literal=MYSQL_ROOT_PASSWORD='your-secure-root-password' \
  --from-literal=MYSQL_DATABASE='myapp' \
  --from-literal=MYSQL_USER='myappuser' \
  --from-literal=MYSQL_PASSWORD='your-secure-user-password'
```

**Required secret keys:**
- `MYSQL_ROOT_PASSWORD` - Root user password (required)
- `MYSQL_DATABASE` - Database to create on first startup (optional)
- `MYSQL_USER` - User to create on first startup (optional)
- `MYSQL_PASSWORD` - Password for MYSQL_USER (optional, required if MYSQL_USER is set)

### Basic Installation

```bash
helm install my-mysql ./charts/apps/mysql \
  --set auth.existingSecret=mysql-auth
```

### Production Installation

```bash
helm install my-mysql ./charts/apps/mysql \
  --set auth.existingSecret=mysql-auth \
  --set primary.persistence.size=50Gi \
  --set primary.persistence.storageClass=fast-ssd \
  --set primary.resources.requests.memory=2Gi \
  --set primary.resources.limits.memory=4Gi
```

## Configuration

### Key Values

| Parameter                        | Description                          | Default          |
| -------------------------------- | ------------------------------------ | ---------------- |
| `architecture`                   | MySQL architecture (standalone only) | `standalone`     |
| `auth.existingSecret`            | Secret name with credentials         | `""`             |
| `image.registry`                 | Container registry                   | `docker.io`      |
| `image.repository`               | Image repository                     | `mysql`          |
| `image.tag`                      | Image tag                            | `9.4.0`          |
| `primary.persistence.enabled`    | Enable persistent storage            | `true`           |
| `primary.persistence.size`       | Volume size                          | `8Gi`            |
| `primary.persistence.storageClass` | Storage class name                 | `""`             |
| `primary.resources.requests.cpu` | CPU request                          | `200m`           |
| `primary.resources.requests.memory` | Memory request                    | `512Mi`          |
| `primary.resources.limits.cpu`   | CPU limit                            | `1`              |
| `primary.resources.limits.memory` | Memory limit                        | `1Gi`            |
| `primary.configuration`          | Custom my.cnf content                | `""`             |
| `metrics.enabled`                | Enable Prometheus metrics            | `true`           |
| `service.type`                   | Service type                         | `ClusterIP`      |
| `service.port`                   | MySQL service port                   | `3306`           |

See `values.yaml` for the complete list of configurable values.

## Custom MySQL Configuration

You can provide custom MySQL configuration via the `primary.configuration` value:

```yaml
primary:
  configuration: |
    [mysqld]
    max_connections=200
    innodb_buffer_pool_size=2G
    character-set-server=utf8mb4
    collation-server=utf8mb4_unicode_ci
    # Performance optimizations
    innodb_flush_log_at_trx_commit=2
    innodb_flush_method=O_DIRECT
```

## Persistence

The chart uses a StatefulSet with a VolumeClaimTemplate for persistent storage.

**Data location:** `/var/lib/mysql`

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

The chart includes an optional Prometheus mysqld_exporter sidecar for collecting MySQL metrics.

### Enable Metrics

```yaml
metrics:
  enabled: true
```

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

Metrics are exposed on port `9104` at `/metrics`.

## Health Checks

The chart configures three types of probes:

- **Startup Probe**: Allows slow-starting instances (up to 5 minutes)
- **Liveness Probe**: Restarts the container if MySQL becomes unresponsive
- **Readiness Probe**: Controls traffic routing to the pod

All probes use `mysqladmin ping` to check MySQL health.

## Security

The chart runs with restrictive security settings by default:

```yaml
primary:
  podSecurityContext:
    fsGroup: 999  # mysql user

  securityContext:
    runAsUser: 999
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    capabilities:
      drop:
        - ALL
```

## Connecting to MySQL

### From within the cluster

```bash
# Using the StatefulSet pod name
mysql -h my-mysql-0.my-mysql.default.svc.cluster.local -uroot -p

# Using the headless service (resolves to pod)
mysql -h my-mysql.default.svc.cluster.local -uroot -p
```

### From outside the cluster

```bash
kubectl port-forward svc/my-mysql 3306:3306
mysql -h 127.0.0.1 -P 3306 -uroot -p
```

## Backup and Restore

### Backup

```bash
kubectl exec -it my-mysql-0 -- \
  mysqldump -uroot -p${MYSQL_ROOT_PASSWORD} --all-databases > backup.sql
```

### Restore

```bash
kubectl exec -i my-mysql-0 -- \
  mysql -uroot -p${MYSQL_ROOT_PASSWORD} < backup.sql
```

## Upgrading

Before upgrading MySQL versions:

1. **Always backup your data**
2. Review MySQL upgrade notes for the target version
3. Test the upgrade in a non-production environment
4. MySQL may require running `mysql_upgrade` after version changes

## Troubleshooting

### Pod not starting

Check if the secret exists and contains `MYSQL_ROOT_PASSWORD`:

```bash
kubectl get secret mysql-auth -o jsonpath='{.data.MYSQL_ROOT_PASSWORD}' | base64 -d
```

### Viewing logs

```bash
kubectl logs my-mysql-0 -c mysql
kubectl logs my-mysql-0 -c metrics  # If metrics enabled
```

### MySQL shell access

```bash
kubectl exec -it my-mysql-0 -- mysql -uroot -p
```

## Resources

- MySQL Documentation: https://dev.mysql.com/doc/
- MySQL Docker Hub: https://hub.docker.com/_/mysql
- mysqld_exporter: https://github.com/prometheus/mysqld_exporter

## Values

See `values.yaml` for detailed configuration options and `values.schema.json` for value validation.
