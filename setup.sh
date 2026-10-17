#!/bin/bash
# setup.sh — interactive setup for muse-auto-backup.
# Asks the mandatory questions in order:
#   Q1: repo name (muse-<email-name>)
#   Q2: GitHub token → the AGENT shows the secure entry dialog here
#       (this script never sees or stores the token)
#   Q3: semua cron? ya/tidak
set -u
cd "$(dirname "$0")" || exit 1

echo "=== muse-auto-backup setup ==="
echo
echo "[1/3] Nama repo backup (format: muse-<email-name>, contoh: muse-irfanbm03):"
read -r REPO_NAME
[ -n "$REPO_NAME" ] || { echo "nama repo wajib diisi"; exit 1; }

echo
echo "[2/3] Token GitHub:"
echo "  Agen akan menampilkan dialog secure entry sekarang."
echo "  Masukkan classic PAT (scope: repo) atau fine-grained PAT di sana."
echo "  Token TIDAK ditulis ke file mana pun — hanya ke secure store / git credential."
echo "  Tekan Enter di sini setelah selesai memasukkan token di dialog."
read -r _

echo
echo "[3/3] Backup semua cron (seluruh folder workspace)? (ya/tidak)"
read -r ALL
case "$ALL" in
  y|ya|Y|YA|yes|YES) MODE=all; DIRS="";;
  *) MODE=selective
     echo "  Daftar folder workspace yang di-backup (pisahkan spasi, relatif ke ~/workspace)."
     echo "  Contoh: goals memory x-grafisify crypto-spot-trader"
     read -r DIRS
     [ -n "$DIRS" ] || { echo "daftar folder wajib diisi untuk mode selective"; exit 1; };;
esac

cp backup.conf.example backup.conf
# fill via python for safe quoting
REPO_NAME="$REPO_NAME" MODE="$MODE" DIRS="$DIRS" python3 - <<'EOF'
import os, re
p = 'backup.conf'
s = open(p).read()
s = re.sub(r'^REPO_NAME=.*$', 'REPO_NAME=' + os.environ['REPO_NAME'], s, flags=re.M)
s = re.sub(r'^BACKUP_MODE=.*$', 'BACKUP_MODE=' + os.environ['MODE'], s, flags=re.M)
if os.environ['MODE'] == 'selective':
    s = re.sub(r'^SELECTIVE_DIRS=.*$', 'SELECTIVE_DIRS="' + os.environ['DIRS'] + '"', s, flags=re.M)
open(p, 'w').write(s)
EOF

echo
echo "backup.conf written:"
cat backup.conf
echo
echo "Next (handled by the agent per SETUP.md): create the private repo,"
echo "first commit + push, register the hourly cron, verify with one manual run."
