#!/usr/bin/env bash
# Point the public redirect page at the tunnel URL that is live right now.
# Safe to run repeatedly: it only commits when the URL actually changed.
set -euo pipefail
LOG=${1:-/tmp/cf.log}
PAGE=$HOME/annotate-link

URL=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' "$LOG" | tail -1)
[ -z "$URL" ] && { echo "no tunnel URL in $LOG yet"; exit 1; }

cd "$PAGE"
CURRENT=$(grep -o 'https://[a-z0-9-]*\.trycloudflare\.com' index.html | head -1 || true)
if [ "$URL" = "$CURRENT" ]; then
  echo "unchanged: $URL"
  exit 0
fi
sed -i "s|https://[a-z0-9-]*\.trycloudflare\.com|$URL|g; s|PLACEHOLDER_URL|$URL|g" index.html
git add index.html
git -c user.name="annotate-bot" -c user.email="voan@localhost" \
    commit -q -m "point at $URL"
git push -q origin main
echo "published: $URL"
