#!/bin/bash
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -f "$tmp/start.sh" "$tmp/crontab" "$tmp/crond" "$tmp/python3" "$tmp/output"; rmdir "$tmp"' EXIT

sed "s|/etc/crontabs/root|$tmp/crontab|g" "$repo/start.sh" > "$tmp/start.sh"
for command in crond python3; do
    printf '#!/bin/bash\nexit 0\n' > "$tmp/$command"
    chmod +x "$tmp/$command"
done
export PATH="$tmp:$PATH"
unset SCAN_TIME UPDATE_TIME

bash "$tmp/start.sh" > "$tmp/output"
grep -Fxq '0 2 * * * /usr/local/bin/scan.sh' "$tmp/crontab"

SCAN_TIME='' bash "$tmp/start.sh" > "$tmp/output"
grep -Fxq '0 2 * * * /usr/local/bin/scan.sh' "$tmp/crontab"

for run in 1 2; do
    SCAN_TIME='0 2 * * *' bash "$tmp/start.sh" > "$tmp/output"
    [[ "$(wc -l < "$tmp/crontab")" -eq 2 ]]
    grep -Fxq '0 2 * * * /usr/local/bin/scan.sh' "$tmp/crontab"
    grep -Fxq '0 1 * * * /usr/bin/freshclam > /proc/1/fd/1 2> /proc/1/fd/2' "$tmp/crontab"
done

SCAN_TIME='30 4 * * 1' bash "$tmp/start.sh" > "$tmp/output"
[[ "$(wc -l < "$tmp/crontab")" -eq 2 ]]
grep -Fxq '30 4 * * 1 /usr/local/bin/scan.sh' "$tmp/crontab"
grep -Fxq '0 1 * * * /usr/bin/freshclam > /proc/1/fd/1 2> /proc/1/fd/2' "$tmp/crontab"

SCAN_TIME='0 2 * * *' UPDATE_TIME='15 3 * * *' bash "$tmp/start.sh" > "$tmp/output"
[[ "$(wc -l < "$tmp/crontab")" -eq 2 ]]
grep -Fxq '0 2 * * * /usr/local/bin/scan.sh' "$tmp/crontab"
grep -Fxq '15 3 * * * /usr/bin/freshclam > /proc/1/fd/1 2> /proc/1/fd/2' "$tmp/crontab"

SCAN_TIME='0 2 * * *' UPDATE_TIME='' bash "$tmp/start.sh" > "$tmp/output"
grep -Fxq '0 1 * * * /usr/bin/freshclam > /proc/1/fd/1 2> /proc/1/fd/2' "$tmp/crontab"

echo 'PASS: default/custom update schedules, scan schedule preservation and restart idempotency'
