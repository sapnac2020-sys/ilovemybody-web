# ILMB governed crosswalk contract

## Purpose

This layer connects existing ILMB identities without copying or renaming source facts. It covers chemical–test–food–nutrient–medicine–body, cell, protein, pathway, phenotype, unit and specimen mappings.

## Directional row contract

Every row contains source and target systems, entity types and identifiers; a controlled directional predicate; match type and approval status; evidence source, version and optional locator; optional confidence; and a deterministic mapping identity.

Names and synonyms are search aids only. They are never join keys.

## Computation gate

A mapping is eligible for calculations only when:

1. match_type is EXACT
2. status is APPROVED
3. both endpoint identifiers resolve in their authoritative source release
4. evidence source and version are present
5. the mapping has passed the existing two-person batch approval and promotion control
6. both endpoints exist as active records in `ilmb_crosswalk_endpoint` for the stated authoritative source and release

Broader, narrower, related and candidate mappings remain searchable but cannot silently enter calculations.

## Workbook

Registered filename: ILMB_Crosswalks_*.xlsx

Required sheet: Crosswalks

Required columns: source_system, source_entity_type, source_id, predicate, target_system, target_entity_type, target_id, match_type, status, evidence_source, evidence_version. mapping_id is optional; when omitted, ILMB generates the deterministic SHA-256 identity. When supplied, it must match.

Optional columns: evidence_locator, confidence.

## Operations

1. Drive scan validates and stages the workbook.
2. Reviewer approves the batch.
3. A different approver promotes it.
4. ilmb-sync crosswalk-rebuild validates and materializes promoted mappings.
5. ilmb-sync crosswalk-audit reports totals and computation eligibility.

## Endpoint registry

`ilmb_crosswalk_endpoint` is the calculation boundary. A workbook may preserve draft, candidate or approved mapping claims, but no row becomes computation-eligible until both `(system_id, entity_type, external_id)` endpoints are registered as active against a named source and version. Rebuilding crosswalks recalculates this gate; workbook confidence cannot bypass it.
