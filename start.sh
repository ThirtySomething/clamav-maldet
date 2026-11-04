#!/bin/bash

SCAN_TIME="${SCAN_TIME:-0 2 * * *}"
echo "[START] Setting up cron schedule: $SCAN_TIME"
echo "$SCAN_TIME /usr/local/bin/scan.sh" > /etc/crontabs/root

UPDATE_TIME="${UPDATE_TIME:-0 1 * * *}"
echo "[START] Setting up ClamAV database update schedule: $UPDATE_TIME"
echo "$UPDATE_TIME /usr/bin/freshclam > /proc/1/fd/1 2> /proc/1/fd/2" >> /etc/crontabs/root

echo "[START] Starting cron daemon..."
crond

echo "[START] Starting WebUI..."
python3 /opt/webui/app.py &

echo "[START] Container running. Scans scheduled via cron."
wait
