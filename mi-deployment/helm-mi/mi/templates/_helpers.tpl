{{/*
Common prefix prepended to Kubernetes resources of this chart
*/}}
{{- define "resource.prefix" -}}
{{- if .Values.cloudName -}}
{{ .Values.cloudName }}
{{- else -}}
{{- "cloud" }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "micro-integrator.labels" -}}
app.kubernetes.io/name: {{ include "micro-integrator.name" . }}
helm.sh/chart: {{ include "micro-integrator.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "micro-integrator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "micro-integrator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "micro-integrator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cp-secret-to-password-tmp" -}}
{{- if eq "azure" .Values.provider }}
{{- printf "cp /mnt/secrets-store/%s ${WSO2_SERVER_HOME}/password-tmp" .Values.azure.keyVault.secretIdentifiers.internalKeystorePassword -}}
{{- else if eq "aws" .Values.provider }}
{{- printf "cp /mnt/secrets-store/%s ${WSO2_SERVER_HOME}/password-tmp" .Values.aws.secretManager.secretIdentifiers.internalKeystorePassword.secretKey -}}
{{- else if eq "gcp" .Values.provider }}
{{- printf "cp /mnt/secrets-store/INTERNAL_KEYSTORE_PASSWORD ${WSO2_SERVER_HOME}/password-tmp" -}}
{{- end }}
{{- end -}}

{{- define "capp-storage-capacity" -}}
{{- if eq "aws" .Values.provider }}
{{- .Values.aws.storage.capacity -}}
{{- else if eq "gcp" .Values.provider }}
{{- .Values.gcp.storage.capacity -}}
{{- end }}
{{- end -}}

{{- define "capp-storage-class-name" -}}
{{- if eq "aws" .Values.provider }}
{{- .Values.aws.storage.storageClass -}}
{{- else if eq "gcp" .Values.provider }}
{{- .Values.gcp.storage.storageClass -}}
{{- end }}
{{- end -}}

