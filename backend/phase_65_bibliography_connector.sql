-- Phase 65: bibliography connector for all ILMB claims and calculations.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_bibliography_entry (
  bibliography_id bigint unsigned NOT NULL AUTO_INCREMENT,
  citation_key varchar(160) NOT NULL,
  source_class enum('PRIMARY_SOURCE','STANDARD','ONTOLOGY','DATABASE','STUDY','BOOK','OTHER') NOT NULL,
  title varchar(1000) NOT NULL,
  author_or_organisation varchar(1000) NULL,
  publication_year smallint unsigned NULL,
  version_or_release varchar(255) NULL,
  doi varchar(255) NULL,
  pmid varchar(64) NULL,
  canonical_url varchar(1600) NULL,
  accessed_on date NULL,
  citation_status enum('RECORDED','ACCESSIBLE','SUPERSEDED','RETRACTED') NOT NULL DEFAULT 'RECORDED',
  note text NULL,
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(bibliography_id),
  UNIQUE KEY uq_ilb_bibliography_key(citation_key),
  UNIQUE KEY uq_ilb_bibliography_doi(doi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_bibliography_link (
  bibliography_link_id bigint unsigned NOT NULL AUTO_INCREMENT,
  bibliography_id bigint unsigned NOT NULL,
  cited_object_type enum('AATMN_POINT','AATMN_VERIFICATION','EQUATION','EQUATION_CASE','TEST_MAPPING','OTHER') NOT NULL,
  cited_object_key varchar(255) NOT NULL,
  evidence_role enum('SOURCE_TEXT','ANATOMY','PAIRING_RULE','EFFECT_CLAIM','FORMULA_DEFINITION','WORKED_EXAMPLE','OTHER') NOT NULL,
  locator_within_source varchar(1200) NULL,
  link_status enum('ACTIVE','SUPERSEDED') NOT NULL DEFAULT 'ACTIVE',
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(bibliography_link_id),
  UNIQUE KEY uq_ilb_bibliography_link(bibliography_id,cited_object_type,cited_object_key,evidence_role),
  KEY idx_ilb_bibliography_cited(cited_object_type,cited_object_key,evidence_role),
  CONSTRAINT fk_ilb_bibliography_link_entry FOREIGN KEY(bibliography_id)
    REFERENCES ilb_bibliography_entry(bibliography_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_bibliography_entry
(citation_key,source_class,title,author_or_organisation,publication_year,version_or_release,canonical_url,accessed_on,citation_status,note)
VALUES
('aatmn_parmar_sakshi_xlsx','PRIMARY_SOURCE','Sakshi.xlsx — Redikall point source collection','Aatmn Parmar',NULL,'provided workbook','https://drive.google.com/file/d/10yGqewPDDYLCLRqmITb_IJ8y9LT_HcWO',CURRENT_DATE,'ACCESSIBLE','Primary source for point code, stated location and stated foundation keyword only; not clinical-effect evidence.')
ON DUPLICATE KEY UPDATE title=VALUES(title),author_or_organisation=VALUES(author_or_organisation),
 version_or_release=VALUES(version_or_release),canonical_url=VALUES(canonical_url),accessed_on=VALUES(accessed_on),
 citation_status=VALUES(citation_status),note=VALUES(note);

INSERT INTO ilb_bibliography_link(bibliography_id,cited_object_type,cited_object_key,evidence_role,locator_within_source)
SELECT b.bibliography_id,'AATMN_POINT',CAST(p.point_id AS CHAR),'SOURCE_TEXT',CONCAT('point_code=',p.point_code)
FROM ilb_aatmn_parmar_point_source p
JOIN ilb_bibliography_entry b ON b.citation_key='aatmn_parmar_sakshi_xlsx'
ON DUPLICATE KEY UPDATE locator_within_source=VALUES(locator_within_source),link_status='ACTIVE';

CREATE OR REPLACE VIEW v_ilb_bibliography_coverage AS
SELECT 'AATMN_POINT' AS object_type,COUNT(*) AS objects_total,
       SUM(CASE WHEN x.cited_object_key IS NULL THEN 0 ELSE 1 END) AS objects_with_active_source
FROM ilb_aatmn_parmar_point_source p
LEFT JOIN (SELECT DISTINCT cited_object_key FROM ilb_bibliography_link
           WHERE cited_object_type='AATMN_POINT' AND evidence_role='SOURCE_TEXT' AND link_status='ACTIVE') x
  ON x.cited_object_key=CAST(p.point_id AS CHAR)
UNION ALL
SELECT 'EQUATION',COUNT(*),
       SUM(CASE WHEN x.cited_object_key IS NULL THEN 0 ELSE 1 END)
FROM ilb_equation_registry e
LEFT JOIN (SELECT DISTINCT cited_object_key FROM ilb_bibliography_link
           WHERE cited_object_type='EQUATION' AND evidence_role='FORMULA_DEFINITION' AND link_status='ACTIVE') x
  ON x.cited_object_key=CAST(e.equation_id AS CHAR);
COMMIT;