# civicrm

![Version: 1.1.0](https://img.shields.io/badge/Version-1.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 6.7.1](https://img.shields.io/badge/AppVersion-6.7.1-informational?style=flat-square)

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
     --from-literal=password='secure-db-password'
   ```

### Installation

```bash
helm install my-civicrm ./charts/apps/civicrm \
  --set database.host=mysql.example.com \
  --set database.name=civicrm \
  --set database.user=civicrm \
  --set database.existingSecret=civicrm-db-secret \
  --set civicrm.baseUrl=https://civicrm.example.com \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=civicrm.example.com
```

## Configuration

### Key Values

| Parameter                        | Description                          | Default                      |
| -------------------------------- | ------------------------------------ | ---------------------------- |
| `nameOverride`                   | Override chart name                  | `""`                         |
| `fullnameOverride`               | Override full resource names         | `""`                         |
| `service.port`                   | Service port (8080 for non-root)     | `8080`                       |
| `civicrm.baseUrl`                | Base URL for CiviCRM (required)      | `http://civicrm.example.com` |
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

## Initial Installation

CiviCRM requires a one-time installation after the first deployment. You can use either method:

### Option 1: Web Installer (Recommended)

1. Navigate to your CiviCRM URL (e.g., `https://civicrm.example.com`)
2. Fill in the installation form:
   - **Database Server**: `{database.host}:{database.port}` (e.g., `mysql:3306`)
   - **Database Name**: `{database.name}` (e.g., `civicrm`)
   - **Database Username**: `{database.user}` (e.g., `civicrm`)
   - **Database Password**: The password from your secret
   - **Admin Email**: `your-admin@example.com`
   - **Admin Password**: Your secure admin password
3. Click "Install CiviCRM"

### Option 2: Command Line Installation

Execute into the pod and run the installation command:

```bash
# Get the pod name
kubectl get pods -l app.kubernetes.io/name=civicrm

# Execute into the pod
kubectl exec -it <pod-name> -- bash

# Run the installation (replace values with your configuration)
cv core:install \
  --db="mysql://<database.user>:<database.password>@<database.host>:<database.port>/<database.name>" \
  --cms-base-url="<civicrm.baseUrl>" \
  -m extras.adminUser="admin" \
  -m extras.adminPass="<your-admin-password>" \
  -m extras.adminEmail="<your-admin-email>"
```

**Example**:
```bash
cv core:install \
  --db="mysql://civicrm:mypassword@mysql:3306/civicrm" \
  --cms-base-url="https://civicrm.example.com" \
  -m extras.adminUser="admin" \
  -m extras.adminPass="AdminPass123" \
  -m extras.adminEmail="admin@example.com"
```

**Note**: The installation persists to the database and persistent volumes. Pod restarts will not affect the installed CiviCRM instance.

## Database Setup

CiviCRM requires an external MySQL 5.7+ or MariaDB 10.0.2+ database.

### MySQL/MariaDB Configuration

Create the database and user with proper encoding and permissions:

```sql
CREATE DATABASE civicrm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'civicrm'@'%' IDENTIFIED BY 'your-secure-password';
GRANT ALL PRIVILEGES ON civicrm.* TO 'civicrm'@'%';
FLUSH PRIVILEGES;
```

**Important**: The `utf8mb4` character set is required for full Unicode support, including emoji and special characters.

### Create Kubernetes Secret

Create a secret for the database password:

```bash
kubectl create secret generic civicrm-db-secret \
  --namespace=default \
  --from-literal=password='your-secure-password'
```

For specific namespaces:

```bash
kubectl create secret generic pauseai-es-civicrm-db \
  --namespace=pauseai-es \
  --from-literal=password='your-secure-password'
```

### Helm Configuration

Configure the database connection in your values:

```yaml
database:
  host: mysql.example.com
  port: 3306
  name: civicrm
  user: civicrm
  existingSecret: civicrm-db-secret
  existingSecretPasswordKey: password
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

CiviCRM automatically generates a site key during first-time installation. No manual configuration is required. The site key is stored in CiviCRM's configuration files on the persistent storage.

### Security Context

The chart runs with a non-root security context by default:

```yaml
securityContext:
  runAsUser: 33 # www-data
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

**Port Configuration**: CiviCRM runs on port 8080 instead of 80 to support non-root execution. Apache is configured via the `APACHE_PORT` environment variable to listen on port 8080, which doesn't require root privileges. The ingress controller handles external port 80/443 traffic and routes it to the service on port 8080.

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
