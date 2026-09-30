# Energy Healing Research Department
Parent: I Love My Body (ilovemybody.in)
Status: implementation draft; database import and website integration pending.
Proposed route: /research/energy-healing/

## Purpose
Understand energy-healing traditions, document experiences respectfully, and test outcomes and proposed mechanisms through reproducible research.

## Initial scope
Pranic Healing is the first investigation. Include Magnified Healing, Reiki, Therapeutic Touch, Healing Touch, Quantum-Touch, Access Bars, distance healing, chakra/aura practices and crystal-based energy healing. Exclude acupuncture, acupressure and movement-based modalities from this department.
Heartfulness/Spiritual Anatomy and Ho’oponopono may be studied as related spiritual frameworks, with their distinctions recorded rather than assumed to be energy-transfer techniques.

## Public sections
1. Understand the practices: origin, terminology, teaching organisations and described procedures.
2. Research library: source records, study designs, findings, limitations and replication.
3. Connections: practitioner-proposed connections and independently tested links labelled separately.
4. Verification lab: preregistered protocols, measurement methods and research progress.
5. Findings: conclusions limited to the specific outcome and population studied.

## Private workspace
Case narratives, supporting clinical/veterinary records, session logs and consent belong in the existing authenticated application, never in public GitHub or an openly served directory. No personal cases are seeded by this migration. Public case reports require explicit publication consent and de-identification.

## Evidence rules
Keep spiritual teachings, reported experiences, clinical outcomes and physical mechanisms distinguishable. Lack of review means NOT_REVIEWED, not absence of evidence. Practitioner materials document teachings; they do not establish efficacy. Assess evidence per claim, outcome and population, not with a single rating for a whole practice.
Record source page/section, study design, sample size, comparator, masking, funding, effect estimate, uncertainty and limitations in evidence reviews. Record correction/retraction checks and reviewer/date.

## Verification programme
Begin with blinded practitioner discrimination tasks and randomised sham-controlled studies of defined outcomes. Preregister primary endpoints, randomisation, sample size justification, analysis and exclusions. Measure recipient outcomes separately from practitioner sensations. HRV/EEG changes do not by themselves establish subtle-energy transfer.
For proposed physical energy measurements specify units, calibration, background controls, shielding, detection thresholds and independent replication. Mathematical models require observed data and externally tested predictions; equations alone do not validate a healing mechanism.
Clinical/veterinary studies require appropriate professional oversight and applicable research ethics review.

## Books and source access
Store bibliographic records and links first. Host full text only when documented permission, licence or public-domain status allows the intended use. Research purpose is not itself permission to redistribute a book.

## Implementation
Apply backend/energy_healing_department.sql to a reviewed staging database first.
This adds independent ilb_ehr_* tables and seed scope records, without modifying disease models or treatment recommendations.
Build public read-only pages from these database tables, showing only PUBLISHED records. Put editing behind the existing authenticated admin and retain revision history.
Private cases will need a separate authenticated implementation; the public research tables do not store patient data.
Migration is rerunnable for its own seed records; CREATE TABLE IF NOT EXISTS does not validate a pre-existing conflicting schema.
Before production: back up, compare actual schema, test migration twice, confirm counts, verify public/private access, then integrate navigation.

## Dated status correction — 30 September 2026
The earlier SSH-blocked/deployment-pending statements above describe the initial implementation stage. Production migration and page checks passed for commit bebffef in [run 36728282791](https://github.com/sapnac2020-sys/ilovemybody-web/actions/runs/36728282791). Later commits require their own deployment evidence. See [completion register](energy-healing-completion-register.md) for current coverage and remaining scientific gates. No scientific status is promoted by deployment.
