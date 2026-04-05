global:
  resolve_timeout: 5m

route:
  receiver: telegram-warning
  group_by:
    - alertname
    - severity
    - service
    - instance
  group_wait: 10s
  group_interval: 1m
  repeat_interval: 4h
  routes:
    - receiver: telegram-critical
      matchers:
        - severity="critical"
      repeat_interval: 1h
    - receiver: telegram-info
      matchers:
        - severity="info"
      repeat_interval: 12h

receivers:
  - name: telegram-warning
    telegram_configs:
      - bot_token: '@@TELEGRAM_BOT_TOKEN@@'
        chat_id: @@TELEGRAM_CHAT_ID@@
        parse_mode: HTML
        send_resolved: true
        message: |
          <b>[{{ .Status | toUpper }}][{{ .CommonLabels.severity | toUpper }}]</b> {{ .CommonLabels.alertname }}
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          {{ if .CommonLabels.service }}<b>Target:</b> {{ .CommonLabels.service }}{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Format "02 Jan 2006 15:04:05 MST" }}
          <b>Details:</b> {{ .CommonAnnotations.description }}

  - name: telegram-critical
    telegram_configs:
      - bot_token: '@@TELEGRAM_BOT_TOKEN@@'
        chat_id: @@TELEGRAM_CHAT_ID@@
        parse_mode: HTML
        send_resolved: true
        message: |
          <b>[{{ .Status | toUpper }}][CRITICAL]</b> {{ .CommonLabels.alertname }}
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          {{ if .CommonLabels.service }}<b>Target:</b> {{ .CommonLabels.service }}{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Format "02 Jan 2006 15:04:05 MST" }}
          <b>Details:</b> {{ .CommonAnnotations.description }}

  - name: telegram-info
    telegram_configs:
      - bot_token: '@@TELEGRAM_BOT_TOKEN@@'
        chat_id: @@TELEGRAM_CHAT_ID@@
        parse_mode: HTML
        send_resolved: true
        message: |
          <b>[{{ .Status | toUpper }}][INFO]</b> {{ .CommonLabels.alertname }}
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          {{ if .CommonLabels.service }}<b>Target:</b> {{ .CommonLabels.service }}{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Format "02 Jan 2006 15:04:05 MST" }}
          <b>Details:</b> {{ .CommonAnnotations.description }}
