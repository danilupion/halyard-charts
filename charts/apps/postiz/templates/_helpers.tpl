{{/*
Names for the Temporal sub-components. They live in the same release but need
predictable, distinct service names.
*/}}
{{- define "postiz.temporal.server.fullname" -}}
{{- printf "%s-temporal" (include "common.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "postiz.temporal.postgresql.fullname" -}}
{{- printf "%s-temporal-postgresql" (include "common.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "postiz.temporal.elasticsearch.fullname" -}}
{{- printf "%s-temporal-elasticsearch" (include "common.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "postiz.temporal.ui.fullname" -}}
{{- printf "%s-temporal-ui" (include "common.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Resolved Postiz URLs (frontend/backend fall back to MAIN_URL when unset).
*/}}
{{- define "postiz.urls.frontend" -}}
{{- default .Values.postiz.urls.main .Values.postiz.urls.frontend -}}
{{- end -}}

{{- define "postiz.urls.backend" -}}
{{- if .Values.postiz.urls.backend -}}
{{- .Values.postiz.urls.backend -}}
{{- else -}}
{{- printf "%s/api" .Values.postiz.urls.main -}}
{{- end -}}
{{- end -}}
