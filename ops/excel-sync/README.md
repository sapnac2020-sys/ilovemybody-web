# ILoveMyBody Excel → MySQL Sync

This is the deployable connector for the existing ILoveMyBody architecture. It keeps individual Excel workbooks editable in Google Drive while treating the existing MySQL database as canonical.

## Safety model

1. Drive files are downloaded read-only.
2. Every file is hashed and registered as an immutable import batch.
3. Workbook structure and record IDs are validated before any row is staged.
4. Candidate rows enter `ilmb_sync_stage_row`; they never overwrite canonical data.
5. A reviewer explicitly approves or rejects a batch.
6. Promotion runs in one MySQL transaction and writes versioned JSON records plus an audit event.
7. Secrets live only in environment variables or a root-readable environment file. They are never written into Excel, Drive, logs, or Git.

## Quick start

```bash
python -m venv .venv
. .venv/bin/activate
pip install -e .
cp .env.example .env
# Fill the existing MySQL connection and Drive folder/key paths.
ilmb-sync migrate
ilmb-sync scan --dry-run
ilmb-sync scan
ilmb-sync batches
ilmb-sync approve <batch-id> --reviewer <name>
ilmb-sync promote <batch-id> --approver <name>
```

Run continuously with the supplied systemd timer, or use cron. The worker is idempotent: an unchanged Drive file hash is skipped.

## Required one-time Drive action

Share the enterprise parent folder with:

`ilmb-excel-sync@ilovemybody-sync.iam.gserviceaccount.com`

Use Viewer permission for one-way Drive → DB sync. Use Editor only if the service must later write validation reports back to Drive.

## What is deliberately not included

- No second database.
- No Cloud Storage, Cloud Run, or Eventarc dependency.
- No direct workbook-to-production write.
- No passwords or JSON keys in the package.
- No automatic clinical release.

## Operations

- `ilmb-sync doctor` checks configuration, key readability, Drive access, and DB access without importing.
- `ilmb-sync scan --dry-run` validates and reports without DB writes.
- `ilmb-sync reject <batch-id> --reviewer <name> --reason <text>` preserves the rejected batch and reason.
- `ilmb-sync reconcile <batch-id>` verifies promoted row counts and hashes.

See `DEPLOYMENT_CHECKLIST.md` for the final live cutover.
