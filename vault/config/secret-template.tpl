{{- with secret "kv/data/upgrade-dev/domain1/database/staging/service1" }}
{{ .Data.data | toUnescapedJSON }}
{{- end }}
