# I Love My Body Hospital UI

This directory contains the self-contained interactive hospital UI prototype.

## Preview

Open `index.html` in a modern browser.

## Deployment boundary

- Deploy this directory to `/hospital/` for staging and review.
- Do not replace the public root `index.html` or the existing `/app/` patient application.
- Prototype progress is stored in browser `localStorage` under `ilmbHospitalState`.
- Authentication, encrypted uploads, consent audit records, and permanent patient data must be connected to the server API before clinical or production use.
- Never add database credentials, patient information, reports, or private configuration to this repository.

## Product safety

The interface supports self-observation alongside appropriate medical care. It does not diagnose, prescribe, change medication, provide monitored emergency care, or promise a cure.

