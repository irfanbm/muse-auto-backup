# SETUP.md — setup wizard spec

The agent performing setup MUST ask these three questions, in this order.
Do not skip, reorder, or merge them.

## Q1 — Nama repo (wajib)

Ask: "Nama repo backupnya apa? Format: `muse-<email-name>`."

- Example: `muse-irfanbm03`
- The repo is created **private** under the chosen GitHub owner.

## Q2 — Token GitHub (wajib, langsung setelah Q1)

Immediately after the repo name is decided, the agent presents the
**secure token entry dialog** — no other question in between.

- Token type: classic PAT with `repo` scope, or fine-grained PAT with
  contents read/write on the backup repo.
- The token goes to the platform's secure credential store (or the git
  credential helper). It is NEVER written to any file, env var, log, or
  chat message.
- The setup script (`setup.sh`) pauses here and continues after the user
  confirms the token was entered.

## Q3 — Semua cron: ya / tidak (wajib)

Ask: "Backup semua cron (seluruh folder workspace)? ya / tidak"

- **ya** → `BACKUP_MODE=all`: every top-level `~/workspace/` folder is
  synced (minus exclusions and the backup root itself).
- **tidak** → `BACKUP_MODE=selective`: ask which project folders to
  include, write them space-separated into `SELECTIVE_DIRS` in
  `backup.conf`.

## After the three questions

1. Create the private repo `<owner>/<repo-name>` on GitHub.
2. `cp backup.conf.example backup.conf`, fill `REPO_OWNER`, `REPO_NAME`,
   `BACKUP_MODE`, `SELECTIVE_DIRS`.
3. `git init` here (if needed), first commit, push to the new repo.
4. Register the hourly cron: `sync.sh` → push; silent unless it errors.
5. Run `sync.sh` once manually to verify the first push lands.
