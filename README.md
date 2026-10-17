# muse-auto-backup

Hourly auto-backup of a Muse workspace to a private GitHub repo.
Selective: only irreplaceable local state, secrets never leave the machine.

Inspired by [Kutuyyy/muse-auto-backup](https://github.com/Kutuyyy/muse-auto-backup)
(MIT). This is a customized copy: repo naming follows `muse-<email-name>`,
setup asks three mandatory questions, and the sync script is parameterized
via `backup.conf` instead of hardcoded paths.

## How it works

1. `sync.sh` (run hourly via cron) rsyncs the configured workspace folders
   into this repo, with secret/binary exclusions.
2. Commits only when something changed, with a meaningful message
   (`auto-backup: N files changed in <folders>`).
3. Pushes to GitHub. Silent when nothing changed; a failed push stays
   local and retries next hour.

## Exclusions (every sync)

`*.zip`, `*.part*`, `*.mp4/.mov/.wav/.sample`, `.env`, `*.env*`,
`*secret*`, `*token*`, `*credential*`, `*cookies*`, `*bundle*`, `*handoff*`,
`*.pem`, `*.key`, `id_rsa*`, `credentials/`, `.git/`, `__pycache__/`,
`node_modules/`.

Deliberately **not** backed up by default: projects that already live in
their own GitHub repos, video renders, migration/handoff zips.

## Setup

Read [SETUP.md](SETUP.md) and run `./setup.sh`. The setup asks three
mandatory questions, in order:

1. **Nama repo** — format `muse-<email-name>` (contoh: `muse-irfanbm03`)
2. **Token GitHub** — agen langsung menampilkan dialog secure entry
   (classic PAT scope `repo`, atau fine-grained). Token masuk secure
   store, tidak pernah ditulis ke file.
3. **Semua cron: ya/tidak** — `ya` = backup seluruh folder workspace,
   `tidak` = pilih daftar folder secara selektif.

## Files

| File | Purpose |
|---|---|
| `SETUP.md` | setup wizard spec (the 3 mandatory questions) |
| `setup.sh` | interactive setup: asks Q1 + Q3, writes `backup.conf` |
| `backup.conf.example` | config template (`REPO_OWNER`, `REPO_NAME`, `BACKUP_MODE`, `SELECTIVE_DIRS`) |
| `sync.sh` | hourly sync: rsync → commit on change → push |
| `push.sh` | push helper: `git push`, soft-fail so the next hour retries |

## License

MIT — following upstream [Kutuyyy/muse-auto-backup](https://github.com/Kutuyyy/muse-auto-backup).
