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
Create the name of the service account to use
*/}}
{{- define "ckan.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ckan.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Scope annotations for SealedSecret objects.

SealedSecrets binds ciphertext to a scope at seal time. The scope used by
kubeseal MUST match the scope the controller infers from these annotations,
or the controller reports "no key could decrypt secret".

  strict         (default) ciphertext is bound to namespace + secret name
  namespace-wide ciphertext may be reused under any name in one namespace
  cluster-wide   ciphertext may be unsealed into ANY namespace under ANY name

Prefer strict. On a shared cluster, cluster-wide means anyone who can create a
SealedSecret in any namespace can unseal these values into their own namespace.
*/}}
{{- define "ckan.sealedSecretAnnotations" -}}
{{- $scope := .Values.general.sealedSecretScope | default "strict" -}}
{{- if eq $scope "cluster-wide" }}
annotations:
  sealedsecrets.bitnami.com/cluster-wide: "true"
{{- else if eq $scope "namespace-wide" }}
annotations:
  sealedsecrets.bitnami.com/namespace-wide: "true"
{{- else if ne $scope "strict" }}
{{- fail (printf "\n\n[CONFIG ERROR]: general.sealedSecretScope must be one of 'strict', 'namespace-wide' or 'cluster-wide' (got %q).\n" $scope) }}
{{- end }}
{{- end -}}

{{/*
Guardrail: every value placed under a SealedSecret's encryptedData must be
SealedSecrets ciphertext. A single plaintext entry makes the controller reject
the whole object with "illegal base64 data", so the Secret is never created and
every workload consuming it fails to start.

Non-secret configuration belongs in .Values.ckan.config (rendered to a
ConfigMap), not in an env map that gets sealed.

Usage:
  {{- include "ckan.validateSealedData" (dict "data" .Values.ckan.env "path" "ckan.env") }}
*/}}
{{- define "ckan.validateSealedData" -}}
{{- $path := .path -}}
{{- range $key, $value := .data }}
{{- if not (regexMatch "^[A-Za-z0-9+/]{100,}={0,2}$" ($value | toString)) }}
{{- fail (printf "\n\n[SEALED SECRET ERROR]: '%s.%s' is not SealedSecrets ciphertext.\nEvery value under an encryptedData map must be sealed with kubeseal.\nMove non-secret configuration to '.Values.ckan.config' instead, or seal this value.\n" $path $key) }}
{{- end }}
{{- end }}
{{- end -}}
