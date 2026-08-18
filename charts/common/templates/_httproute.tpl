{{/*
Gateway API HTTPRoute for exposing the chart's HTTP service through a Gateway tier.
Renders nothing unless the route block's "enabled" is true. By default it emits a
single "/" PathPrefix rule targeting the chart's Service on .Values.service.port
(HTTPRoute backendRefs require a numeric port, unlike Ingress which can use the
port name).
Usage: include "common.httproute" (dict "root" $)
Optional dict keys:
  route       - route values block (default: root.Values.route)
  name        - HTTPRoute name (default: common.fullname)
  serviceName - backend Service name (default: common.fullname)
  port        - backend Service port number (default: root.Values.service.port)
Route block schema (mirrors the ergonomics of the ingress block):
  route:
    enabled: false
    parentRefs: []      # Gateways to attach to (name/namespace/sectionName)
    hostnames: []
    rules: []           # optional full override of spec.rules
    annotations: {}     # e.g. dns/managed: "false"
    timeouts: {}        # e.g. request: 3600s (long-lived connections)
*/}}
{{- define "common.httproute" -}}
{{- $root := .root | required "root is required for common.httproute" -}}
{{- $route := .route | default $root.Values.route -}}
{{- if $route.enabled }}
{{- $name := .name | default (include "common.fullname" $root) -}}
{{- $serviceName := .serviceName | default (include "common.fullname" $root) -}}
{{- /* lazy lookup: charts without a top-level service block must pass "port" */ -}}
{{- $svc := $root.Values.service | default dict -}}
{{- $port := .port | default $svc.port -}}
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  {{- include "common.metadata" (dict "name" $name "root" $root) | nindent 2 }}
  {{- with $route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  parentRefs:
    {{- toYaml ($route.parentRefs | required "route.parentRefs is required when the route is enabled") | nindent 4 }}
  {{- with $route.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- if $route.rules }}
    {{- toYaml $route.rules | nindent 4 }}
    {{- else }}
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: {{ $serviceName }}
          port: {{ $port | required "backend port is required (route dict port or .Values.service.port)" }}
      {{- with $route.timeouts }}
      timeouts:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
{{- end }}
{{- end -}}
