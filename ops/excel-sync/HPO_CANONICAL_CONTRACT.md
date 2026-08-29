# Human Phenotype Ontology canonical synchronization contract

Status: five source partitions registered. Production import remains validation, staging, approval, promotion, and reconciliation controlled.

## Canonical language

- Canonical phenotype identity is the official HPO `term_id`.
- Preferred names are display labels, never keys.
- Synonyms are aliases and never additional phenotype entities.
- Alternative IDs and external xrefs are explicit crosswalks.
- Obsolete terms retain their declared replacement or consider targets.
- Original relationship predicates, target expressions, source tags, and raw values remain immutable source evidence.
- No disease, gene, prognosis, treatment, or person-level conclusion is inferred from an ontology relationship.

## Audited release counts

| Partition | Included source sheets | Rows |
|---|---|---:|
| TERMS | Terms; Obsolete_Actions | 20,995 |
| SYNONYMS | Synonyms | 26,237 |
| MAPPINGS | Xrefs; Alternative_IDs; Subsets | 22,872 |
| RELATIONS | Relations_Original | 24,378 |
| PROPERTIES | Ontology_Header; Term_Properties; Term_Audit; Typedef_Tags | 32,735 |
| **Total** | | **127,217** |

All configured natural/composite keys were complete and unique. `Term_Audit` contains zero source rows in this release and therefore contributes no staged records.

## Universal-layer mapping

| HPO source | Universal layer |
|---|---|
| Terms | Entity Master |
| Synonyms | Entity Alias |
| Xrefs and Alternative_IDs | Crosswalk Registry |
| Subsets | Classification Membership |
| Obsolete_Actions | Entity Lifecycle |
| Relations_Original | Relationship Source |
| Term_Properties | Entity Property |
| Term_Audit | Evidence/Audit |
| Ontology_Header | Source Release |
| Typedef_Tags | Relationship Vocabulary |

## Cross-system rule

HPO phenotype IDs, UBERON anatomy IDs, CL cell IDs, MONDO disease IDs, HGNC gene IDs, and LOINC observation IDs remain distinct. Connections require an explicit directed relationship or versioned crosswalk. Name similarity never creates equivalence.

## Formula boundary

HPO supplies governed phenotype identities and declared ontology structure. A formula may reference an HPO ID only when the person-level observation, measure, time, unit, context, source, and uncertainty are explicit. Ontology structure alone is not a clinical formula or proof.

## Deployment boundary

Source workbooks remain private. The worker validates and stages them. Promotion requires approval and count/hash reconciliation. Raw workbooks do not belong in `public_html`.
