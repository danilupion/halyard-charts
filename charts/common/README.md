# Common Library Chart

This chart provides reusable template helpers for other charts in this repository.

## Usage

To use the helpers, add this chart as a dependency in your `Chart.yaml`:

```yaml
dependencies:
  - name: common
    version: 0.1.0
    repository: file://../../common
```

Then reference the helpers via the `common` chart name. For example:

```yaml
{{ include "common.labels" . }}
```

See existing charts for more examples.
