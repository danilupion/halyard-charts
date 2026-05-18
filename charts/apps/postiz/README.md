# postiz

Helm chart that deploys [Postiz](https://postiz.com) bundled with its required
Temporal stack (server + dedicated Postgres + Elasticsearch visibility store).

## Components

| Component                          | Purpose                                    |
| ---------------------------------- | ------------------------------------------ |
| `postiz` Deployment                | Frontend, backend and orchestrator (pm2)   |
| `postiz-temporal` Deployment       | Temporal server (auto-setup image)         |
| `postiz-temporal-postgresql` STS   | Dedicated Postgres for Temporal persistence|
| `postiz-temporal-elasticsearch` STS| ES 7.x visibility store for Temporal       |

Postiz uses the shared cluster Postgres / Redis for its own data — only the
Temporal stack is bundled in this chart.

## Image notes

The upstream Postiz image runs nginx workers as user `www` while pm2/Node runs
as root. Uploads written by Node land as `root:root`, which nginx can't read.
The deployment patches `/etc/nginx/nginx.conf` on startup (`sed user www -> root`)
so both processes share the same UID and `/uploads/` is readable end-to-end.

## Troubleshooting

### Posts stay scheduled forever and never publish

**Symptom**: A post in the Postiz calendar sits as "scheduled" (purple) past
its publication time. No error appears in the UI. `kubectl logs deploy/postiz`
shows the post payload being created but no Temporal workflow activity afterwards.

**Cause**: The orchestrator's Temporal workers can lose their connection to the
Temporal server (e.g., after Temporal/Elasticsearch is restarted) without
crashing the Node process. PM2 sees the process as healthy and doesn't restart
it, so workflow tasks pile up in queues with no worker polling them.

**Verification**: List active Temporal workflows. Stuck posts show as `Running`
indefinitely with only `WorkflowExecutionStarted` + `WorkflowTaskScheduled`
events (no `WorkflowTaskStarted`):

```bash
kubectl -n postiz exec deploy/postiz-temporal -- \
  temporal workflow list --address postiz-temporal:7233 --namespace default
```

**Fix**: Restart the orchestrator process inside the Postiz pod. This
re-registers all per-provider workers (`main`, `x`, `linkedin`, …) and resumes
the stuck workflows automatically:

```bash
kubectl -n postiz exec deploy/postiz -- pm2 restart orchestrator
```

The pod itself does not need to be deleted — pm2 keeps `backend` and `frontend`
online while it restarts the orchestrator.
