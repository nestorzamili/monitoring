#!/bin/sh
set -eu

INPUT=/etc/alertmanager/alertmanager.yml.tpl
OUTPUT=/tmp/alertmanager.yml

awk '
{
  gsub(/@@ALERT_INSTANCE@@/, ENVIRON["ALERT_INSTANCE"])
  gsub(/@@TELEGRAM_BOT_TOKEN@@/, ENVIRON["TELEGRAM_BOT_TOKEN"])
  gsub(/@@TELEGRAM_CHAT_ID@@/, ENVIRON["TELEGRAM_CHAT_ID"])
  print
}
' "$INPUT" > "$OUTPUT"

exec /bin/alertmanager \
  --config.file="$OUTPUT" \
  --storage.path=/alertmanager
