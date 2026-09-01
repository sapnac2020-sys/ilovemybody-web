-- Phase 69: legacy sources may be used as audit inputs during verification,
-- while remaining barred from approved connectors, calculations and public output.
START TRANSACTION;

ALTER TABLE ilb_source_governance
  ADD COLUMN IF NOT EXISTS verification_eligible tinyint(1) NOT NULL DEFAULT 0
  AFTER governance_status;

UPDATE ilb_source_governance
SET verification_eligible=1,
    governance_note='Legacy audit input permitted for source-fidelity and independent verification review only. It remains prohibited from approved connectors, calculations and user-facing outputs until added to the ILMB master manifest and independently accepted.'
WHERE source_key='aatmn_parmar_sakshi_xlsx';

CREATE OR REPLACE VIEW v_ilb_source_governance_gate AS
SELECT g.source_key,g.governance_status,g.verification_eligible,g.connector_eligible,g.calculation_eligible,
       g.governed_by_manifest_key,g.governance_note,
       CASE WHEN g.connector_eligible=1 AND g.calculation_eligible=1 THEN 'ELIGIBLE'
            ELSE 'BLOCKED' END AS output_gate
FROM ilb_source_governance g;

COMMIT;