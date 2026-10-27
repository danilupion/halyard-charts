# rest-server

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 0.14.0](https://img.shields.io/badge/AppVersion-0.14.0-informational?style=flat-square)

restic's rest-server, an append-only backup target, with an optional prune job

## Description

[rest-server](https://github.com/restic/rest-server) stores [restic](https://restic.net) repositories in a host
folder and serves them over HTTP. Defaults:

- **Append-only** (`--append-only`): clients can add snapshots but not delete or overwrite them, so a compromised
  client can't destroy its own backups.
- **Private repositories** (`--private-repos`): each user reaches only the repository named after it, `/<user>/`.
- **Users from a Secret** holding an htpasswd file. It is mounted as a folder, so changes reach the pod and
  rest-server reloads them without a restart. Without a Secret the server runs and refuses every request.
- **The host folder must exist** (`hostPathType: Directory`): if the disk behind it is missing, the pod doesn't
  start, rather than writing backups elsewhere.

restic encrypts everything before it leaves the client, so the server never sees the data or the repository
passwords. The transport is plain HTTP; use it over a private network or VPN.

### Prune job

Because clients can't delete, retention runs here: a CronJob mounts the same folder and, for each listed
repository, runs `restic forget --prune` (grouped by host, keeping one snapshot a day for 30 days and one a week
for 90) and then `restic check`, re-reading 5% of the data. `startingDeadlineSeconds` lets a run missed while the
node was off start when it is back. When every repository succeeds, it fetches an optional heartbeat URL.

## Requirements

| Repository          | Name   | Version |
| ------------------- | ------ | ------- |
| file://../../common | common | 0.2.0   |

## Installation

```bash
# One htpasswd line per user (bcrypt)
htpasswd -nB cerebro >> htpasswd
kubectl create secret generic rest-server-htpasswd --from-file=htpasswd

helm install rest-server ./charts/backup/rest-server \
  --set storage.hostPath=/srv/restic \
  --set htpasswd.existingSecret=rest-server-htpasswd
```

A client then uses `rest:http://cerebro:<password>@<host>:8000/cerebro/`.

To enable pruning, create a Secret with one key per repository holding its restic password, and set:

```yaml
prune:
  enabled: true
  repositories: [cerebro]
  passwordsSecret: rest-server-repository-passwords
```

## Values

| Key | Default | Description |
| --- | --- | --- |
| `storage.hostPath` | `""` | Host folder holding the repositories (required) |
| `storage.hostPathType` | `Directory` | `Directory` refuses to start while the folder is missing |
| `htpasswd.existingSecret` | `""` | Secret holding the htpasswd file |
| `htpasswd.key` | `htpasswd` | Key of that Secret |
| `restServer.appendOnly` | `true` | Clients may add but not delete |
| `restServer.privateRepos` | `true` | Each user reaches only `/<user>/` |
| `restServer.extraArgs` | `[]` | Extra rest-server flags |
| `service.type` | `ClusterIP` | `NodePort` with `service.nodePort` for a fixed host port |
| `prune.enabled` | `false` | Render the prune CronJob |
| `prune.schedule` | `0 12 * * 0` | Cron schedule, in `tz` |
| `prune.repositories` | `[]` | Repositories to prune |
| `prune.passwordsSecret` | `""` | Secret with one restic password per repository |
| `prune.forgetArgs` | 30 daily, 90 days weekly, by host | `restic forget` flags |
| `prune.check.readDataSubset` | `5%` | Share of the data `restic check` re-reads; `""` checks the structure only |
| `prune.heartbeat.existingSecret` | `""` | Secret holding a URL fetched after a fully successful run |
