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
          {{ if eq .Status "resolved" }}✅{{ else if eq .CommonLabels.severity "critical" }}🚨{{ else if eq .CommonLabels.severity "warning" }}⚠️{{ else }}ℹ️{{ end }} <b>{{ .CommonLabels.alertname }}</b>
          <b>Status:</b> {{ .Status | toUpper }}
          <b>Severity:</b> {{ .CommonLabels.severity | toUpper }}
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}
          {{ if eq .Status "resolved" }}<b>Ended:</b> {{ (index .Alerts 0).EndsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}{{ end }}

  - name: telegram-critical
    telegram_configs:
      - bot_token: '@@TELEGRAM_BOT_TOKEN@@'
        chat_id: @@TELEGRAM_CHAT_ID@@
        parse_mode: HTML
        send_resolved: true
        message: |
          {{ if eq .Status "resolved" }}✅{{ else }}🚨{{ end }} <b>{{ .CommonLabels.alertname }}</b>
          <b>Status:</b> {{ .Status | toUpper }}
          <b>Severity:</b> CRITICAL
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}
          {{ if eq .Status "resolved" }}<b>Ended:</b> {{ (index .Alerts 0).EndsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}{{ end }}

  - name: telegram-info
    telegram_configs:
      - bot_token: '@@TELEGRAM_BOT_TOKEN@@'
        chat_id: @@TELEGRAM_CHAT_ID@@
        parse_mode: HTML
        send_resolved: true
        message: |
          {{ if eq .Status "resolved" }}✅{{ else }}ℹ️{{ end }} <b>{{ .CommonLabels.alertname }}</b>
          <b>Status:</b> {{ .Status | toUpper }}
          <b>Severity:</b> INFO
          <b>Instance:</b> {{ if .CommonLabels.instance }}{{ .CommonLabels.instance }}{{ else }}@@ALERT_INSTANCE@@{{ end }}
          <b>Summary:</b> {{ .CommonAnnotations.summary }}
          <b>Started:</b> {{ (index .Alerts 0).StartsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}
          {{ if eq .Status "resolved" }}<b>Ended:</b> {{ (index .Alerts 0).EndsAt.Local.Format "02 Jan 2006 15:04:05 MST" }}{{ end }}
