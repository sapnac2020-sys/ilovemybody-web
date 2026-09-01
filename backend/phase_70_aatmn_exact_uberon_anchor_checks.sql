-- Phase 70: connect only exact UBERON-coded anatomy anchors to the Aatmn review.
-- These are anatomical-anchor checks, not proof of a chakra point or claimed effect.
START TRANSACTION;

INSERT INTO ilb_bibliography_entry
(citation_key,source_class,title,author_or_organisation,version_or_release,canonical_url,accessed_on,citation_status,note)
VALUES
('uberon_terms_2026_06_19','ONTOLOGY','ILMB_UBERON_01_Terms_Release_2026-06-19.xlsx','Uberon ontology','2026-06-19','https://docs.google.com/spreadsheets/d/1zPIgPRdkU3y7RboPI1OLWEBONux1XFFq/edit',CURRENT_DATE,'ACCESSIBLE','Approved ILMB master-manifest anatomy source. Exact UBERON identifier required; term presence does not establish an Aatmn point or biological effect.')
ON DUPLICATE KEY UPDATE title=VALUES(title),version_or_release=VALUES(version_or_release),
 canonical_url=VALUES(canonical_url),accessed_on=VALUES(accessed_on),citation_status='ACCESSIBLE',note=VALUES(note);

CREATE TABLE IF NOT EXISTS ilb_aatmn_uberon_anchor_check (
  candidate_id bigint unsigned NOT NULL,
  uberon_id varchar(120) NOT NULL,
  anchor_name varchar(500) NOT NULL,
  term_match_status enum('EXACT_UBERON_IDENTIFIER') NOT NULL,
  point_location_status enum('ANCHOR_ONLY_NOT_POINT_VERIFICATION') NOT NULL DEFAULT 'ANCHOR_ONLY_NOT_POINT_VERIFICATION',
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(candidate_id),
  CONSTRAINT fk_ilb_aatmn_uberon_check_candidate FOREIGN KEY(candidate_id)
    REFERENCES ilb_aatmn_anatomy_candidate(candidate_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_aatmn_uberon_anchor_check(candidate_id,uberon_id,anchor_name,term_match_status)
SELECT candidate_id,anatomy_code,anatomy_name,'EXACT_UBERON_IDENTIFIER'
FROM ilb_aatmn_anatomy_candidate
WHERE anatomy_code REGEXP '^UBERON:[0-9]+$'
ON DUPLICATE KEY UPDATE uberon_id=VALUES(uberon_id),anchor_name=VALUES(anchor_name);

INSERT INTO ilb_bibliography_link(bibliography_id,cited_object_type,cited_object_key,evidence_role,locator_within_source)
SELECT b.bibliography_id,'OTHER',CAST(x.candidate_id AS CHAR),'ANATOMY',CONCAT(x.uberon_id,' | ',x.anchor_name)
FROM ilb_aatmn_uberon_anchor_check x
JOIN ilb_bibliography_entry b ON b.citation_key='uberon_terms_2026_06_19'
ON DUPLICATE KEY UPDATE locator_within_source=VALUES(locator_within_source),link_status='ACTIVE';

COMMIT;