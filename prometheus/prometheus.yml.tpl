global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    instance: '@@ALERT_INSTANCE@@'

rule_files:
  - /etc/prometheus/rules/*.yml

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets:
          - prometheus:9090
        labels:
          service: prometheus

  - job_name: node
    static_configs:
      - targets:
          - node-exporter:9100
        labels:
          node_name: '@@ALERT_INSTANCE@@'
    relabel_configs:
      - source_labels: [node_name]
        target_label: instance
