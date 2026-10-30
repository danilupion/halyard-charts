# Plausible Analytics Helm Chart

Privacy-friendly, cookie-free web analytics. GDPR compliant without consent banners.

## Overview

This chart deploys [Plausible Analytics Community Edition](https://plausible.io) on Kubernetes with:

- Plausible server
- ClickHouse (for analytics events), unless an external one is configured

PostgreSQL (users, sites and settings) is not deployed: the chart connects to an existing server.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (for persistence)
- A PostgreSQL server with a database and an owner user for Plausible (it runs its own migrations)

## Installation

```bash
helm dependency update
helm install plausible . -f values.yaml
```

## Configuration

### Required Settings

| Parameter | Description |
|-----------|-------------|
| `plausible.baseUrl` | Public URL where Plausible will be accessible |
| `plausible.secretKeyBase` | 64+ byte secret for session encryption |
| `externalPostgresql.host` | PostgreSQL server Plausible connects to |

Generate a secret key:

```bash
openssl rand -base64 48
```

### Database Options

PostgreSQL is always external (`username` and `database` default to `plausible`, `existingSecretKey` to
`password`). ClickHouse is deployed by the chart unless `clickhouse.enabled: false` points it at an external one:

```yaml
externalPostgresql:
  host: postgres.example.com
  port: 5432
  username: plausible
  database: plausible
  existingSecret: plausible-postgres-secret
  existingSecretKey: password

clickhouse:
  enabled: false

externalClickhouse:
  host: clickhouse.example.com
  port: 8123
  username: plausible
  database: plausible_events
  existingSecret: plausible-clickhouse-secret
  existingSecretKey: password
```

### Email (Optional)

Configure email for password resets and weekly reports:

```yaml
mailer:
  enabled: true
  adapter: Bamboo.Mua
  emailFrom: plausible@example.com
  smtp:
    host: smtp.example.com
    port: 587
    username: plausible
    existingSecret: plausible-smtp-secret
```

### Geolocation (Optional)

For visitor location data, get a free MaxMind license:

```yaml
geolocation:
  existingSecret: plausible-maxmind-secret
  edition: GeoLite2-City
```

### Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: plausible.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: plausible-tls
      hosts:
        - plausible.example.com
```

## Adding the Tracking Script

After deployment, add this script to your websites:

```html
<script defer data-domain="yourdomain.com" src="https://plausible.example.com/js/script.js"></script>
```

## Resource Requirements

Minimum recommended:

- Plausible: 256Mi RAM, 100m CPU
- ClickHouse: 512Mi RAM (analytics data)

## Upgrading

From 2.x: 3.0.0 drops the bundled Bitnami PostgreSQL subchart (`postgresql.*` values). Before upgrading, copy the
data to another server (`pg_dump -Fc plausible`, then `pg_restore --no-owner --role=<owner>` into an empty
database) and set `externalPostgresql`. The old StatefulSet's volume is left behind; delete it once the copy is
verified.

```bash
helm dependency update
helm upgrade plausible . -f values.yaml
```

## Links

- [Plausible Documentation](https://plausible.io/docs)
- [Community Edition](https://github.com/plausible/community-edition)
- [Configuration Options](https://github.com/plausible/community-edition/wiki/configuration)
