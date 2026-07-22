I LOVE MY BODY — PUBLIC WEBSITE

Open index.html to preview.

Seven public views:
Home / Our Method / What We Connect / Treatment Plan / Non-Invasive Care / Evidence / Selected Practitioners.
My Happy Space is the separate private patient application at /app/.

Deployment:
1. Upload the contents of this folder into the public_html root for ilovemybody.in.
2. Keep the existing /app/ folder unchanged; all My Happy Space links point to /app/.
3. The source counts (52 families / 275 references) reflect the last completed audit supplied in the project. Replace them with live backend counts once the public evidence endpoint is available.
4. The Selected Practitioners buttons are intentionally non-transactional until practitioner records and booking routes are connected.
5. Google Fonts are loaded from fonts.googleapis.com. Self-host them if required by privacy policy.

This frontend does not contain database credentials and does not diagnose, prescribe, or change medicines.
I LOVE MY BODY — PUBLIC WEBSITE

Production: https://ilovemybody.in/
Private patient app: https://ilovemybody.in/app/

The public website is static HTML, CSS and JavaScript. The private patient app
is separate and is deliberately excluded from this repository and deployment.

Deployment
----------
Pushes to main deploy index.html and assets/ through GitHub Actions. The action:

1. validates the three public source files;
2. uses the single HOSTINGER_DEPLOY_BUNDLE repository secret;
3. backs up the existing public index and assets on Hostinger;
4. replaces only index.html and assets/;
5. verifies that /app/ still exists and remains reachable.

Never commit database credentials, SSH keys, patient records, medical reports,
private uploads or live config files.

Product boundary
----------------
I Love My Body complements appropriate medical care. Public automation does
not diagnose, prescribe, stop medicine or promise cure. Evidence, tradition,
author philosophy and personal observations retain separate labels.
