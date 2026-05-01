#!/bin/bash

echo "[START] Setting up cron schedule: $SCAN_TIME"
echo "$SCAN_TIME /usr/local/bin/scan.sh" > /etc/crontabs/root

echo "[START] Starting cron daemon..."
crond

echo "[START] Starting WebUI..."
python3 /opt/webui/app.py &

echo "[START] Container running. Scans scheduled via cron."
wait
