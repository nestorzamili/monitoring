#!/bin/sh
set -eu

INPUT=/etc/prometheus/prometheus.yml.tpl
OUTPUT=/tmp/prometheus.yml

awk '
{
  gsub(/@@ALERT_INSTANCE@@/, ENVIRON["ALERT_INSTANCE"])
  print
}
' "$INPUT" > "$OUTPUT"

exec /bin/prometheus \
  --config.file="$OUTPUT" \
  --storage.tsdb.path=/prometheus \
  --storage.tsdb.retention.time=7d \
  --storage.tsdb.retention.size=512MB \
  --web.enable-lifecycle
