# Energy healing completion register — 30 September 2026

Scope: the current catalogue, not every healing tradition worldwide. Baseline: a1e0d1466a21d01c4a0d3dc2ef91b1cb24557026 (#138). The catalogue mixes modalities, branches, families and a delivery style; these must not be counted as 50 independent treatments.

## Current verified implementation
- Fifty sourced catalogue identities and fifty process assessments are seeded.
- Two detailed entries contain sixteen published sections in total.
- Convergence contains nine candidate themes and 34 teaching observations.
- Two weight-management maps contain eight connections; sequences remain partial or missing.
- One structured evidence review and three draft Magnified protocols are seeded.
- The previous deployed baseline bebffef passed production migration and public/private smoke checks in run 36728282791. This does not confirm deployment of later commits.

## Automated audit
Run `php ops/audit-energy-healing.php /absolute/site/root` on the installed site. This read-only command uses the installed configuration, emits public research metadata and aggregate integrity counts, and never exports patient results or identifiers. Exit 0 means listed integrity checks passed; 2 means integrity defects; 1 means configuration/schema unavailable. Open research gaps do not become integrity failures or scientific approvals.

The audit reports record kinds and per-record counts for published sections, structured evidence reviews, process reviews, completed department protocols with results and convergence observations. It flags missing branch parents, source records/locators and cross-person session links. It intentionally does not infer completeness from record counts or efficacy from a completed protocol. Deployment saves its output in the existing private backup directory. CI tests both the baseline and an intentionally broken branch relationship.

## Remaining gates
| Gate | Work needed | Closure evidence |
| --- | --- | --- |
| Scope | Define inclusion/exclusion rules, alias and lineage resolution, and search languages/regions | Dated scope and screening register; coverage bounded to that scope |
| Detailed entries | Complete remaining catalogue records | Claim-specific sections with source passages and limitations |
| Sources | Verify exact passages, editions and stable provenance | Locator, version/date, accessible record, correction/retraction audit |
| Literature | Complete reproducible searches, deduplication and screening | Query logs, exclusions, included-study extraction and risk of bias |
| Processes | Extract outcome-specific action order, duration, dose and prerequisites | Traceable sequence; unavailable material stays SOURCE_GAP |
| Convergence | Review matches and contradictions across independent sources | Component comparisons; unknown remains unknown |
| Outcomes | Evaluate each population/outcome independently | Effect estimates, uncertainty, suitable comparators and replication |
| Mechanisms | Define quantitative predictions and test them | Calibrated raw measurements, masking, controls and independent replication |
| Research capture | Add consent, allocation concealment, audit history and locked endpoints | Validated study capture and export before enrolment |
| Operations | Confirm latest deployment, backup restoration, permissions and responsive journeys | Commit-linked run, restoration evidence and live checks |

No department experiment is complete. Scientific validation cannot be created by a migration, source count or website test.
