#!/bin/bash
if [ -n "$SCAN_MAX_FILESIZE" ]; then
    if [[ ! "$SCAN_MAX_FILESIZE" =~ ^([0-9]+([.][0-9]+)?)([kKmMgG]?[bB]?)$ ]]; then
        echo "[SCAN] SCAN_MAX_FILESIZE must be a Compose-style byte value (e.g. 500b, 1024kb, 20m, 1.5gb)" >&2
        exit 1
    fi

    size="${BASH_REMATCH[1]}"
    unit="${BASH_REMATCH[3],,}"
    unit="${unit%b}"
    if ! size=$(LC_ALL=C numfmt --from=iec --round=down --format='%.0f' "$size${unit^^}"); then
        echo "[SCAN] SCAN_MAX_FILESIZE must be convertible to bytes" >&2
        exit 1
    fi

    if [ "${#size}" -gt 10 ] || [ "$size" -lt 1 ] || [ "$size" -gt 4294967295 ]; then
        echo "[SCAN] SCAN_MAX_FILESIZE must be at least 1 byte and below 4 GiB" >&2
        exit 1
    fi

    export SCAN_MAX_FILESIZE="$size"
fi

echo "[SCAN] Starting scan of $SCAN_PATH"
maldet -a "$SCAN_PATH"
echo "[SCAN] Scan finished"
