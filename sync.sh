#!/bin/bash
# sync.sh — hourly selective backup of a Muse workspace to GitHub.
# Template version: reads backup.conf (see backup.conf.example).
# 1. rsync configured sources into this repo dir (secret/binary exclusions)
# 2. commit only when something changed (meaningful message)
# 3. push via push.sh; silent when nothing changed; failed push stays local
#    and retries next hour.
set -u
BACKUP_ROOT="$(cd "$(dirname "$0")" && pwd)"
WS=~/workspace
cd "$BACKUP_ROOT" || exit 1

CONF="$BACKUP_ROOT/backup.conf"
[ -f "$CONF" ] || { echo "backup.conf missing — copy backup.conf.example, or run ./setup.sh"; exit 1; }
# shellcheck disable=SC1090
. "$CONF"
: "${REPO_OWNER:?set REPO_OWNER in backup.conf}"
: "${REPO_NAME:?set REPO_NAME in backup.conf}"
: "${BACKUP_MODE:=selective}"

EXCLUDES=(
  --exclude='.git/'
  --exclude='__pycache__/'
  --exclude='node_modules/'
  --exclude='*.zip' --exclude='*.part*'
  --exclude='*.mp4' --exclude='*.mov' --exclude='*.wav' --exclude='*.sample'
  --exclude='.env' --exclude='*.env*'
  --exclude='*secret*' --exclude='*token*' --exclude='*credential*' --exclude='*cookies*'
  --exclude='*bundle*' --exclude='*handoff*'
  --exclude='*.pem' --exclude='*.key' --exclude='id_rsa*'
  --exclude='credentials/'
)

sync_one() { # src_rel dest_rel
  local src="$WS/$1" dest="$BACKUP_ROOT/$2"
  [ -e "$src" ] || return 0
  mkdir -p "$dest"
  rsync -a --delete "${EXCLUDES[@]}" "$src/" "$dest/"
}

if [ "$BACKUP_MODE" = "all" ]; then
  SELF="$(basename "$BACKUP_ROOT")"
  for d in "$WS"/*/; do
    base="$(basename "$d")"
    case "$base" in
      "$SELF"|your_files|user) continue;;
    esac
    sync_one "$base" "$base"
  done
else
  for d in $SELECTIVE_DIRS; do
    [ -n "$d" ] && sync_one "$d" "$d"
  done
fi

[ -f "$BACKUP_ROOT/.gitignore" ] || printf '%s\n' \
  '.git/' '__pycache__/' 'node_modules/' '*.zip' '*.mp4' '.env' 'backup.conf' \
  > "$BACKUP_ROOT/.gitignore"

git add -A
if git diff --cached --quiet; then
  exit 0  # nothing changed → silent
fi

CHANGED=$(git diff --cached --name-only | cut -d/ -f1 | sort -u | tr '\n' ' ')
NFILES=$(git diff --cached --name-only | wc -l)
STAMP=$(TZ=Asia/Jakarta date '+%Y-%m-%d %H:%M')
git -c user.name="Muse Auto-Backup" -c user.email="backup@localhost" \
  commit -q -m "auto-backup: $NFILES files changed in $CHANGED" -m "Hourly backup $STAMP WIB."
echo "committed: $NFILES files"

bash "$BACKUP_ROOT/push.sh"
