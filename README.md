# I Love My Body

The main website is the I Love My Body Self-Care Hospital experience: a connected digital hospital designed to work alongside appropriate medical care.

## Production structure

- `/index.html` — public hospital entrance, lobby and complete UI/UX prototype.
- `/assets/` — public styles, scripts and hospital visual assets.
- `/app/` — existing private PHP patient application and APIs; preserve until its functions are migrated into the new hospital experience.
- `/api/` — public API endpoints.
- `/backend/` — database schema, migrations and evidence-mapping work.
- `/ops/`, `/tests/`, `/proofs/`, `/docs/` — deployment, verification and operational records.

## Data boundary

The public hospital prototype currently stores demonstration progress in browser local storage. Authentication, encrypted uploads, consent auditing and permanent patient data must use the server API before clinical or production use.

Never commit database credentials, SSH keys, patient records, medical reports, private uploads or live configuration files.

