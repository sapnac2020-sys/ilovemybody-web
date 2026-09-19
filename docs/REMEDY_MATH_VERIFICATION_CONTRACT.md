# Phase 50 — Remedy Mathematics Verification Contract

## Purpose

ILMB may catalogue every proposed remedy while refusing to treat catalogue presence, tradition, publication, popularity or practitioner confidence as proof.

The engine separates:

1. remedy identity and attribution;
2. proposed target and claimed mechanism;
3. measurable exposure;
4. personal baseline;
5. personal response;
6. uncertainty and confounders;
7. repeatability;
8. safety and clinical control;
9. mathematical verification status.

## Personal truth states

Numeric personal records use only:

- `PERSON_MEASURED`
- `MATHEMATICALLY_DERIVED`
- `UNKNOWN`

External catalogues and structural descriptions are scaffolding, not personal truth.

## Remedy verification states

- `NOT_TESTABLE_YET`
- `TEST_IN_PROGRESS`
- `NO_MEASURABLE_EFFECT`
- `PERSONAL_RESPONSE_OBSERVED`
- `REPEATED_PERSONAL_RESPONSE`
- `CONTRADICTORY`
- `UNSAFE`
- `REJECTED`

No state means universal efficacy or cure. A repeated personal response remains specific to the person, protocol, measurements, assumptions and observation window.

## Mathematical minimum

For a response variable `y`:

```text
absolute_change = intervention_value - baseline_value
relative_change = absolute_change / ABS(baseline_value)
```

Relative change is unavailable when the baseline is zero. Uncertainty, repeatability and confounders must accompany the result. Formula execution is versioned and its inputs are retained in `calculation_json`.

## Clinical boundary

This layer does not diagnose, prescribe, change medication, declare cure or override clinician judgement. Stop rules and safety variables are mandatory before an active protocol may be `TESTABLE`.

## Deployment

The migration is additive and rerunnable. Review and test it against a non-production schema before using the existing controlled migration workflow. Do not place patient data in GitHub, workflow logs or screenshots.
