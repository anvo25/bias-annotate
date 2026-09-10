#!/usr/bin/env bash
# Start the tunnel, wait for its URL, publish it to the redirect page, then
# stay attached so systemd can supervise the tunnel process itself.
set -uo pipefail
LOG=$HOME/annotate-link/cf.log
: > "$LOG"

"$HOME/cloudflared" tunnel --url http://localhost:1325 --edge-ip-version 4 \
    >> "$LOG" 2>&1 &
CF=$!

for _ in $(seq 1 40); do
    grep -q 'trycloudflare\.com' "$LOG" && break
    sleep 2
done
"$HOME/annotate-link/update.sh" "$LOG" || echo "could not publish link (check git remote)"

wait $CF
