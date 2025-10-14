# civicrm

![Version: 1.0.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 6.7.0](https://img.shields.io/badge/AppVersion-6.7.0-informational?style=flat-square)

CiviCRM Standalone - open source CRM for nonprofits, NGOs and advocacy organizations

## Description

CiviCRM is a web-based, open source CRM (Constituent Relationship Management) software for organizations focused on nonprofit and civic missions. This Helm chart deploys CiviCRM Standalone. An external database (MySQL/MariaDB) is required.

## Requirements

| Repository            | Name   | Version |
| --------------------- | ------ | ------- |
| file://../../common   | common | 0.1.0   |

## Installation

### Prerequisites

1. A MySQL 5.7+ or MariaDB 10.0.2+ database
2. Create the database and user:
   ```sql
   CREATE DATABASE civicrm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   CREATE USER 'civicrm'@'%' IDENTIFIED BY 'secure-password';
   GRANT ALL PRIVILEGES ON civicrm.* TO 'civicrm'@'%';
   FLUSH PRIVILEGES;
   ```

3. Create a Kubernetes secret with the database password:
   ```bash
   kubectl create secret generic civicrm-db-secret \
     --from-literal=password='secure-password'
   ```

### Installation

```bash
helm install my-civicrm ./charts/apps/civicrm \
  --set database.host=mysql.example.com \
  --set database.name=civicrm \
  --set database.user=civicrm \
  --set database.existingSecret=civicrm-db-secret \
  --set civicrm.baseUrl=https://civicrm.example.com \
  --set civicrm.siteKey=$(openssl rand -hex 16) \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=civicrm.example.com
```

## Configuration

### Key Values

| Parameter                        | Description                          | Default                      |
| -------------------------------- | ------------------------------------ | ---------------------------- |
| `nameOverride`                   | Override chart name                  | `""`                         |
| `fullnameOverride`               | Override full resource names         | `""`                         |
| `civicrm.baseUrl`                | Base URL for CiviCRM (required)      | `http://civicrm.example.com` |
| `civicrm.siteKey`                | Site key for security                | `""`                         |
| `database.host`                  | Database hostname (required)         | `""`                         |
| `database.port`                  | Database port                        | `3306`                       |
| `database.name`                  | Database name (required)             | `civicrm`                    |
| `database.user`                  | Database user (required)             | `civicrm`                    |
| `database.existingSecret`        | Existing secret with DB password     | `""`                         |
| `persistence.public.enabled`     | Enable persistence for public files  | `true`                       |
| `persistence.public.size`        | Size of public volume                | `10Gi`                       |
| `persistence.private.enabled`    | Enable persistence for private files | `true`                       |
| `persistence.private.size`       | Size of private volume               | `5Gi`                        |
| `persistence.extensions.enabled` | Enable persistence for extensions    | `true`                       |
| `persistence.extensions.size`    | Size of extensions volume            | `2Gi`                        |
| `ingress.enabled`                | Enable ingress                       | `false`                      |

See `values.yaml` for the complete list of configurable values.

## Database Configuration

CiviCRM requires an external MySQL 5.7+ or MariaDB 10.0.2+ database. Configure it in your values:

```yaml
database:
  host: mysql.example.com
  port: 3306
  name: civicrm
  user: civicrm
  existingSecret: civicrm-db-secret
  existingSecretPasswordKey: password
```

The database must be created with UTF-8MB4 encoding:

```sql
CREATE DATABASE civicrm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Persistence

CiviCRM requires three persistent volumes:

- **public**: Uploaded files, generated PDFs, cached templates (10Gi default)
- **private**: Templates, logs, sensitive data (5Gi default)
- **extensions**: Installed extensions (2Gi default)

To use existing PVCs:

```yaml
persistence:
  public:
    existingClaim: my-civicrm-public-pvc
  private:
    existingClaim: my-civicrm-private-pvc
  extensions:
    existingClaim: my-civicrm-ext-pvc
```

## Resource Naming

By default, resources are named `{release-name}-civicrm`. You can customize this:

### Using fullnameOverride for simple names

```bash
# Creates service named "crm" instead of "my-release-civicrm"
helm install my-release charts/apps/civicrm \
  --set database.host=mysql \
  --set database.existingSecret=civicrm-db-secret \
  --set fullnameOverride=crm
```

This creates:
- Service: `crm` (instead of `my-release-civicrm`)
- Deployment: `crm` (instead of `my-release-civicrm`)
- PVCs: `crm-public`, `crm-private`, `crm-ext`

**Connection string:** `http://crm.default.svc.cluster.local`

### Using nameOverride

```bash
# Changes the chart name component only
helm install my-app charts/apps/civicrm \
  --set nameOverride=webapp
```

This creates resources named `my-app-webapp`.

## Security

### Site Key

CiviCRM requires a site key for security. Generate one:

```bash
openssl rand -hex 16
```

Configure it via values or an existing secret:

```yaml
civicrm:
  siteKey: "your-generated-site-key"
  # OR
  existingSecretSiteKey: civicrm-sitekey-secret
  existingSecretSiteKeyKey: site-key
```

### Security Context

The chart runs with a non-root security context by default:

```yaml
securityContext:
  runAsUser: 33 # www-data
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

## Ingress

Enable ingress for external access:

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: civicrm.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: civicrm-tls
      hosts:
        - civicrm.example.com
```

## Upgrading

Before upgrading, always:

1. Backup your database
2. Backup persistent volumes
3. Read CiviCRM upgrade notes: https://docs.civicrm.org/sysadmin/en/latest/upgrade/

## Resources

- CiviCRM Documentation: https://docs.civicrm.org
- CiviCRM Home: https://civicrm.org
- Docker Images: https://github.com/civicrm/civicrm-docker

## Values

See `values.yaml` for detailed configuration options and `values.schema.json` for value validation.
