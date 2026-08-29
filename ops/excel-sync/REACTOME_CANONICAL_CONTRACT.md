# Reactome V97 human canonical connector contract

## Authority and release

- System ID: `REF-REACTOME-HUMAN`
- Authority: Reactome
- Release: `V97`
- Species boundary: `Homo sapiens` and `R-HSA` records only
- Official download catalogue: https://reactome.org/download-data
- Official current-release directory: https://reactome.org/download/current/
- Database version endpoint: https://reactome.org/ContentService/data/database/version
- Licence: https://reactome.org/license

## Canonical content

| Layer | Source records |
|---|---:|
| Human pathways | 2,883 |
| Human pathway hierarchy edges | 2,899 |
| Human reactions | 16,093 |
| Reaction–PubMed evidence links | 43,590 |
| Protein-role-reaction records | 241,110 |
| Human complex records | 16,169 |
| UniProt-to-pathway mappings | 54,699 |
| UniProt-to-reaction mappings | 132,322 |
| ChEBI-to-pathway mappings | 13,100 |
| ChEBI-to-reaction mappings | 31,058 |
| Ensembl-to-pathway mappings | 381,765 |
| Ensembl-to-reaction mappings | 931,878 |

The source is packaged into 16 connector-sized Excel workbooks. Large partitions use deterministic 50,000-row worksheet segments.

## Identity and language rules

1. Reactome stable IDs remain canonical for pathways, reactions and complexes.
2. UniProt, ChEBI and Ensembl identifiers remain external canonical identities; labels never replace identifiers.
3. A mapping record is not a universal `SAME_AS` assertion. Preserve its Reactome event context and evidence code.
4. Preserve source evidence codes, PubMed identifiers, roles and hierarchy direction exactly.
5. Do not mix computationally inferred non-human events into the human foundation.
6. Duplicate external-ID/event pairs with different evidence codes are distinct source assertions and must not be collapsed.

## Import boundary

- Header row: 4.
- Validate and upsert to staging only.
- Natural keys are declared per worksheet in `modules.json`.
- Promotion requires source-count reconciliation, key checks and explicit approval.
- Every promoted release must remain traceable and reversible.

## Formula and clinical boundary

Reactome supplies curated pathway/event structure and source mappings. It does not provide person-level effects, causal weights, diagnoses, treatment recommendations, dosage formulas, population values or clinical approval. Formula candidates may reference these canonical identities only after variables, units, evidence, observations and validation gates are separately declared.
