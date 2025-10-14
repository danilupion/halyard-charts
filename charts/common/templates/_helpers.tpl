{{/*
Standard Kubernetes labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels for matching pods to services
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Standard metadata block with labels and annotations
Usage: include "common.metadata" (dict "name" "resource-name" "root" $)
*/}}
{{- define "common.metadata" -}}
name: {{ .name | required "name is required for common.metadata" }}
{{- with .namespace }}
namespace: {{ . }}
{{- end }}
labels:
  {{- include "common.labels" .root | nindent 2 }}
{{- with .root.Values.commonLabels }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .root.Values.commonAnnotations }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Image reference with optional tag/digest
Usage: include "common.image" (dict "repository" "nginx" "tag" "1.21" "pullPolicy" "IfNotPresent" "root" $)
*/}}
{{- define "common.image" -}}
{{- $tag := .tag | default .root.Chart.AppVersion -}}
image: {{ .repository }}{{ if $tag }}:{{ $tag }}{{ end }}
imagePullPolicy: {{ .pullPolicy | default "IfNotPresent" }}
{{- end -}}

{{/*
PersistentVolumeClaim template
Usage: include "common.pvc" (dict "name" "data" "spec" .Values.persistence.data "root" $)
*/}}
{{- define "common.pvc" -}}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  {{- include "common.metadata" (dict "name" .name "root" .root) | nindent 2 }}
spec:
  {{- with .spec.accessModes }}
  accessModes:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .spec.storageClassName }}
  storageClassName: {{ . }}
  {{- end }}
  resources:
    requests:
      storage: {{ .spec.size | required "storage size is required" }}
  {{- with .spec.selector }}
  selector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

{{/*
Environment variable from a value
Usage: include "common.env" (dict "name" "DB_HOST" "value" "mysql.default.svc")
*/}}
{{- define "common.env" -}}
- name: {{ .name | required "env name is required" }}
  value: {{ .value | quote }}
{{- end -}}

{{/*
Environment variable from a secret
Usage: include "common.envSecret" (dict "name" "DB_PASSWORD" "secret" "db-creds" "key" "password")
*/}}
{{- define "common.envSecret" -}}
- name: {{ .name | required "env name is required" }}
  valueFrom:
    secretKeyRef:
      name: {{ .secret | required "secret name is required" }}
      key: {{ .key | required "secret key is required" }}
{{- end -}}

{{/*
Environment variable from a configmap
Usage: include "common.envConfigMap" (dict "name" "APP_CONFIG" "configMap" "app-config" "key" "config.json")
*/}}
{{- define "common.envConfigMap" -}}
- name: {{ .name | required "env name is required" }}
  valueFrom:
    configMapKeyRef:
      name: {{ .configMap | required "configMap name is required" }}
      key: {{ .key | required "configMap key is required" }}
{{- end -}}

{{/*
Volume mount helper
Usage: include "common.volumeMount" (dict "name" "data" "mountPath" "/data" "subPath" "subdir" "readOnly" true)
*/}}
{{- define "common.volumeMount" -}}
- name: {{ .name | required "volume name is required" }}
  mountPath: {{ .mountPath | required "mountPath is required" }}
  {{- with .subPath }}
  subPath: {{ . }}
  {{- end }}
  {{- if .readOnly }}
  readOnly: true
  {{- end }}
{{- end -}}
