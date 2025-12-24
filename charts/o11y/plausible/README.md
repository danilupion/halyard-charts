# Plausible Analytics Helm Chart

Privacy-friendly, cookie-free web analytics. GDPR compliant without consent banners.

## Overview

This chart deploys [Plausible Analytics Community Edition](https://plausible.io) on Kubernetes with:

- Plausible server
- PostgreSQL (for user data and configuration)
- ClickHouse (for analytics events)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support (for persistence)

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

Generate a secret key:

```bash
openssl rand -base64 48
```

### Database Options

#### Bundled Databases (default)

PostgreSQL and ClickHouse are deployed as subcharts by default.

#### External Databases

To use external databases:

```yaml
postgresql:
  enabled: false

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
- PostgreSQL: 256Mi RAM
- ClickHouse: 512Mi RAM (analytics data)

## Upgrading

```bash
helm dependency update
helm upgrade plausible . -f values.yaml
```

## Links

- [Plausible Documentation](https://plausible.io/docs)
- [Community Edition](https://github.com/plausible/community-edition)
- [Configuration Options](https://github.com/plausible/community-edition/wiki/configuration)
