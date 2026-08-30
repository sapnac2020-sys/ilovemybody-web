# ILMB Existing Data Exact Reconciliation Register

Live read-only audit generated: 2026-08-30 07:03:21 UTC.

## Exact module inventory

| Module | Base tables | Views | Exact rows | Non-empty tables | Empty tables | Readiness |
|---|---:|---:|---:|---:|---:|---|
| ChEBI canonical | 0 | 0 | 0 | 0 | 0 | Source downloaded; canonical loader missing |
| LOINC | 0 | 0 | 0 | 0 | 0 | Source/import required |
| Human body | 84 | 26 | 61,916 | 75 | 9 | Reconcile existing structures |
| Nutrition | 34 | 8 | 20,030 | 15 | 19 | Reconcile and complete identities |
| Medicines | 17 | 4 | 573 | 12 | 5 | Partial catalogue |
| Units and ranges | 8 | 1 | 201 | 7 | 1 | Conversion and interval coverage incomplete |
| Formula system | 32 | 6 | 3,381 | 29 | 3 | Governed framework exists |
| Patient/measurement | 42 | 33 | 1,378 | 32 | 10 | Test records exist |
| Ingestion controls | 8 | 0 | 134 | 3 | 5 | Only legacy importer has activity |

## Canonical control state

All of these contain exactly zero rows:

- `ilmb_sync_batch`
- `ilmb_sync_file`
- `ilmb_sync_stage_row`
- `ilmb_sync_validation_error`
- `ilmb_sync_audit`
- `ilmb_canonical_record`
- `ilmb_canonical_record_history`
- `ilb_source_release`

The 134 ingestion rows are the earlier PHP Test Atlas import: one batch, 123 rows, and 10 audit records. They do not prove the newer Drive pipeline.

## Provenance coverage

Among 289 relevant existing tables/views:

- 269 have no recognised source identifier column.
- 288 have no recognised release/version column.
- 288 have no recognised checksum column.

These are structural coverage findings. A table may contain source text under a nonstandard field, so field-level mapping must precede any destructive decision.

## Canonicalisation order

1. Assign every relevant base table a role: source, canonical candidate, staging, crosswalk, history, legacy, or empty shell.
2. Map its primary identifier and external identifiers.
3. Map source, release, checksum, review state, and effective dates.
4. Detect table overlap by identifier and semantic field coverage.
5. Detect duplicate identities within and across tables.
6. Test relationship endpoints and unit compatibility.
7. Freeze canonical selections without deleting source records.
8. Load missing official datasets only after a matching canonical contract exists.
9. Recompute one patient result and compare database and Excel outputs.

## Missing-data boundary for the separate chat

The separate data-building chat may prepare:

- LOINC 2.83 source release and manifest.
- UCUM release/version metadata and complete conversion definitions.
- Human-body hierarchy below organ level only where the existing 84 tables lack coverage.
- IFCT/USDA source-release manifests and stable food/nutrient identifiers.
- Medicine identifiers and release metadata only for records absent from existing medicine tables.

It must not create replacement database tables, duplicate existing records, invent formulas, or promote data directly.
