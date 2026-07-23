# I Love My Body — Backend-Driven Application Contract

## One rule

The browser is a renderer and input device. It must not own health logic,
question order, wording, formulas, ranges, scoring, evidence selection,
eligibility, safety routing, journey duration, or motivational responses.

## Runtime sequence

1. Authenticate the participant where the current step requires it.
2. Read `v_ilb_app_current_step` for the participant's active enrollment.
3. Render the returned title, instruction, actions and screen type.
4. Read the named backend `read_contract`.
5. Submit only through the named backend `write_contract`.
6. Store an `ilb_app_step_event` receipt.
7. Ask the backend to validate the completion rule.
8. Advance `ilb_app_enrollment_state.current_step_key` only after validation.
9. Render the backend-returned next state and wording.

## Four entry routes

The first screen reads `v_ilb_app_active_pathway`. Multiple selections are
permitted:

- I have an illness
- I am anxious, tense or stressed
- I am addicted
- I am lost and seeking direction

These are reasons for arrival, not diagnoses or labels.

## Canonical flow

`v_ilb_app_flow_contract` exposes the active fourteen-step contract:

1. reason for arrival
2. privacy and consent
3. basic profile
4. medical history
5. medical reports
6. medicines and prescriptions
7. connected baseline review
8. PRE-10 assessment
9. clarity map
10. mentor preference
11. first seven-week journey
12. reassessment
13. optional second seven-week journey
14. continuing path

The second seven weeks are never automatic and are not a fixed 100-day
programme.

## Calculation boundary

The frontend does not calculate. The backend may return:

- source-defined validated instrument results;
- formula outputs whose required observations, units and provenance exist;
- coverage and completeness;
- within-person change where measurements are comparable;
- evidence links and qualifications;
- missing-data and review-required states.

The backend must not invent an overall human, happiness, health or energy
score. It must not turn correlation into causation, diagnose, prescribe,
recommend stopping medicine, or promise cure.

## Evidence boundary

Every explanatory result returns its formula or assessment identity, version,
source reference, applicability conditions, missing inputs, and review status.
Book content, participant encouragement, scientific evidence and medical
interpretation remain separate content classes.

## Safety and tone

The system asks rather than assumes, never labels a person, and allows
sensitive questions to be skipped. Emergency and clinician-routing rules
override ordinary journey progression. All medical treatment decisions remain
with the participant and qualified professionals.

