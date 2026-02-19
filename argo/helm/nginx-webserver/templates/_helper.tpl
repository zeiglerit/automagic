{{- define "nginx-webserver.name" -}}
nginx-webserver
{{= end }}

{{- define "nginx-webserver.fullname" -}}
{{ include "nginx-webserver.name" . }}
{{- end}}
