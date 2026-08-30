# ChEBI canonical ingestion contract

## Purpose

ChEBI is ILMB's controlled chemical identity and relationship layer. It does not by itself establish diagnosis, treatment efficacy, dose response, or patient causality.

## Authoritative sources

- Monthly bulk releases: `https://ftp.ebi.ac.uk/pub/databases/chebi/`
- Public API: `https://www.ebi.ac.uk/chebi/backend/api/`
- Bulk release files are the reproducible source of truth.
- API responses are lookup/candidate evidence and are cached with retrieval time and SHA-256.

## Storage layers

1. Immutable release directory: `$ILMB_WORK_DIR/chebi/releases/<release-label>/`
2. `manifest.json`: URL, filename, bytes, SHA-256, remote timestamp, row count and validation result.
3. Regenerated Excel partitions: registered as `REF-CHEBI` and processed through normal stage, review, promotion and reconciliation.
4. Canonical database records: promoted only after two-person approval.
5. ILMB crosswalks: separate from raw ChEBI facts.

## Identity rules

- Canonical chemical join key: `CHEBI_ID`.
- Names and synonyms are search fields, never automatic computation keys.
- Secondary IDs must resolve to a canonical ChEBI ID.
- Relationship subject and object identifiers must both resolve.
- A source release is promoted as a unit; mixed-release computation is prohibited.

## Required bulk sources

- FULL OBO ontology
- compounds
- names/synonyms
- relations and relation types
- chemical data
- structures and structure registry
- database accessions
- secondary IDs
- compound origins
- curator comments
- WURCS
- source and status lookups

SDF is optional because the flat `structures.tsv.gz` source contains the structure layer used for governed Excel regeneration. It can be fetched for independent structure reconciliation.

## Commands

```bash
ilmb-sync chebi-fetch --release 2026-08-14
ilmb-sync chebi-fetch --release 2026-08-14 --include-sdf
ilmb-sync chebi-validate "$ILMB_WORK_DIR/chebi/releases/2026-08-14/manifest.json"
ilmb-sync chebi-api /public/<documented-endpoint>/ --param key=value
```

The API command accepts a documented relative path rather than hard-coding one endpoint, so API changes remain isolated from the bulk ingestion contract.

## Promotion gates

All are blocking:

1. Every required source exists.
2. Byte size and SHA-256 match the manifest.
3. Every gzip stream is readable.
4. Every TSV has unique headers and exceeds its conservative truncation threshold.
5. The ontology is readable and contains the expected order of magnitude of terms.
6. Regenerated Excel part ranges are continuous.
7. Excel totals reconcile to the release manifest.
8. Canonical ChEBI IDs are unique.
9. Relationship endpoints resolve.
10. Only `EXACT + APPROVED` ILMB mappings may enter calculations.

## Recovery guarantee

Excel files are outputs, not the source of truth. If they are lost, the recorded official release plus this connector must regenerate them deterministically.
