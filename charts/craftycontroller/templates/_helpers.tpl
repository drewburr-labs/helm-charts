{{/*
Expand the name of the chart.
*/}}
{{- define "craftycontroller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "craftycontroller.fullname" -}}
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
{{- define "craftycontroller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "craftycontroller.labels" -}}
helm.sh/chart: {{ include "craftycontroller.chart" . }}
{{ include "craftycontroller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "craftycontroller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "craftycontroller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "craftycontroller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "craftycontroller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
SFTP sidecar container spec
*/}}
{{- define "craftycontroller.sftp-sidecar" -}}
{{- with .Values.sftp }}
{{- if .enabled }}
- name: sftp
  image: "{{ .image.repository }}:{{ .image.tag | default $.Chart.AppVersion }}"
  imagePullPolicy: {{ .image.pullPolicy }}
  restartPolicy: Always
  env:
    - name: SFTP_USERS
      valueFrom:
        secretKeyRef:
          name: {{ .users.secretKeyRef.name }}
          key: {{ .users.secretKeyRef.key }}
    {{- with .additionalEnv }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  ports:
    - name: {{ .service.port.name }}
      containerPort: {{ .service.port.port }}
      protocol: {{ .service.port.protocol }}
  {{- with .livenessProbe }}
  resources:
    {{- toYaml .resources | nindent 4 }}
  livenessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .readinessProbe }}
  readinessProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .startupProbe }}
  startupProbe:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  securityContext:
    {{- toYaml .securityContext | nindent 4 }}
  volumeMounts:
    - name: sftp-host-keys
      mountPath: /etc/ssh-keys
    - name: sftp-scripts
      mountPath: /etc/sftp.d
    {{- range $name, $spec := .Values.persistence }}
    {{- if ne $spec.enabled false }}
    - name: {{ $name }}
      mountPath: {{ print "/home/crafty/" $spec.mountPath  }}
    {{- end }}
    {{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Volumes used by the SFTP sidecar
*/}}
{{- define "craftycontroller.sftp-volumes" -}}
{{- if .Values.sftp.enabled -}}
- name: sftp-host-keys
  secret:
    secretName: sftp-host-keys
- name: sftp-scripts
  configMap:
    name: sftp-scripts
    defaultMode: 0550
{{- end -}}
{{- end -}}
