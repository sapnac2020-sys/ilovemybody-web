# Energy healing: existing LOINC integration

Status: additive SQL prepared; not imported or runtime-tested.

## Repository contracts inspected
- backend/phase_56_test_atlas_loinc_crosswalk.sql: candidate-to-LOINC mappings require approval.
- backend/phase_60_subject_test_result_ledger.sql: original report values, specimen, units, source document and subject/date.
- ops/excel-sync/migrations/008_loinc_parameter_bootstrap.sql: approved LOINC identifiers connect to canonical parameters.

These are repository definitions, not proof that every migration or mapping is present in production.

## Added integration
backend/energy_healing_loinc_links.sql adds private session records, explicit result links and a read view using existing results. It creates no guessed LOINC codes and duplicates no lab observations.
The view requires matching subjects, completed sessions, active results, exact LOINC identity, approved mappings and approved test candidates. It preserves text results as well as numeric results.

## Required application behaviour
Use the authenticated subject context, never trust a client-supplied subject identifier. Reject cross-subject links on writes; the SQL read view also excludes them. Verify protocol belongs to the selected practice. Record timing roles based on actual dates; existing lab dates have day precision, so do not infer exact within-day pre/post order.
Keep these tables and view out of public APIs and exports. This migration supplies storage/read logic, not an access-control implementation.
Before numerical comparison confirm identical test context, compatible units, method and specimen. Preserve original values; use existing verified UCUM conversions only. A LOINC identity does not by itself guarantee two results are comparable.
The existing numeric-only parameter observation view is not used here because qualitative outcomes also matter.

## Staging verification required
Verify existing object/column contracts, apply after department migration, rerun, and check:
- matching subject + exact approved mapping + completed session appears;
- cross-subject, void result, unlinked identity, revoked mapping and cancelled session do not;
- text-only results retain their text;
- original results remain unchanged;
- private endpoints enforce authentication and subject access.
No cases or personal data are seeded. No treatment-effect calculation or causal conclusion is generated.
