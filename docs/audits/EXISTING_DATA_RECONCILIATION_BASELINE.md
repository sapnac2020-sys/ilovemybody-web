# ILMB Existing Data Reconciliation Baseline

Generated from the read-only live audit at 2026-08-30T06:53:47+00:00.

## Governing decision

Existing ILMB data is reconciled before any missing external dataset is added. No table is deleted, overwritten, or declared canonical solely from its name. The separate data-building chat supplies only items listed in the missing-data handoff after reconciliation.

## Live database baseline

- Database: `u756742628_ilovemybody`
- Base tables: 1004
- Views: 303
- Foreign-key columns: 521
- Base tables without primary keys: 0
- Empty base-table shells: 206
- Required application objects present: 102/102
- Open governance issues: 3

## Module inventory

| Module | Base tables | Views | Non-empty | Empty | Estimated rows |
|---|---:|---:|---:|---:|---:|
| ChEBI | 0 | 0 | 0 | 0 | 0 |
| LOINC | 0 | 0 | 0 | 0 | 0 |
| Human body | 84 | 26 | 75 | 9 | 60,716 |
| Nutrition | 34 | 8 | 15 | 19 | 20,026 |
| Medicines | 17 | 4 | 12 | 5 | 573 |
| Units & ranges | 8 | 1 | 7 | 1 | 201 |
| Formula system | 32 | 6 | 29 | 3 | 3,381 |
| Patient records | 42 | 33 | 32 | 10 | 1,378 |
| Excel sync | 8 | 0 | 3 | 5 | 134 |

Information-schema row estimates are inventory signals, not reconciliation totals. Exact counts and identity checks are required before promotion.

## Confirmed findings

1. No ChEBI-named or LOINC-named canonical table exists.
2. `ilmb_canonical_record` and `ilmb_canonical_record_history` contain zero rows.
3. The Drive pipeline has zero files, batches, stage rows, validation errors, audit rows, and canonical rows.
4. The older PHP import completed one batch with 123 rows in `ilb_test_atlas_candidate`.
5. Human-body data is extensive but spread across legacy, internal, reference, intersection, and canonical-looking tables.
6. Nutrition contains 19,458 food-nutrient observations but only two food-item rows and 24 nutrient-catalogue rows.
7. Medicines contain 384 pharmaceutical rows plus several smaller drug and interaction tables.
8. The unit layer has 60 units, 11 aliases, 36 marker-unit mappings, and only one conversion requirement.
9. `ilb_source_release` is empty, so official release-level provenance is not yet operational.
10. Patient computation outputs remain empty even though subjects, measurements, formulas, and formula runs exist.

## Reconciliation rules

- Preserve every source table until its records are mapped and checksummed.
- Assign each table one role: canonical, candidate, staging, crosswalk, history, view, legacy, or empty shell.
- Select canonical records by stable identifier, provenance, release, review status, and relationship coverage—not row volume.
- Resolve synonyms and duplicates through versioned crosswalks.
- Never merge clinical, traditional, and hypothesis evidence levels.
- Do not promote new rows until counts, keys, units, and relationship endpoints reconcile.
- Patient outputs must expose inputs, formula version, units, assumptions, provenance, and calculation timestamp.

## Work order

1. Exact-count and classify existing source/canonical/staging tables.
2. Map overlapping tables and keys.
3. Populate release provenance for existing datasets.
4. Resolve duplicate identifiers and unit aliases.
5. Validate foreign-key and semantic orphans.
6. Freeze canonical mappings.
7. Run one existing patient calculation and independently reproduce it.
8. Issue the final missing-data handoff to the separate data-building chat.
