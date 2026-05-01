#!/bin/bash
echo "[SCAN] Starting scan of $SCAN_PATH"
maldet -a "$SCAN_PATH"
echo "[SCAN] Scan finished"
