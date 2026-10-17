#!/bin/bash
# push.sh — push the backup repo to GitHub.
# Auth comes from the git credential helper (set up during SETUP.md Q2),
# never from a file. Soft-fail: a failed push stays local and the next
# hourly run retries it.
set -u
cd "$(dirname "$0")" || exit 1
export https_proxy=http://hatch-egress-proxy:3128 http_proxy=http://hatch-egress-proxy:3128 \
       HTTPS_PROXY=http://hatch-egress-proxy:3128 HTTP_PROXY=http://hatch-egress-proxy:3128
if git push -q origin main 2>/tmp/muse_backup_push.err; then
  echo "pushed ok"
else
  echo "push failed (will retry next hour):"
  head -3 /tmp/muse_backup_push.err
  exit 1
fi
