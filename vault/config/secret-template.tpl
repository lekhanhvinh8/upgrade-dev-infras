{
  {{- with secret "kv/data/upgrade-dev/domain1/database/staging/service1" }}
  {{- $data := .Data.data }}
  {{- $length := len $data }}
  {{- $i := 0 }}
  {{- range $key, $value := $data }}
  "{{ $key }}": "{{ $value }}"{{ if ne (add $i 1) $length }},{{ end }}
  {{- $i = add $i 1 }}
  {{- end }}
  {{- end }}
}
