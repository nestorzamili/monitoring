#!/bin/sh
set -eu

OUT_DIR=/textfile
TMP_FILE="$OUT_DIR/docker_health.prom.tmp"
OUT_FILE="$OUT_DIR/docker_health.prom"
TARGETS="${DOCKER_TARGETS:-naoto-be naoto-fe naoto-web naoto-docs}"
INTERVAL="${SCRAPE_INTERVAL_SECONDS:-30}"

write_metrics() {
  now="$(date +%s)"

  {
    echo "# HELP docker_health_collector_last_run_seconds Unix timestamp of the last successful Docker health collection."
    echo "# TYPE docker_health_collector_last_run_seconds gauge"
    echo "docker_health_collector_last_run_seconds $now"
    echo "# HELP docker_container_present Whether the target container exists."
    echo "# TYPE docker_container_present gauge"
    echo "# HELP docker_container_running Whether the target container is running."
    echo "# TYPE docker_container_running gauge"
    echo "# HELP docker_container_healthy Whether the target container Docker health status is healthy."
    echo "# TYPE docker_container_healthy gauge"
    echo "# HELP docker_container_restart_count Restart count reported by Docker."
    echo "# TYPE docker_container_restart_count gauge"

    for service in $TARGETS; do
      if inspect="$(docker inspect --type container --format '{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}|{{.RestartCount}}' "$service" 2>/dev/null)"; then
        status="$(printf '%s' "$inspect" | cut -d'|' -f1)"
        health="$(printf '%s' "$inspect" | cut -d'|' -f2)"
        restarts="$(printf '%s' "$inspect" | cut -d'|' -f3)"
        running=0
        healthy=0

        if [ "$status" = "running" ]; then
          running=1
        fi

        if [ "$health" = "healthy" ]; then
          healthy=1
        fi

        echo "docker_container_present{service=\"$service\"} 1"
        echo "docker_container_running{service=\"$service\"} $running"
        echo "docker_container_healthy{service=\"$service\"} $healthy"
        echo "docker_container_restart_count{service=\"$service\"} $restarts"
      else
        echo "docker_container_present{service=\"$service\"} 0"
        echo "docker_container_running{service=\"$service\"} 0"
        echo "docker_container_healthy{service=\"$service\"} 0"
        echo "docker_container_restart_count{service=\"$service\"} 0"
      fi
    done
  } > "$TMP_FILE"

  mv "$TMP_FILE" "$OUT_FILE"
}

mkdir -p "$OUT_DIR"

while true; do
  write_metrics
  sleep "$INTERVAL"
done
