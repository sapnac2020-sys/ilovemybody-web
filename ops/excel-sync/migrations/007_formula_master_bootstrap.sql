-- Formula Master provenance schema only.
-- Live equation rows are imported by run-body-need-master-migrations.php after it inspects
-- the actual production registry column contract. This avoids guessing legacy column names.

ALTER TABLE ilmb_formula_master
  ADD COLUMN IF NOT EXISTS source_system VARCHAR(64) NULL AFTER evidence_class;
ALTER TABLE ilmb_formula_master
  ADD COLUMN IF NOT EXISTS source_record_key VARCHAR(191) NULL AFTER source_system;
ALTER TABLE ilmb_formula_master
  ADD UNIQUE KEY IF NOT EXISTS uq_ilmb_formula_source (source_system, source_record_key);
