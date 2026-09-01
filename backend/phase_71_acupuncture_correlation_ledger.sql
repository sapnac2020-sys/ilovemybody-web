-- Phase 71: reproducible acupuncture-coordinate crosswalk.
-- WHO 2008 provides point-location standardisation. It is not evidence for any clinical outcome.
START TRANSACTION;

INSERT INTO ilb_bibliography_entry
(citation_key,source_class,title,author_or_organisation,version_or_release,canonical_url,accessed_on,citation_status,note)
VALUES
('who_acupuncture_point_locations_wpr_2008','STANDARD','WHO Standard Acupuncture Point Locations in the Western Pacific Region','World Health Organization, Western Pacific Region','2008','https://iris.who.int/items/f188654a-d8a7-4519-9979-8e2de713c060',CURRENT_DATE,'ACCESSIBLE','Location/nomenclature standard for 361 acupuncture points. A location standard does not establish an Aatmn correspondence, physiological mechanism, clinical effect, or formula.')
ON DUPLICATE KEY UPDATE title=VALUES(title),author_or_organisation=VALUES(author_or_organisation),
 version_or_release=VALUES(version_or_release),canonical_url=VALUES(canonical_url),
 accessed_on=VALUES(accessed_on),citation_status='ACCESSIBLE',note=VALUES(note);

CREATE TABLE IF NOT EXISTS ilb_aatmn_acupuncture_crosswalk (
  crosswalk_id bigint unsigned NOT NULL AUTO_INCREMENT,
  point_id bigint unsigned NOT NULL,
  acupuncture_point_id bigint unsigned NOT NULL,
  relation_type enum('EXACT_LOCATION','OVERLAPPING_LOCATION','NEARBY_LOCATION','NO_LOCATION_MATCH','UNRESOLVED') NOT NULL,
  match_method enum('LANDMARK_COMPARISON','MEASUREMENT_COMPARISON','COORDINATE_COMPARISON','EXPERT_REVIEW') NOT NULL,
  aatmn_location_excerpt text NULL,
  comparison_note text NOT NULL,
  source_bibliography_id bigint unsigned NOT NULL,
  review_status enum('CANDIDATE','LOCATION_VERIFIED','REJECTED') NOT NULL DEFAULT 'CANDIDATE',
  reviewed_at datetime(6) NULL,
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(crosswalk_id),
  UNIQUE KEY uq_ilb_aatmn_acupuncture_crosswalk (point_id,acupuncture_point_id),
  KEY ix_ilb_aatmn_acupuncture_review (review_status,relation_type),
  CONSTRAINT fk_ilb_aatmn_acupuncture_point FOREIGN KEY(point_id)
    REFERENCES ilb_aatmn_parmar_point_source(point_id),
  CONSTRAINT fk_ilb_aatmn_acupuncture_standard FOREIGN KEY(acupuncture_point_id)
    REFERENCES ilb_acupuncture_point(point_id),
  CONSTRAINT fk_ilb_aatmn_acupuncture_bibliography FOREIGN KEY(source_bibliography_id)
    REFERENCES ilb_bibliography_entry(bibliography_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_aatmn_formula_hypothesis (
  hypothesis_id bigint unsigned NOT NULL AUTO_INCREMENT,
  point_id bigint unsigned NOT NULL,
  crosswalk_id bigint unsigned NULL,
  proposed_input varchar(500) NOT NULL,
  proposed_output varchar(500) NOT NULL,
  biological_pathway_text text NULL,
  mathematical_expression text NULL,
  source_bibliography_id bigint unsigned NULL,
  evidence_state enum('NO_CROSSWALK','LOCATION_ONLY','MECHANISM_PENDING','OUTCOME_PENDING','VERIFIED') NOT NULL DEFAULT 'NO_CROSSWALK',
  created_at datetime(6) NOT NULL DEFAULT current_timestamp(6),
  PRIMARY KEY(hypothesis_id),
  KEY ix_ilb_aatmn_formula_state (evidence_state),
  CONSTRAINT fk_ilb_aatmn_formula_point FOREIGN KEY(point_id)
    REFERENCES ilb_aatmn_parmar_point_source(point_id),
  CONSTRAINT fk_ilb_aatmn_formula_crosswalk FOREIGN KEY(crosswalk_id)
    REFERENCES ilb_aatmn_acupuncture_crosswalk(crosswalk_id),
  CONSTRAINT fk_ilb_aatmn_formula_bibliography FOREIGN KEY(source_bibliography_id)
    REFERENCES ilb_bibliography_entry(bibliography_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_bibliography_link(bibliography_id,cited_object_type,cited_object_key,evidence_role,locator_within_source)
SELECT bibliography_id,'OTHER','ilb_acupuncture_point','LOCATION','WHO 2008 standard; canonical location basis for the existing 361-point ILMB acupuncture dataset'
FROM ilb_bibliography_entry WHERE citation_key='who_acupuncture_point_locations_wpr_2008'
ON DUPLICATE KEY UPDATE locator_within_source=VALUES(locator_within_source),link_status='ACTIVE';

COMMIT;
