{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ckan.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ckan.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ckan.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ckan.labels" -}}
helm.sh/chart: {{ include "ckan.chart" . }}
{{ include "ckan.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ckan.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ckan.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Datastore (Data API) config. Renamed from `dataAPI` to `datastore` for
consistency; `dataAPI` is still accepted as a backward-compatible alias so
existing environments do not break. Returns the resolved config dict.
*/}}
{{- define "ckan.datastore" -}}
{{- $merged := dict -}}
{{- with .Values.dataAPI -}}{{- $merged = deepCopy . -}}{{- end -}}
{{- with .Values.datastore -}}{{- $merged = mergeOverwrite $merged (deepCopy .) -}}{{- end -}}
{{- toYaml $merged -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "ckan.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ckan.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
