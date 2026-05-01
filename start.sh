#!/bin/bash

echo "[START] Starting WebUI..."
python3 /opt/webui/app.py &

echo "[START] Starting scan loop (interval: $SCAN_INTERVAL)..."
while true; do
    /usr/local/bin/scan.sh
    sleep "$SCAN_INTERVAL"
done
