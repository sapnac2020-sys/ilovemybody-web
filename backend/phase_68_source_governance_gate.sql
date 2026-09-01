-- Phase 68: source-governance gate. Preserve unapproved legacy sources for audit,
-- but prevent their use in approved connectors, equations, or user-facing outputs.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_source_governance (
  source_key varchar(160) NOT NULL,
  governance_status enum('APPROVED_SOURCE','LEGACY_UNAPPROVED','REJECTED','SUPERSEDED') NOT NULL,
  connector_eligible tinyint(1) NOT NULL DEFAULT 0,
  calculation_eligible tinyint(1) NOT NULL DEFAULT 0,
  governed_by_manifest_key varchar(255) NULL,
  governance_note text NOT NULL,
  reviewed_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(source_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_source_governance
(source_key,governance_status,connector_eligible,calculation_eligible,governed_by_manifest_key,governance_note)
VALUES
('aatmn_parmar_sakshi_xlsx','LEGACY_UNAPPROVED',0,0,NULL,
 'Not present in ILMB_Data_Delivery_Final_Manifest_2026-08-30.xlsx. Preserved as an audit-only legacy input; prohibited from approved connectors, calculations and user-facing outputs.')
ON DUPLICATE KEY UPDATE
 governance_status=VALUES(governance_status),connector_eligible=VALUES(connector_eligible),
 calculation_eligible=VALUES(calculation_eligible),governed_by_manifest_key=VALUES(governed_by_manifest_key),
 governance_note=VALUES(governance_note),reviewed_at=CURRENT_TIMESTAMP(6);

UPDATE ilb_bibliography_entry
SET citation_status='RECORDED',
    note='Legacy audit-only source. Not present in ILMB_Data_Delivery_Final_Manifest_2026-08-30.xlsx; prohibited from approved connectors, calculations and user-facing outputs.'
WHERE citation_key='aatmn_parmar_sakshi_xlsx';

CREATE OR REPLACE VIEW v_ilb_source_governance_gate AS
SELECT g.source_key,g.governance_status,g.connector_eligible,g.calculation_eligible,
       g.governed_by_manifest_key,g.governance_note,
       CASE WHEN g.connector_eligible=1 AND g.calculation_eligible=1 THEN 'ELIGIBLE'
            ELSE 'BLOCKED' END AS output_gate
FROM ilb_source_governance g;

COMMIT;