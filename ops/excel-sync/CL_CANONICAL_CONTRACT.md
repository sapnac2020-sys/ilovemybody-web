# Cell Ontology canonical synchronization contract

Status: five source partitions registered. Production import remains validation, staging, approval, promotion, and reconciliation controlled.

## Canonical language

- Canonical cell identity is `term_id` using the official CL identifier.
- A preferred name is display text and never a database key.
- Synonyms are aliases attached to one canonical CL term.
- Alternative IDs and external xrefs are explicit crosswalks.
- Obsolete terms remain traceable through their declared replacement or consider targets.
- Original predicates, target expressions, source tags, and raw values remain immutable source evidence.
- No clinical relationship or formula is inferred from ontology membership alone.

## Registered partitions and audited counts

| Partition | Included source sheets | Rows |
|---|---|---:|
| TERMS | Terms; Obsolete_Actions | 19,081 |
| SYNONYMS | Synonyms | 47,803 |
| MAPPINGS | Xrefs; Alternative_IDs; Subsets | 46,548 |
| RELATIONS | Relations_Original | 79,783 |
| PROPERTIES | Ontology_Header; Term_Properties; Term_Audit; Typedef_Tags | 32,380 |
| **Total** | | **225,595** |

All configured natural/composite keys were present and unique in the audited release.

## Universal-layer mapping

| CL source | Universal layer |
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

## Cross-ontology rule

UBERON and CL identities remain distinct. A UBERON anatomy term and a CL cell term may be connected only by an explicit, directed, sourced relationship or crosswalk. Similar names never establish equivalence.

## Formula boundary

CL supplies governed cell identities and declared ontology relationships. Formula variables may reference CL IDs only after units, direction, context, evidence, and source version are explicit. Ontology structure alone is not clinical proof.

## Deployment boundary

Source workbooks remain private. The Drive/Hostinger worker validates and stages them. Promotion requires approval and count/hash reconciliation. Only API/renderer code belongs in `public_html`.
