{{/*
Expand the name of the chart.
*/}}
{{- define "prowlarr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prowlarr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prowlarr.labels" -}}
helm.sh/chart: {{ include "prowlarr.chart" . }}
{{ include "prowlarr.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prowlarr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prowlarr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: indexer
{{- end }}
