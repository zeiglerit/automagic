{{- define "ai-inference.name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "ai-inference.fullname" -}}
{{ .Release.Name }}-{{ .Chart.Name }}
{{- end }}

{{- define "ai-inference.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}
