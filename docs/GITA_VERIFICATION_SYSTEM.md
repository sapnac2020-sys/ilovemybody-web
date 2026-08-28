# Phase 50 — Bhagavad Gita Verification System

## Purpose

Phase 50 imports the supplied 700-slot Bhagavad Gita workbook into governed database layers without treating scripture, a translation, or an interpretation as clinical fact.

## Imported corpus

The controlled workbook batch is identified by SHA-256:

`93af638cc14477a7c6039454619745b4cfce1f59e263a0ab82f6eecc56255bd5`

Expected post-import counts:

- 18 chapters
- 700 verse slots
- 700 exact Sanskrit source records
- 700 nonblank source hashes
- 6,568 machine-token rows covering all 700 verses
- 700 draft translations
- 19 body candidate records
- 11 food candidate records
- 20 machine-draft propositions
- 12 formula definitions
- 9 passing deterministic arithmetic tests
- 0 approved translations
- 0 preregistered predictions
- 0 verified personal results
- 0 personally supported claims

The last four zeroes are deliberate truth controls, not missing-data defects.

## Separation contract

The database keeps these layers distinct:

1. edition and immutable source text;
2. tokenisation, grammar and glosses;
3. translation and commentary;
4. text propositions;
5. body, food and other candidate mappings;
6. hypotheses and falsification rules;
7. preregistered predictions;
8. personal protocols and observations;
9. numeric measurements with units and uncertainty;
10. calculated results;
11. replications and contradictions;
12. proof gates.

No candidate mapping is copied into anatomy, clinical claims, or a person's body state.

## Proof gate

A prediction can reach `supported_personally` only when all of the following are true:

- source text is frozen;
- translation is reviewed;
- prediction is preregistered;
- formula version is frozen;
- personal measurements exist;
- uncertainty is calculated;
- minimum replication is met;
- contradictions are resolved.

Even then, the result means supported for the measured person and protocol. It does not establish a universal cure, diagnosis, or biological law.

## Files

- `backend/phase_50_gita_verification_system.sql`
- `backend/phase_50a_gita_corpus.sql.gz`
- `ops/run-backend-migrations.php`
- `.github/workflows/migrate-backend.yml`

Both migrations are rerunnable. Corpus inserts are immutable `INSERT IGNORE` records under a versioned import batch.

## Readiness query

```sql
SELECT * FROM v_ilb_gita_readiness;
```

Expected immediately after import:

```text
verse_rows=700
source_rows=700
hashed_source_rows=700
tokenised_verses=700
approved_translations=0
passing_formula_tests=9
preregistered_predictions=0
verified_results=0
personally_supported_claims=0
```

## Next scientific work

The corpus import completes the governed foundation. It does not fabricate the unfinished human work. Sanskrit review, translation approval, hypothesis design, preregistration, personal measurement, replication and contradiction review remain explicit queues.
