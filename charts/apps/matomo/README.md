Helm chart that wraps the Bitnami Matomo chart and adds a log-import CronJob that replays ingress-nginx controller logs into Matomo.

Usage notes:
- Values under `bitnamiMatomo` map 1:1 to the upstream Bitnami chart. Use them to configure ingress, persistence, internal MariaDB, or an external database (via `bitnamiMatomo.externalDatabase`).
- By default the CronJob mounts `/var/log/containers` on the node. For single-node clusters, set `cronjob.nodeSelector` + `cronjob.hostPath.path` to the node that stores ingress logs.
- Provide `MATOMO_URL` and `MATOMO_TOKEN` via Kubernetes secrets named in `cronjob.matomo.*` (keys `url` and `token` respectively).
- After adding this chart run `helm dependency update charts/apps/matomo` so both `common` and the Bitnami `matomo` dependency are vendored locally.
