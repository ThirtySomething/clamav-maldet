# clamav-maldet

A lightweight Docker image that combines ClamAV, Linux Malware Detect (Maldet), and a simple WebUI for browsing and restoring quarantined files.

## Overview

This repository builds a container that:

- Installs ClamAV for malware scanning
- Updates the ClamAV signature database daily using `freshclam`
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
  -e SCAN_MAX_FILESIZE=500m \
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
- `SCAN_TIME` – cron schedule for scans (default: `0 2 * * *` for daily at 2 AM)
- `UPDATE_TIME` – cron schedule for ClamAV signature updates (default: `0 1 * * *` for daily at 1 AM). Set it in the Compose environment to change the update time; schedules use the container's timezone.
- `SCAN_MAX_FILESIZE` – maximum file size using [Compose byte-value syntax][compose-byte-values]: plain bytes or case-insensitive `b`, `k`/`kb`, `m`/`mb`, `g`/`gb` suffixes. Examples: `500b`, `1024kb`, `20m`, `1gb`, `1.5gb`. Units use powers of 1024; fractional bytes are rounded down. The value is converted to bytes before invoking Maldet and passed to ClamAV as `--max-filesize=<VALUE>`. The converted size must be at least 1 byte and below 4 GiB. Compose sets `500m` (500 MiB); unset or empty keeps Maldet's automatic limit. Maldet's file selection limit is adjusted to include files up to this size, and ClamAV's total scan-size limit is set to twice this value.

## Web UI

Open the [Web UI][web-ui] in your browser to view quarantined files and restore them.

## Notes

- The WebUI runs at `/opt/webui/app.py` inside the container.
- Maldet is configured to use ClamAV as its scanner.
- ClamAV signatures are downloaded during the image build and updated by cron according to `UPDATE_TIME` (daily at 01:00 by default). Update output and errors are available in the container logs (`docker compose logs`).

## Links

- [ClamAV][clamav]
- [Linux Malware Detect][maldet]
- [Docker][docker]

## License

This project is licensed under the terms in [LICENSE][license].

[clamav]: https://www.clamav.net/
[compose-byte-values]: https://docs.docker.com/reference/compose-file/extension/#specifying-byte-values
[docker]: https://www.docker.com/
[license]: LICENSE
[maldet]: https://www.rfxn.com/projects/linux-malware-detect/
[web-ui]: http://localhost:8888
