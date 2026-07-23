# Backend Freeze — PRE-10 and N.A.I.V.E.

## Database state audited

Source audited: `u756742628_ilovemybody (3).sql`, exported 22 July 2026.

The export contains the existing subject, consent, documents, medical history, medicines, laboratory measurements, psychometric instruments, direction, evidence, formulas, N.A.I.V.E. programme, protocol, safety, food, body-signal, action and content systems.

No existing personal records are changed by Phase 42.

## Live backend status

Imported and verified on Hostinger on 23 July 2026 (UTC verification
`2026-07-23 06:12:52`).

- active dimensions: 10
- PRE-10 days: 10
- active assessments: 18
- active assessment items: 71
- response options: 329
- active result definitions: 8
- structural readiness blockers: 0

The private repository records the non-sensitive verification at
`docs/LIVE_BACKEND_STATUS.md`.

## Backend migration files

1. `backend/phase_42_pre10_clarity_engine.sql`
2. `backend/phase_42b_pre10_choice_library.sql`
3. `backend/phase_42c_pre10_calculation_contract.sql`

They have been imported in that order into `u756742628_ilovemybody`.

All three files are rerunnable. Phase 42B includes the corrected derived-table
aliases used by its choice library.

The secure migration workflow is:

`.github/workflows/migrate-backend.yml`

It uses the existing Hostinger SSH secret, reads database credentials only from
the private server configuration, runs the migrations, verifies structural
readiness, and records no credentials or patient-authored data.

## What Phase 42 adds

- 10 connected PRE-10 dimensions
- 10-day plan and daily route
- assessment registry
- links to existing validated psych and direction instruments
- original ILB discovery item bank
- explicit response scale anchors
- assessment sessions, responses and calculated results
- participant-owned reflections
- day progress
- optionality and privacy boundaries
- provenance fields and result-language rules

## What Phase 42C computes

The backend now has a declared calculation contract. It computes:

- assessment information availability;
- item-level normalization for questions with a declared numeric scale;
- validated/imported results under the named instrument’s own rules;
- coverage of the ten connected dimensions;
- source catalogues for assessments and stored scientific formulas.

It deliberately does **not** calculate one “human”, “health”, “happiness” or
“energy” score. Different questions, laboratory values and validated
instruments are not mathematically interchangeable merely because they are
connected.

Frontend/API read contracts:

- `v_ilb_pre10_latest_response`
- `v_ilb_pre10_assessment_progress`
- `v_ilb_pre10_item_result`
- `v_ilb_pre10_dimension_coverage`
- `v_ilb_pre10_source_catalog`
- `v_ilb_formula_source_catalog`
- `v_ilb_backend_readiness`

Definitions and audit tables:

- `ilb_pre10_result_definition`
- `ilb_pre10_calculation_audit`

## Registered validated routes

- WHO-5
- PHQ-9 (conditional; safety workflow required)
- GAD-7 (conditional)
- IPIP (one exact public-domain version must be frozen)
- Rosenberg Self-Esteem Scale

Validated instruments are not duplicated or paraphrased in the original ILB question bank.

## Original ILB discovery routes

- present reality
- thoughts and attention
- beliefs and body relationship
- feelings and expression
- values
- lifestyle and comfort zones
- relationships and belonging
- intimacy and desire
- dreams and direction
- instinct, courage and self-trust
- Complete Clarity review

## Existing programme retained

PRE-10 does not replace N.A.I.V.E.

Sequence:

1. PRE-10 information gathering
2. seven-week N.A.I.V.E. journey
3. reassessment
4. optional second seven weeks when chosen and appropriate

## Verification

`v_ilb_backend_readiness` is the canonical structural readiness check. The live
verified result contains zero blocked rows.

## What still requires application work before live patient onboarding

The backend contract is live. It cannot create user interfaces or clinical
operations by itself. Before inviting patients, the separate application must:

- configure the web forms and APIs;
- exercise consent and withdrawal;
- test save/resume and document upload;
- test medicine-photo confirmation;
- test safety routing with qualified reviewers;
- freeze the exact IPIP version and scoring key before presenting its items;
- verify official instrument presentation and licences;
- implement source pop-ups from stored provenance;
- run access-control and privacy tests;
- complete a clinician review of participant-facing wording;
- run a de-identified end-to-end test account.

Do not enter live patient information into development or screenshots.
