# Backend Freeze — PRE-10 and N.A.I.V.E.

## Database state audited

Source audited: `u756742628_ilovemybody (3).sql`, exported 22 July 2026.

The export contains the existing subject, consent, documents, medical history, medicines, laboratory measurements, psychometric instruments, direction, evidence, formulas, N.A.I.V.E. programme, protocol, safety, food, body-signal, action and content systems.

No existing personal records are changed by Phase 42.

## New backend files

1. `backend/phase_42_pre10_clarity_engine.sql`
2. `backend/phase_42b_pre10_choice_library.sql`

Import in that order into `u756742628_ilovemybody`.

Both files are rerunnable and were statically parsed as MySQL/MariaDB SQL:

- Phase 42: 34 statements
- Phase 42B: 6 statements

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

## Verification after import

Expected:

- `pre10_dimensions` = 10
- `pre10_days` = 10
- `scales_missing_anchors` = 0
- `choice_items_without_options` = 0 after Phase 42B

The exact assessment and item totals are intentionally returned by the verification queries rather than hard-coded here, so future reviewed additions do not create false failure messages.

## Remaining operational work before live patient onboarding

Schema-complete does not mean clinically live. Before inviting patients:

- configure the web forms and APIs;
- exercise consent and withdrawal;
- test save/resume and document upload;
- test medicine-photo confirmation;
- test safety routing with qualified reviewers;
- freeze the exact IPIP version and scoring key;
- verify official instrument presentation and licences;
- implement source pop-ups from stored provenance;
- run access-control and privacy tests;
- complete a clinician review of participant-facing wording;
- run a de-identified end-to-end test account.

Do not enter live patient information into development or screenshots.

