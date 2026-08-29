# Gene Ontology canonical connector contract

## Authority and release

- System ID: `REF-GO`
- Authority: Gene Ontology Consortium
- Source edition: `go-basic.obo`
- Data version: `releases/2026-07-26`
- Official source: https://purl.obolibrary.org/obo/go/go-basic.obo
- Download documentation: https://geneontology.org/docs/download-ontology/
- Citation and reuse policy: https://geneontology.org/docs/go-citation-policy/

## Canonical partitions

| File pattern | Source partition | Sheets | Source rows |
|---|---|---|---:|
| `ILMB_GO_01_Terms_Release_*.xlsx` | TERMS | Terms; Obsolete_Actions | 54,214 |
| `ILMB_GO_02_Synonyms_Release_*.xlsx` | SYNONYMS | Synonyms | 129,521 |
| `ILMB_GO_03_Mappings_Release_*.xlsx` | MAPPINGS | Xrefs; Alternative_IDs; Subsets | 36,766 |
| `ILMB_GO_04_Relations_Release_*.xlsx` | RELATIONS | Relations_Original | 71,498 |
| `ILMB_GO_05_Properties_Release_*.xlsx` | PROPERTIES | Ontology_Header; Term_Properties | 14,845 |

## Identity and language rules

1. `term_id` is the stable canonical identity. Names and synonyms are labels, never keys.
2. Preserve the namespaces `biological_process`, `molecular_function`, and `cellular_component` exactly.
3. Preserve original relation predicates, target expressions, raw values, and ordinals.
4. Alternative IDs redirect to canonical GO identities; they are not independent entities.
5. Cross-references do not establish `SAME_AS`; cross-system equivalence requires separate evidence and review.
6. Retain obsolete records and their `replaced_by` or `consider` actions.

## Import boundary

- Header row: 4.
- Validate and upsert to staging only.
- Promotion requires count reconciliation, unique-key checks, and explicit approval.
- Release replacement must remain traceable and reversible.

## Formula and clinical boundary

GO supplies controlled biological terminology and asserted ontology structure. It does not supply person-level observations, causal effect sizes, diagnoses, treatments, clinical weights, or population values. Formula candidates may reference canonical GO IDs only after variables, units, evidence, and validation gates are separately declared.
