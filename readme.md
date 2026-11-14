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

Build the image directly with Docker, tagging it with the build date (`YYYYMMDD`)
and `latest`, then push both tags to the registry configured in `.env`:

```bash
REGISTRY=MY-REGISTRY:MY-REGISTRY-PORT
IMAGE="$REGISTRY/thirtysomething/clamav-maldet"
BUILD_DATE="$(date +%Y%m%d)"

docker login "$REGISTRY"
docker build \
  -t "$IMAGE:$BUILD_DATE" \
  -t "$IMAGE:latest" \
  .
docker push "$IMAGE:$BUILD_DATE"
docker push "$IMAGE:latest"
```

Set `REGISTRY` to the same registry host and port in `.env`. Compose runs the
`latest` tag from that registry.

## Run

### Using Docker

```bash
docker run --rm -p 8888:8888 \
  -e SCAN_PATH=/scan \
  -e SCAN_MAX_FILESIZE=500m \
  -e SCAN_INTERVAL=24h \
  -v /path/to/data:/scan \
  -v /path/to/quarantine:/usr/local/maldetect/quarantine \
  MY-REGISTRY:MY-REGISTRY-PORT/thirtysomething/clamav-maldet:latest
```

### Using Docker Compose

Edit the provided `.env` file to set the scan and quarantine directories on the
host, the host port for the Web UI, the registry, and the container environment
settings. Push the image before starting the service:

```bash
docker compose up -d
```

`SCAN_HOST_PATH` and `QUARANTINE_HOST_PATH` are host paths. `HOST_PORT` is the
host port mapped to the Web UI's container port `8888`. Scan directories are
mounted read-write so Maldet can move infected files to quarantine.

To scan multiple host directories, replace the single scan volume entry in
`docker-compose.yml` with one entry per directory, mounting each at a different
subdirectory under `/scan`:

```yaml
volumes:
  - /path/to/data1:/scan/data1
  - /path/to/data2:/scan/data2
  - ${QUARANTINE_HOST_PATH}:/usr/local/maldetect/quarantine
```

Keep `SCAN_PATH=/scan`; Maldet scans the contents of both mounted directories.
Do not mount both host paths to the exact same container path (`/scan`), since
one mount will hide the other.

## Configuration

Environment variables:

- `REGISTRY` – registry host and optional port used to pull the Compose image (for example, `MY-REGISTRY:MY-REGISTRY-PORT`)
- `SCAN_MAX_FILESIZE` – maximum file size using [Compose byte-value syntax][compose-byte-values]: plain bytes or case-insensitive `b`, `k`/`kb`, `m`/`mb`, `g`/`gb` suffixes. Examples: `500b`, `1024kb`, `20m`, `1gb`, `1.5gb`. Units use powers of 1024; fractional bytes are rounded down. The value is converted to bytes before invoking Maldet and passed to ClamAV as `--max-filesize=<VALUE>`. The converted size must be at least 1 byte and below 4 GiB. Compose sets `500m` (500 MiB); unset or empty keeps Maldet's automatic limit. Maldet's file selection limit is adjusted to include files up to this size, and ClamAV's total scan-size limit is set to twice this value.
- `SCAN_PATH` – path to scan inside the container (default: `/scan`)
- `SCAN_TIME` – cron schedule for scans (default: `0 2 * * *` for daily at 2 AM)
- `TZ` – container timezone for scan and update schedules (default: `Europe/Berlin`). Set an IANA timezone such as `Europe/Berlin` or `Etc/UTC` in the Compose environment.
- `UPDATE_TIME` – cron schedule for ClamAV signature updates (default: `0 1 * * *` for daily at 1 AM). Set it in the Compose environment to change the update time; schedules use the container's timezone.

## Web UI

Open the [Web UI][web-ui] in your browser to view quarantined files and restore them.

## Notes

- The WebUI runs at `/opt/webui/app.py` inside the container.
- Maldet is configured to use ClamAV as its scanner.
- The container shares the host's clock; configure NTP on the Docker host, not inside the container. `TZ` controls local time, including daylight-saving changes. Jobs near a daylight-saving transition may be skipped or run twice; use `Etc/UTC` to avoid this ambiguity.
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
