# Pranic Healing verification protocol — draft v0.1

Date: 2026-09-30
Status: design proposal. Not registered, ethically approved, funded or conducted.
This document specifies tests; it reports no experimental findings.

## Questions and separate conclusions

| Question | Test | A positive result would support |
| --- | --- | --- |
| Can practitioners detect a concealed condition? | Randomised blinded discrimination | Detection under the tested conditions |
| Does a session improve a defined recipient outcome? | Randomised matched-sham trial | An intervention effect for that population and outcome |
| Is a physical signal associated with the session? | Calibrated instrument study | A signal within the instrument's measured quantity and bandwidth |

None of these conclusions alone establishes the others. A negative experiment bounds the tested claim and conditions; it does not test every spiritual interpretation.

## Experiment PH-D01: concealed-hand discrimination

Claim operationalisation: a participating practitioner agrees, before randomisation, that their scanning method can identify which of two concealed positions contains a volunteer's hand without ordinary sensory cues. This is narrower than detecting illness.

Set up two geometrically identical positions behind an opaque screen. Both must have the same apparent temperature, airflow, sound and visible features at the practitioner's side. Test these conditions with sham observers first. If ordinary heat or other cues cannot be excluded, report a sensory-discrimination test rather than a subtle-energy test.

An independent controller creates balanced, randomly ordered left/right assignments, concealed from practitioners and the staff recording responses. The volunteer follows the assignments without communicating. The practitioner gives one forced left/right answer and confidence score before the assignment is revealed. No feedback is given until all trials finish. Set scan distance and time in advance; log deviations.

Planning example: 20 practitioners, 40 trials each, across two sessions; 800 responses. These are planning numbers, not a powered final sample. Do not treat 800 responses from 20 practitioners as 800 independent people.

Primary estimand: accuracy across practitioners versus 0.5. Primary inference: a preregistered randomisation test respecting each practitioner's balanced assignment schedule, with a confidence interval accounting for practitioner clustering. A binomial test is suitable only where independence assumptions are justified. Freeze the analysis code on synthetic data before unmasking. Report all practitioners, trial counts, uncertainty, exclusions and deviations. Individual practitioner analyses are secondary and require multiplicity control.

Choose the smallest scientifically relevant accuracy advantage before calculating power. Simulate the complete design, including within-practitioner correlation, absences and exclusions. Do not choose sample size by inspecting emerging results. Repeat any positive finding in a new sample with independent investigators.

## Experiment PH-O01: recipient outcomes

Begin with one non-emergency outcome agreed with a qualified clinical investigator; do not combine depression, cancer and general wellbeing into one endpoint.

Specify the population, eligibility, primary outcome instrument, baseline period, follow-up times, standard care, intervention dose and smallest meaningful difference. Use validated instruments and their required licences. Preserve usual care.

Randomise participants to Pranic Healing or a plausible matched sham with the same session duration, room, interaction and schedule. Keep allocation concealed until enrolment. Outcome assessors and analysts remain masked. Practitioners generally know their assignment; document this limit. Record recipient guesses and expectations without using them to selectively remove participants.

Record session adherence, concurrent treatments, changes in medication, adverse events and losses to follow-up in both arms. Prespecify a clinical escalation route and stopping rules. Analyse participants by allocated group; specify missing-data handling before collecting data. Use a baseline-adjusted between-group model and report effect size with confidence interval, not only a p-value.

For an approximate two-arm continuous-outcome design, per-arm sample size is:
n = 2 × (z_(1-alpha/2) + z_(1-beta))² × sigma² / delta².
Here sigma is an independently estimated outcome standard deviation and delta is the agreed meaningful difference. Inflate for attrition and adapt for clustering or repeated measures. This approximation is not a substitute for the final statistical design.

Register protocol and analysis before enrolment, obtain applicable ethics approval and consent, and publish null as well as positive findings. Veterinary studies need separate veterinary endpoints, professional oversight and approval; human scales and reference intervals cannot simply be reused.

## Experiment PH-M01: proposed physical signal

First ask for a quantitative prediction: which measured quantity, where, when, direction, magnitude and bandwidth? If none is specified, describe the work as exploratory. Do not define a positive signal after inspecting many sensors.

For a magnetic hypothesis, use an appropriately calibrated magnetometer and report tesla, bandwidth, sensitivity, background fields, shielding and detection threshold. For electrical, optical, thermal or acoustic hypotheses, specify the corresponding calibrated quantity and units. Instruments measure those quantities; none is automatically a prana meter.

Randomise active and sham periods; blind the instrument operator and analyst to labels. Include empty-room, participant-only, device-drift and matched-motion controls. Synchronise time stamps, preserve raw files and calibration records, and analyse a prespecified time window. Control for breathing, muscle movement, room temperature and ordinary electrical equipment.

Set an acceptable false-positive rate and minimum detectable signal before collection. A null result excludes only signals above the stated threshold in the measured conditions. A positive result needs artefact exclusion and independent replication before being connected to recipient outcomes.

## Measurement and terminology contract

| Record | Representation |
| --- | --- |
| Laboratory or clinical observation | Existing approved LOINC identity, with original result and source preserved |
| Unit | Original unit; UCUM mapping only when validated |
| Diagnosis | Existing approved diagnosis terminology where available; do not derive diagnosis from LOINC |
| Practitioner perception | Explicit local research variable with definition, scale and assessor |
| Session | Practice, date/time, duration, mode, adherence and protocol version |
| Veterinary observation | Species, specimen, method and species-appropriate interpretation |

LOINC identifies what was observed. It neither proves energy transfer nor makes unlike specimens, methods or populations comparable. Do not invent a LOINC code for chakra balance or a healing session. Keep raw values and any transformed values separately with transformation provenance.

The existing private result-link implementation is a session log, not a complete research electronic data capture system. Research needs consent tracking, allocation concealment, locked endpoint definitions, audit history and analysis exports before enrolment.

## Evidence review completion worksheet

Search Pranic Healing and Choa Kok Sui variants in PubMed/MEDLINE, Europe PMC, Crossref, ClinicalTrials.gov and WHO ICTRP; add relevant regional indexes, dissertation repositories and citation chasing. Record platform, exact query, date and limits. Search practitioner organisations separately for teaching history and unpublished studies. Access-dependent databases should be marked inaccessible, not silently counted as searched.

Deduplicate by DOI/PMID and title-author-year. Retain a screening log with reasons for exclusion. For included studies extract population, enrolment and analysed counts, randomisation, allocation concealment, comparator, masking, endpoint, missing data, effect and uncertainty, registration, funding and investigator affiliations. Separate controlled studies, uncontrolled series and narratives.

Check the publisher record, PubMed publication types/linked notices and Crossmark where available for corrections or retractions. A search with no notice is dated, not a permanent guarantee. Assess risk of bias per outcome. Do not pool studies with incompatible populations or endpoints.

This worksheet has not yet been completed as a systematic review. The published entry remains a focused initial review.

## Completion status

| Deliverable | Status |
| --- | --- |
| Database-backed public Pranic entry | Merged; production database deployment unverified |
| Private session/result links | Merged; synthetic SQL and HTTP integration checks passed |
| Hostinger deployment | Blocked by SSH authentication |
| Detailed verification designs | This draft |
| Complete systematic review | Pending |
| Registered, approved experiments | Not started |
| Evidence of mechanism from this department | No experiments conducted |
| Full-text book hosting | Permission/licence review required |

Keep patient narratives and credentials out of this public repository. Scientific study status must not be changed merely because website implementation is complete.

## Dated status correction — 30 September 2026
The earlier SSH-blocked/deployment-pending statements above describe the initial implementation stage. Production migration and page checks passed for commit bebffef in [run 36728282791](https://github.com/sapnac2020-sys/ilovemybody-web/actions/runs/36728282791). Later commits require their own deployment evidence. See [completion register](energy-healing-completion-register.md) for current coverage and remaining scientific gates. No scientific status is promoted by deployment.
