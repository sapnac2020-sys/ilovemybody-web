# Live deployment checklist

Nothing may be marked complete without evidence from the named command.

| Gate | Action | Passing evidence |
|---|---|---|
| 1 | Share the Drive parent folder with the service account as Viewer | `ilmb-sync doctor` reports Drive access and visible file count |
| 2 | Put the downloaded JSON key at `/etc/ilmb-sync/google-service-account.json` | owner `root`, group `ilmb-sync`, mode `0640` or stricter |
| 3 | Enter the existing MySQL credentials in `/etc/ilmb-sync/ilmb-sync.env` | `ilmb-sync doctor` reports database access |
| 4 | Apply `migrations/001_sync_control.sql` to the existing DB | six `ilmb_sync_*` / canonical control tables exist |
| 5 | Run `ilmb-sync scan --dry-run` | every registered workbook is VALID or has an explicit rejection report |
| 6 | Run the first staging scan | every changed workbook has a batch ID; production records unchanged |
| 7 | Review and approve one non-clinical batch | status becomes APPROVED with reviewer recorded |
| 8 | Promote using a different approver | transaction commits; row count reconciles; status PROMOTED |
| 9 | Enable the timer | `systemctl list-timers ilmb-sync.timer` shows next run |
| 10 | Run rollback/restore drill | prior workbook version and DB backup can be restored in isolation |

## Password and secret rules

- Never store passwords, database DSNs, the service-account JSON key, OAuth tokens, or recovery codes in Excel.
- Never upload the key to Drive or commit it to Git.
- Rotate the downloaded service-account key if it has ever been pasted into chat, email, Drive, or source control.
- MySQL account should have only the schema/table permissions required by this connector; do not use root.
- Drive access should be folder-scoped through sharing and API scope should remain read-only.
- Production promotion requires two different human identities.
- Logs contain file names, batch IDs, hashes and counts; never cell values from personal observation sheets.

## Honest current state

The software package can be built and tested without secrets. Live deployment is complete only after gates 1–9 pass against the real Drive folder, existing MySQL database and server.
