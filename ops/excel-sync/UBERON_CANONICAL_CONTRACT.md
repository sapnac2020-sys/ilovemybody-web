# UBERON canonical synchronization contract

Status: connector registered; production import requires validation, staging, approval, and reconciliation.

## Authoritative identity

- Canonical anatomy identity is `term_id` (for example, `UBERON:0002107`).
- A preferred name is display text, never a key.
- Synonyms never create new anatomy entities.
- Alternative IDs and external xrefs are crosswalks, never silent replacements.
- Obsolete terms remain traceable and must point to their declared replacement/consider targets.
- Relationship predicates and target expressions are preserved verbatim from the source before any normalized relationship is derived.
- Original source rows are immutable; corrections arrive as a new release or governed supersession.

## Registered source partitions

| Partition | Workbook pattern | Included sheets | Expected rows |
|---|---|---|---:|
| TERMS | ILMB_UBERON_01_Terms_Release_*.xlsx | Terms; Obsolete_Actions | 27,352 |
| SYNONYMS | ILMB_UBERON_02_Synonyms_Release_*.xlsx | Synonyms | 63,996 |
| MAPPINGS | ILMB_UBERON_03_Mappings_Release_*.xlsx | Xrefs; Alternative_IDs; Subsets | 93,443 |
| RELATIONS | ILMB_UBERON_04_Relations_Release_*.xlsx | Relations_Original | 111,872 |
| PROPERTIES | ILMB_UBERON_05_Properties_Release_*.xlsx | Ontology_Header; Term_Properties; Term_Audit; Typedef_Tags | 22,120 |
| **Total** | | | **318,783** |

The total above is the exact sum of importable source sheets. README, dictionaries, and QC sheets are controls and are not data rows.

## Universal-language mapping

| Source sheet | Universal layer | Canonical meaning |
|---|---|---|
| Terms | Entity Master | One anatomy entity per UBERON term ID |
| Synonyms | Entity Alias | Search/display aliases attached to the canonical term |
| Xrefs | Crosswalk Registry | External source identifier mapped to the UBERON term |
| Alternative_IDs | Crosswalk Registry | Retired/alternate UBERON ID mapped to the canonical term |
| Subsets | Classification Membership | Declared ontology subset membership |
| Obsolete_Actions | Entity Lifecycle | Obsolete status and declared replacement/consider target |
| Relations_Original | Relationship Source | Immutable original edge or logical axiom |
| Term_Properties | Entity Property | Source-declared property value |
| Term_Audit | Evidence/Audit | Source tag retained for traceability |
| Ontology_Header | Source Release | Ontology-level release metadata |
| Typedef_Tags | Relationship Vocabulary | Predicate identity and metadata |

## Safety gates

1. Match one and only one connector rule.
2. Hash the workbook and every staged row.
3. Reject duplicate deterministic keys.
4. Never resolve anatomy by name when a UBERON ID exists.
5. Stage only; do not write directly to public/live tables.
6. Reconcile staged counts to the table above.
7. Approve the batch explicitly.
8. Rebuild the DB-to-Excel mirror after promotion.
9. Compare MySQL counts, mirror counts, and control-room counts.
10. Publish only API/renderer code to `public_html`; raw workbooks remain private.

## Formula boundary

UBERON supplies identities and anatomical relationships. It does not itself supply clinical formulas. Formula work may begin only after every variable refers to a canonical entity ID, every relationship states its predicate and direction, units use a controlled unit system, and evidence/source IDs are retained.

## Current external gate

The five source files must be present in the shared Google Drive intake folder or another approved private intake location reachable by the Hostinger sync job. GitHub does not store these binary source workbooks.
