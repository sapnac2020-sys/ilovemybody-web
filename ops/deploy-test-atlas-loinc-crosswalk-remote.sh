#!/usr/bin/env bash
set -euo pipefail
work="$1"
config="$2"
php "$work/ops/run-test-atlas-loinc-crosswalk-migration.php" "$config" "$work/backend/phase_56_test_atlas_loinc_crosswalk.sql"
