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

## Literature progress, 30 September 2026

Executed and recorded one PubMed-indexed web discovery query for each of the 50 catalogue identities. Fifteen queries returned no indexed results; that is not proof of absent evidence. This is a bounded discovery pass, not an exhaustive systematic search.

The new migration preserves 290 practice–PMID candidate records: 12 abstract appraisals, one existing appraisal, 204 awaiting screening, two notices to reconcile, 46 excluded name collisions, one wrong-design exclusion and 24 unconfirmed lineage identities. These are candidate mappings, not 290 eligible studies. Alias expansion, registry searches, citation chasing, independent screening and non-English databases remain open.

Twelve focused primary-study appraisals bring the structured evidence-review total to 13. They cover Reiki, Therapeutic Touch, Pranic Healing, Quantum Touch, Jin Shin Jyutsu, Johrei, Polarity Therapy, ThetaHealing, healing dowsing, Biofield Tuning, Bengston and Healing Touch. Each records the tested population/outcome, comparator, findings, uncertainty, limitations and available procedure information. All twelve are ABSTRACT reviews; none is presented as a full-text appraisal. The Bengston record is ANIMAL research. The Jin Shin Jyutsu correction notice (PMID 36398997) is flagged for reconciliation; all other new notice audits remain pending.

Findings include condition-specific null results (Reiki fibromyalgia), negative operational tests (Therapeutic Touch hand detection, dowsing identification, ThetaHealing theta increase), preliminary adjunctive clinical findings and uncontrolled participant experiences. Immune markers are not cancer survival outcomes. Within-arm improvement is not a between-arm treatment effect. Shared teaching components do not establish a shared physical mechanism.

Verification uses twice-run SQL migrations, exact record counts, animal/abstract/notice classification checks, integrity auditing and HTTP evidence-page checks. Deployment additionally checks the live evidence page and private sign-in redirect. These verify data and software behavior; scientific validation still requires full-text bias appraisal, reconciled corrections, complete reproducible procedures and appropriate independent controlled studies. No department experiment or research protocol is marked complete by this change.

## Follow-up research pass, 30 September 2026

See [research scope and evidence register](energy-healing-research-scope.md). All 50 direct PubMed queries now completed. All 290 earlier mappings have a recorded title/metadata decision; this is not completed full-text screening. Evidence reviews increased to 25, with seven scoped full-text reviews and two reconciled correction records. Expanded search identifiers and retained papers still require review, so every catalogue research-completion gate remains open. Software checks do not close scientific gates.
