# Headscale Helm Chart

Self-hosted Tailscale control server for creating private mesh networks.

## Overview

This chart deploys:

- **Headscale server**: Control plane for Tailscale clients
- **Subnet router** (optional): Advertises Kubernetes network routes to the tailnet

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner (if persistence enabled)

## Installation

```bash
helm install headscale ./headscale \
  --set headscale.serverUrl=https://headscale.example.com \
  --set ingress.enabled=true \
  --set ingress.host=headscale.example.com
```

## Configuration

### Required Values

| Parameter | Description |
|-----------|-------------|
| `headscale.serverUrl` | Public URL where Headscale is accessible |

### Headscale Server

| Parameter | Description | Default |
|-----------|-------------|---------|
| `headscale.serverUrl` | Public URL for client connections | `""` (required) |
| `headscale.ipPrefixes.v4` | IPv4 prefix for tailnet | `100.64.0.0/10` |
| `headscale.ipPrefixes.v6` | IPv6 prefix for tailnet | `fd7a:115c:a1e0::/48` |
| `headscale.baseDomain` | Base domain for MagicDNS | `""` |
| `headscale.dns.magicDns` | Enable MagicDNS | `true` |
| `headscale.dns.nameservers` | Upstream DNS servers | `[1.1.1.1, 8.8.8.8]` |
| `headscale.database.type` | Database type: sqlite or postgres | `sqlite` |
| `headscale.logLevel` | Log level | `info` |

### DERP (Relay)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `headscale.derp.externalEnabled` | Use external DERP servers | `true` |
| `headscale.derp.url` | DERP map URL | Tailscale's default |
| `headscale.derp.embeddedEnabled` | Run embedded DERP server | `false` |
| `headscale.derp.embeddedPort` | Embedded DERP STUN port | `3478` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.size` | PVC size | `1Gi` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Ingress hostname | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls` | TLS configuration | `[]` |

### Subnet Router

| Parameter | Description | Default |
|-----------|-------------|---------|
| `subnetRouter.enabled` | Enable subnet router | `false` |
| `subnetRouter.routes` | Routes to advertise | `[]` |
| `subnetRouter.authKey` | Pre-auth key | `""` |
| `subnetRouter.existingSecret` | Existing secret with auth key | `""` |
| `subnetRouter.existingSecretKey` | Key in existing secret | `auth-key` |

## Usage

### Initial Setup

1. Deploy Headscale:

```bash
helm install headscale ./headscale \
  --set headscale.serverUrl=https://headscale.example.com \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.host=headscale.example.com
```

2. Create a user:

```bash
kubectl exec -it deploy/headscale -- headscale users create admin
```

3. Generate a pre-auth key:

```bash
kubectl exec -it deploy/headscale -- headscale preauthkeys create \
  --user admin --expiration 24h
```

4. Connect a client:

```bash
tailscale up --login-server https://headscale.example.com
```

### Subnet Router

To expose Kubernetes networks to the tailnet:

1. Generate a pre-auth key for the subnet router:

```bash
kubectl exec -it deploy/headscale -- headscale preauthkeys create \
  --user admin --expiration 365d --reusable
```

2. Create a SealedSecret with the auth key, or add it to values:

```yaml
subnetRouter:
  enabled: true
  routes:
    - 172.31.240.0/20  # MetalLB private-ip pool
  existingSecret: headscale-subnet-router-key
  existingSecretKey: auth-key
```

3. Approve the route:

```bash
# List routes
kubectl exec -it deploy/headscale -- headscale routes list

# Enable route
kubectl exec -it deploy/headscale -- headscale routes enable -r <route-id>
```

### Management Commands

```bash
# List users
kubectl exec -it deploy/headscale -- headscale users list

# List nodes
kubectl exec -it deploy/headscale -- headscale nodes list

# List routes
kubectl exec -it deploy/headscale -- headscale routes list

# Delete a node
kubectl exec -it deploy/headscale -- headscale nodes delete -i <node-id>
```

## PostgreSQL Backend

For high availability, use PostgreSQL instead of SQLite:

```yaml
headscale:
  database:
    type: postgres
    postgres:
      host: postgresql.default.svc
      port: 5432
      name: headscale
      user: headscale
      existingSecret: headscale-db-secret
      existingSecretKey: password
```

## OIDC Authentication

Enable OIDC for web-based authentication:

```yaml
headscale:
  oidc:
    enabled: true
    issuer: https://auth.example.com
    clientId: headscale
    existingSecret: headscale-oidc
    existingSecretKey: client-secret
```
