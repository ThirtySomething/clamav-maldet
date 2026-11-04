#!/bin/bash
set -euo pipefail

repo=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -f "$tmp/maldet" "$tmp/result" "$tmp/output"; rmdir "$tmp"' EXIT

cat > "$tmp/maldet" <<'EOF'
#!/bin/bash
printf '%s\n' "${SCAN_MAX_FILESIZE-}" "$@" > "$TEST_RESULT"
EOF
chmod +x "$tmp/maldet"
export PATH="$tmp:$PATH" TEST_RESULT="$tmp/result"

check_size() {
    local input="$1" expected="$2"
    SCAN_MAX_FILESIZE="$input" SCAN_PATH='/scan with spaces' \
        bash "$repo/scan.sh" > "$tmp/output"
    [[ "$(cat "$tmp/result")" == "$expected"$'\n-a\n/scan with spaces' ]]
}

check_size 1g 1073741824
check_size 20m 20971520
check_size 500b 500
check_size 1G 1073741824
check_size 20M 20971520
check_size 500B 500
check_size 100m 104857600
check_size 100mb 104857600
check_size 1gb 1073741824
check_size 20mb 20971520
check_size 1k 1024
check_size 1024kb 1048576
check_size 2048k 2097152
check_size 300m 314572800
check_size 2b 2
check_size 1KB 1024
check_size 20Mb 20971520
check_size 1gB 1073741824
check_size 1.5gb 1610612736
check_size 0.1k 102
check_size 500.9b 500
check_size 01 1
check_size 104857600 104857600
check_size 1 1
check_size 3g 3221225472
check_size 4095m 4293918720
check_size 4294967295b 4294967295
check_size 4294967295 4294967295
check_size '' ''
unset SCAN_MAX_FILESIZE
SCAN_PATH='/scan with spaces' bash "$repo/scan.sh" > "$tmp/output"
[[ "$(cat "$tmp/result")" == $'\n-a\n/scan with spaces' ]]

for input in 0 0b 0.1b -1 1tb 1mib 1.2.3gb 1gbb 1e3 4g 4096m 4294967296 \
    4294967296b 999999999999999999999g '20 m' '1; exit'; do
    rm -f "$tmp/result"
    if SCAN_MAX_FILESIZE="$input" bash "$repo/scan.sh" > "$tmp/output" 2>&1; then
        echo "Unexpected acceptance of SCAN_MAX_FILESIZE=$input" >&2
        exit 1
    fi
    [[ ! -e "$tmp/result" ]]
    grep -q 'SCAN_MAX_FILESIZE must be' "$tmp/output"
done

echo 'PASS: size conversion, environment propagation, defaults, boundaries and invalid inputs'
