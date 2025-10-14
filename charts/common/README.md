# Common Library Chart

This chart provides reusable template helpers for other charts in this repository. It promotes DRY (Don't Repeat Yourself) principles by centralizing common Kubernetes patterns and reducing boilerplate.

## Usage

To use the helpers, add this chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 0.1.0
    repository: file://../../common
```

Then run `helm dependency update` to fetch the library chart.

Reference the helpers via the `common` chart name in your templates:

```yaml
{{ include "common.labels" . }}
```

## Available Helpers

### Labels and Metadata

#### `common.labels`

Standard Kubernetes labels following recommended practices.

```yaml
labels:
  {{- include "common.labels" . | nindent 2 }}
```

Outputs:

```yaml
helm.sh/chart: chart-name-1.0.0
app.kubernetes.io/name: chart-name
app.kubernetes.io/instance: release-name
app.kubernetes.io/managed-by: Helm
```

#### `common.selectorLabels`

Subset of labels for pod selectors.

```yaml
selector:
  matchLabels:
    {{- include "common.selectorLabels" . | nindent 4 }}
```

#### `common.metadata`

Complete metadata block with labels and annotations.

```yaml
metadata:
  {{- include "common.metadata" (dict "name" "my-resource" "root" $) | nindent 2 }}
```

### Images

#### `common.image`

Image reference with tag and pull policy.

```yaml
{{- include "common.image" (dict "repository" "nginx" "tag" "1.21" "pullPolicy" "IfNotPresent" "root" $) | nindent 2 }}
```

### Environment Variables

#### `common.env`

Environment variable from a value.

```yaml
env:
  {{- include "common.env" (dict "name" "DB_HOST" "value" "mysql.default.svc") | nindent 2 }}
```

#### `common.envSecret`

Environment variable from a secret.

```yaml
env:
  {{- include "common.envSecret" (dict "name" "DB_PASSWORD" "secret" "db-creds" "key" "password") | nindent 2 }}
```

#### `common.envConfigMap`

Environment variable from a configmap.

```yaml
env:
  {{- include "common.envConfigMap" (dict "name" "APP_CONFIG" "configMap" "app-config" "key" "config.json") | nindent 2 }}
```

### Volumes

#### `common.pvc`

Complete PersistentVolumeClaim resource.

```yaml
{{- include "common.pvc" (dict "name" "data" "spec" .Values.persistence.data "root" $) }}
```

#### `common.volumeMount`

Volume mount entry.

```yaml
volumeMounts:
  {{- include "common.volumeMount" (dict "name" "data" "mountPath" "/data" "subPath" "subdir" "readOnly" true) | nindent 2 }}
```

## Examples

See the following charts for real-world usage:

- [civicrm](../apps/civicrm) - Application chart using most helpers
- [letsencrypt-cloudflare-issuer](../infra/letsencrypt-cloudflare-issuer) - Infrastructure chart using label helpers
- [metallb-config](../infra/metallb-config) - Infrastructure chart with metadata helpers

## Contributing

When adding new helpers:

1. Include clear documentation comments in `_helpers.tpl`
2. Show usage examples
3. Update this README
4. Test with at least one chart in the repository
