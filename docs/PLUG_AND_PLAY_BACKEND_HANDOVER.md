# I Love My Body — Plug-and-Play Backend Handover

## Frozen product

**I Love My Body Self-Care Hospital**  
**Where Health Meets Happiness**  
**Everything is connected.**

The frontend is a renderer. The database owns the vocabulary, content,
navigation, journey, questions, calculation definitions, source boundaries,
access rules and current patient state.

The supplied HTML remains the visual source. These migrations do not redesign
it.

## Import order

The live database already contains the scientific, medical, food, evidence,
PRE-10 and canonical journey foundations through Phase 46.

Import these new files into `u756742628_ilovemybody` in this exact order:

1. `backend/phase_47_hospital_product_contract.sql`
2. `backend/phase_48_patient_runtime_contract.sql`
3. `backend/phase_49_plug_and_play_freeze.sql`

All three are rerunnable and do not delete patient-authored records.

## Phase 47 — product source of truth

Phase 47 adds:

- canonical brand and safety settings;
- seven human departments:
  - Body Talk
  - Vitality
  - The Senses
  - Feeling
  - The Mind
  - Expression
  - Self
- the Connection Centre as the nervous-system hub;
- the Book as a separate content department;
- hospital rooms and their access/data contracts;
- entrance, lobby and patient-dashboard navigation;
- versioned participant-facing content blocks;
- seven selectable accent themes with controlled light and dark surfaces;
- the complete journey template:
  - registration;
  - medical starting picture;
  - 10-Day Discovery;
  - first seven weeks;
  - two-day reassessment;
  - optional second seven weeks;
  - continuing self-care;
- the connection loop:
  - exteroception;
  - interoception;
  - proprioception;
  - nervous system;
  - gut, heart and brain;
  - memory;
  - somatic, autonomic and neuroendocrine–immune outputs;
  - consequence and feedback;
- the change path:
  - clutter;
  - confusion;
  - comfort zone;
  - action;
  - consequence;
  - conscience;
  - change;
  - cleanliness;
  - cohesion;
  - class;
  - clarity;
  - pattern-based foresight;
  - conscious awareness;
- seven transparent metric definitions with meaning and limitations.

No universal health, happiness, energy or human score is created.

## Phase 48 — patient runtime

Phase 48 adds:

- private accounts with hashed mobile identity and hashed PIN;
- revocable, expiring sessions and CSRF-token hashes;
- registration progress;
- persistent theme, background, font and text-size preferences;
- one versioned patient journey state;
- stage history;
- a private-by-default journal;
- intent, choice, action and consequence records;
- public bot conversations with a three-question registration gate;
- versioned API/data contracts;
- read models for:
  - public hospital bootstrap;
  - journey structure;
  - Connection Centre;
  - one patient dashboard.

The web server must resolve `subject_key` from the authenticated session. It
must never trust a `subject_key` supplied by the browser.

## Phase 49 — release freeze

Phase 49:

- freezes the new objects into release
  `ilb_backend_2026_07_24_complete`;
- registers every canonical frontend contract;
- keeps the excluded third-party micro-point experiment blocked and retired;
- retires the obsolete related freeze issue;
- adds a deterministic readiness inventory;
- publishes the final release summary.

## Frontend entry contracts

### Public entrance and lobby

Read:

```sql
SELECT * FROM v_ilb_public_hospital_bootstrap;
```

This returns only active public settings, departments, navigation and content.
It contains no patient records.

### Journey explanation

Read:

```sql
SELECT * FROM v_ilb_journey_contract
ORDER BY display_order;
```

The frontend must display these durations and optionality rules rather than
hard-code “100 days”.

### Connection Centre

Read:

```sql
SELECT * FROM v_ilb_connection_contract
ORDER BY FIELD(component_group,'incoming','centre','connector','memory','outgoing','feedback'),
         display_order;
```

Plain-language explanations and scientific boundaries must be shown together.

### Patient dashboard

After authenticated server-side subject resolution:

```sql
SELECT * FROM v_ilb_patient_dashboard
WHERE subject_key = :authenticated_subject_key;
```

The dashboard shows one current stage and one next action. It should link to
records, discovery, check-in, journal, sources and appearance without turning
them into separate competing homepages.

### API registry

Read:

```sql
SELECT * FROM ilb_data_contract
WHERE status = 'active'
ORDER BY route_path, http_method;
```

The request/response shapes and handler boundaries are stored here.

## Calculations

The active patient-facing calculation definitions are in:

```sql
SELECT * FROM ilb_metric_definition
WHERE status = 'active';
```

Every metric stores:

- a stable key and intuitive name;
- its mathematical expression;
- required inputs;
- minimum observations;
- output unit;
- plain-language meaning;
- limitation;
- patient-facing label.

The existing scientific formula, validated-instrument and evidence systems
remain canonical. Phase 47 does not overwrite them.

## Medical and privacy boundaries

The application must:

- work alongside existing medical treatment;
- never diagnose, prescribe or change medicine automatically;
- keep clinical, book, evidence and encouragement content distinct;
- retain participant wording;
- allow sensitive questions to be skipped;
- make private journal content private by default;
- let safety routing override ordinary feedback;
- display a source, scope and limitation for explanatory results;
- avoid causal language for personal associations;
- store neither raw PINs nor raw session/CSRF tokens.

## Final verification

After importing all three files, run:

```sql
SELECT * FROM v_ilb_release_summary;
```

Expected:

- `missing_objects = 0`
- `active_departments = 9`
- `active_journey_stages = 7`
- `active_api_contracts = 8`
- `active_metric_definitions = 7`

Then run:

```sql
SELECT * FROM v_ilb_plug_play_readiness
WHERE readiness_status <> 'ready';
```

Expected: zero rows.

This verifies structural readiness. Before real patient onboarding, the web
server still requires production credentials, TLS, secure upload storage,
session cookies, rate limiting, backups, restore testing, access logging and a
de-identified end-to-end test.
