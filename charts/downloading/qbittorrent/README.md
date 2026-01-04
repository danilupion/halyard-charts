# qBittorrent Helm Chart

A Helm chart for deploying qBittorrent - a free and open-source BitTorrent client.

## Features

- LinuxServer.io container image with PUID/PGID support
- Web UI exposed via ClusterIP service and optional Ingress
- Torrent traffic via configurable NodePort service
- Persistent storage for config and downloads
- Support for extra volumes (media hardlinking)
- Optional init container for permission setup

## Installation

```bash
helm dependency update
helm install qbittorrent . -n downloading --create-namespace
```

## Configuration

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container registry | `lscr.io` |
| `image.repository` | Container image | `linuxserver/qbittorrent` |
| `image.tag` | Image tag | `5.0.4` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |

### LinuxServer Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `linuxserver.puid` | User ID for file permissions | `1000` |
| `linuxserver.pgid` | Group ID for file permissions | `1000` |
| `linuxserver.tz` | Timezone | `Europe/Madrid` |

### qBittorrent Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `qbittorrent.webUiPort` | Web UI port | `8080` |
| `qbittorrent.torrentPort` | Torrent listening port | `6881` |

### Services

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Web UI service type | `ClusterIP` |
| `service.port` | Web UI service port | `8080` |
| `torrentService.enabled` | Enable torrent NodePort | `true` |
| `torrentService.type` | Torrent service type | `NodePort` |
| `torrentService.port` | Torrent service port | `6881` |
| `torrentService.nodePort` | NodePort for torrents | `31415` |
| `torrentService.udpEnabled` | Enable UDP port | `true` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.host` | Ingress hostname | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.tls` | TLS configuration | `[]` |

### Persistence

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.config.enabled` | Enable config PVC | `true` |
| `persistence.config.size` | Config PVC size | `1Gi` |
| `persistence.config.existingClaim` | Use existing PVC | `""` |
| `persistence.downloads.enabled` | Enable downloads PVC | `true` |
| `persistence.downloads.size` | Downloads PVC size | `100Gi` |
| `persistence.downloads.existingClaim` | Use existing PVC | `""` |
| `persistence.downloads.mountPath` | Downloads mount path | `/downloads` |

### Extra Volumes

For media hardlinking with *arr apps:

```yaml
extraVolumes:
  - name: movies
    persistentVolumeClaim:
      claimName: media-movies

extraVolumeMounts:
  - name: movies
    mountPath: /movies
```

## Example Values

### Basic Installation

```yaml
ingress:
  enabled: true
  className: nginx
  host: qbittorrent.example.com
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  tls:
    - secretName: qbittorrent-tls
      hosts:
        - qbittorrent.example.com
```

### With Existing Storage

```yaml
persistence:
  config:
    existingClaim: qbittorrent-config-pvc
  downloads:
    existingClaim: shared-downloads-pvc
```

## Port Forwarding

For torrent traffic, you need to forward the NodePort from your router to your Kubernetes node:

- TCP: Router port 31415 -> Node IP:31415
- UDP: Router port 31415 -> Node IP:31415

Adjust the port if using a different `torrentService.nodePort` value.
