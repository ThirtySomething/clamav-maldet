# clamav-maldet

A lightweight Docker image that combines ClamAV, Linux Malware Detect (Maldet), and a simple WebUI for browsing and restoring quarantined files.

## Overview

This repository builds a container that:

- Installs ClamAV for malware scanning
- Installs Linux Malware Detect (Maldet) to enable quarantine restore
- Provides a minimal Flask WebUI on port `8888`
- Runs a periodic scan using `scan.sh`

## Motivation

ClamAV can detect and quarantine infected files, but it does not restore them to their original location. Maldet extends ClamAV with restore support, and the WebUI makes quarantined files easy to inspect and recover.

## Build

```bash
docker build -t clamav-maldet:latest .
```

## Run

### Using Docker

```bash
docker run --rm -p 8888:8888 \
  -e SCAN_PATH=/scan \
  -e SCAN_INTERVAL=24h \
  -v /path/to/data:/scan:ro \
  -v /path/to/quarantine:/usr/local/maldetect/quarantine \
  clamav-maldet:latest
```

### Using Docker Compose

```bash
docker compose up -d
```

The provided `docker-compose.yml` exposes port `8888` and mounts the scan and quarantine volumes.

## Configuration

Environment variables:

- `SCAN_PATH` – path to scan inside the container (default: `/scan`)
- `SCAN_INTERVAL` – scan interval used by `start.sh` (default: `24h`)

## Web UI

Open `http://localhost:8888` in your browser to view quarantined files and restore them.

## Notes

- The WebUI runs at `/opt/webui/app.py` inside the container.
- Maldet is configured to use ClamAV as its scanner.

## Links

- ClamAV: https://www.clamav.net/
- Linux Malware Detect: https://www.rfxn.com/projects/linux-malware-detect/
- Docker: https://www.docker.com/

## License

This project is licensed under the terms in [LICENSE](LICENSE).
