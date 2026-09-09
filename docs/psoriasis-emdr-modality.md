# ILoveMyBody Psoriasis Project — EMDR Modality

## Purpose

EMDR is stored as a separate governed modality inside the psoriasis project. It is not represented as a direct psoriasis treatment and is not allowed to inherit direct IL-17, IL-23 or keratinocyte claims.

## Primary role

EMDR is an upstream modifier for the central threat / trauma-processing pathway:

`disturbing memory -> learned threat -> autonomic arousal`

The psoriasis connection is represented as a testable downstream hypothesis:

`EMDR -> target distress/arousal change -> possible neuroimmune change -> possible psoriasis change`

Each arrow carries its own evidence status. Improvement in the EMDR target cannot be substituted for improvement in skin disease.

## Protocol

The database records the standard eight phases as separate protocol steps:

1. History and treatment planning
2. Preparation
3. Assessment
4. Desensitization
5. Installation
6. Body scan
7. Closure
8. Reevaluation

## Psoriasis measurements

The existing private psoriasis intake automatically receives the new EMDR fields because they are registered under `PSO_COP_LIFESTYLE_V4`:

- EMDR target label
- SUD distress rating
- VOC adaptive-cognition rating
- target-linked body sensation
- HRV RMSSD (optional autonomic measure)
- EMDR session status

Skin outcome remains measured independently using existing psoriasis inputs such as PASI, BSA, target plaque measurement and itch.

## Decision rule

EMDR should only be considered when the trauma/threat pathway is clinically relevant and a qualified clinician considers EMDR appropriate. If distress/arousal improves without skin improvement, the hospital records a nervous-system response without claiming psoriasis response. If both change, the temporal relationship is recorded for research and still does not prove causality by itself.

## Database objects

Phase 105 adds:

- `ilb_modality_definition`
- `ilb_modality_pathway_link`
- `ilb_modality_protocol_step`
- `ilb_modality_measurement_link`
- `ilb_modality_evidence`
- `ilb_modality_session`
- `ilb_modality_session_measurement`
- `v_ilb_emdr_psoriasis_modality`

## Production gate

`ops/verify-emdr-modality.php` refuses any database other than `u756742628_ilovemybody`, applies the additive migration, verifies modality counts and confirms there is no direct IL-17 treatment claim for EMDR.
