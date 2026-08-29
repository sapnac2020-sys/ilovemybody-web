# RxNorm canonical synchronization contract

Status: the complete active NLM-normalized RxNorm identity layer is registered for validation and staging. Promotion remains approval and reconciliation controlled.

## Canonical identity

- RXCUI is the canonical medicine-concept identifier.
- The normalized name is a label, never a key.
- TTY is the official RxNorm concept class.
- Ingredients, dose forms, clinical drugs, branded drugs, and packs remain distinct semantic partitions.
- This module contains public NLM-normalized RxNorm concepts only; restricted third-party source atoms are excluded.
- Vocabulary presence is not prescribing guidance, substitutability, dosage approval, indication, or clinical evidence.

## Audited release counts

| Partition | Sheet | Rows |
|---|---|---:|
| Ingredients | 02_INGREDIENTS | 22,166 |
| Dose forms | 03_DOSE_FORMS | 170 |
| Clinical drugs | 04_CLINICAL_DRUGS | 58,259 |
| Branded drugs | 05_BRANDED_DRUGS | 43,004 |
| Packs | 06_PACKS | 1,398 |
| **Total** | | **124,997** |

RXCUI completeness and cross-partition uniqueness passed with zero duplicates.

## Formula boundary

A medicine formula must explicitly declare RXCUI, ingredient, strength, UCUM unit, dose form, route, timing, person context, evidence, contraindication logic, uncertainty, and release state. RxNorm identity alone is not a clinical formula.

## Deployment boundary

The private worker validates and stages rows. Promotion requires explicit approval and count/hash reconciliation. Raw terminology workbooks do not belong in public_html.
