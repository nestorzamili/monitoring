# Lightweight VM Monitoring with Telegram Alerts

This stack is designed for lightweight monitoring on a single Ubuntu VM with 2 vCPU and 2 GB RAM, without any public UI. Components:

- `node_exporter` for host metrics
- `docker-health-metrics` to read container status and Docker health checks
- `Prometheus` for scraping and alert rule evaluation
- `Alertmanager` to send alerts to Telegram
- Conservative resource limits to keep the stack lightweight on a 2C2G VM

## Structure

```text
monitoring/
  .env.example
  compose.yml
  README.md
  docker-health/
    entrypoint.sh
  prometheus/
    entrypoint.sh
    prometheus.yml.tpl
    rules/
      host-alerts.yml
  alertmanager/
    alertmanager.yml.tpl
    entrypoint.sh
```

## Requirements

- Docker and the Docker Compose plugin installed on the VM
- Target application containers with stable container names and Docker health checks enabled

## Setup

1. Copy the env file:

```bash
cd monitoring
cp .env.example .env
```

2. Edit `.env`:

- `ALERT_INSTANCE`: VM name shown in alerts
- `TELEGRAM_BOT_TOKEN`: Telegram bot token
- `TELEGRAM_CHAT_ID`: destination group, channel, or direct message chat ID
- `DOCKER_TARGETS`: space-separated list of container names to monitor

3. Validate the config:

```bash
docker compose --env-file .env config
```

4. Start the stack:

```bash
docker compose --env-file .env up -d
```

5. Check status:

```bash
docker compose --env-file .env ps
docker compose --env-file .env logs -f prometheus
docker compose --env-file .env logs -f alertmanager
```

## Monitored Targets

Host:

- CPU usage
- memory available
- load average
- disk free
- disk fill prediction
- inode free
- filesystem read-only
- swap usage
- host reboot
- exporter down

Docker containers:

- container exists or is missing
- container is running or stopped
- Docker health check is healthy or unhealthy
- container restart count

## Alert Test

Recommended Telegram alert test:

1. Start the monitoring stack
2. Stop one application service, for example `naoto-web`
3. Wait about 2 minutes for the container alert to fire
4. Start the service again
5. Confirm that the resolved notification is sent

For faster testing, temporarily lower thresholds in `prometheus/rules/host-alerts.yml`, then reload Prometheus:

```bash
docker compose --env-file .env kill -s HUP prometheus
```

## Operations

Reload Prometheus after changing rules:

```bash
docker compose --env-file .env kill -s HUP prometheus
```

Restart the stack:

```bash
docker compose --env-file .env restart
```

Stop the stack:

```bash
docker compose --env-file .env down
```

## Notes

- This stack cannot alert when the VM is fully down because every component runs on the same host
- Add an external heartbeat or uptime monitor if you need host-down detection
- There is no public dashboard or UI; debugging is done through monitoring container logs
- Prometheus retention time and retention size are capped to keep disk usage under control
