# Phase 107 — Psoriasis Genetic → Modifiable Pathway

## Core model

Psoriasis genetics are represented as susceptibility inputs, not as a deterministic active-disease equation.

`FIXED_GENETIC_SUSCEPTIBILITY -> MODIFIABLE_BIOLOGICAL_STATE -> MEASURED_PHENOTYPE`

The model therefore separates:

1. inherited susceptibility that is not changed by ordinary non-gene therapy;
2. immune, skin-cell, barrier, neuroimmune and metabolic states that can change over time;
3. the visible/clinical phenotype that must be measured independently.

## Mathematical scaffold

A generic person-level state model is stored conceptually as:

`Y(t) = F[G, X(t), P(t), B(t), C(t), E(t), R(t)]`

where:

- `G` = genotype / fixed susceptibility;
- `X(t)` = expression/regulatory state;
- `P(t)` = protein/signalling state;
- `B(t)` = biochemical/pathway state;
- `C(t)` = cellular and tissue state;
- `E(t)` = exposures / triggers / modifiers;
- `R(t)` = repair / compensatory state;
- `Y(t)` = psoriasis phenotype.

No coefficients are assigned unless sourced or measured. This phase therefore defines the variables and causal topology but does not invent a numerical cure equation.

## Canonical psoriasis path

`GENETIC SUSCEPTIBILITY -> ANTIGEN/INNATE ACTIVATION -> DC/IL-23 -> Th17/Tc17 -> IL-17A/F (+ TNF/IL-22 amplification) -> KERATINOCYTE ACTIVATION -> DIFFERENTIATION/MATURATION -> BARRIER -> PLAQUE`

## What must normalize

The pathway defines the biological targets rather than declaring a treatment:

- pathologic upstream immune activation decreases;
- pathogenic IL-23/type-17 signalling decreases;
- keratinocyte inflammatory activation decreases;
- epidermal differentiation/maturation normalizes;
- barrier integrity improves;
- plaque burden approaches clearance.

Genotype may remain unchanged throughout.

## Modality governance

Every modality link must record:

- target node;
- action class;
- expected direction;
- direct vs indirect action;
- psoriasis-specific evidence status;
- clinical-use status;
- claim boundary;
- measurement requirement.

No alternative modality may be represented as a direct IL-17 treatment or psoriasis cure without validated evidence.

### Current crosswalk

- EMDR: upstream neuroimmune/distress modifier; indirect; preliminary psoriasis evidence.
- Acupuncture: possible neuroimmune modifier; indirect; preliminary; no point-to-IL-17 claim.
- Nutrition: systemic/metabolic modifier where a relevant abnormality exists; not a universal psoriasis cure.
- Sleep: physiologic/upstream modifier; downstream skin effect must be measured.
- Exercise: systemic/metabolic modifier; not a direct cytokine treatment.
- UV phototherapy: established direct skin treatment, classified as conventional non-drug medical therapy rather than alternative medicine.
- Barrier care: established supportive downstream action; does not replace upstream immune control.
- Louise Hay: research-only emotional/meaning framework, not verified psoriasis etiology.
- Redikall: research-only emotional/meaning framework; no verified IL-23/IL-17/keratinocyte route.

## Louise Hay / supplied anecdotal narrative

The supplied psoriasis narrative is retained as a separate anecdotal note set with themes including fear of hurt, criticism/self-criticism, emotional shutdown, loss of purpose and emotional processing. These notes are explicitly marked `NOT_VERIFIED_CAUSE` and `ANECDOTAL`.

They may generate questions to measure, but cannot establish biological causation or efficacy.

## Verification gates

The production verifier requires:

- 8 genetic susceptibility factors;
- 12 modifiable nodes;
- 8 genetic-to-node links;
- 9 modality crosswalk links;
- 6 emotional narrative notes;
- genetic records remain `FIXED_GENOTYPE`;
- emotional narratives remain `NOT_VERIFIED_CAUSE`;
- EMDR remains indirect with an explicit no-direct-IL-17 boundary;
- alternative frameworks cannot acquire a direct IL-17 or cure claim;
- UV phototherapy remains explicitly distinguished as conventional non-drug medical treatment.

## What Phase 107 does not claim

It does not establish an alternative cure for psoriasis.

It establishes the governed structure needed to test the real question:

> With genetic susceptibility fixed, which measured modifiable biological variables must change, and which interventions can reproducibly change them enough for skin to normalize?
