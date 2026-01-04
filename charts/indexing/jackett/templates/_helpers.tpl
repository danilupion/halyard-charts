{{/*
Expand the name of the chart.
*/}}
{{- define "jackett.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "jackett.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "jackett.labels" -}}
helm.sh/chart: {{ include "jackett.chart" . }}
{{ include "jackett.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "jackett.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jackett.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: indexer
{{- end }}
