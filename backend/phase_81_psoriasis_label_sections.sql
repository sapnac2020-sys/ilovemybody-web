-- Phase 81: exact text sections extracted from registered DailyMed SPL XML.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_regulatory_label_section (
 agent_key varchar(80) NOT NULL,
 set_id char(36) NOT NULL,
 section_code varchar(20) NOT NULL,
 section_name varchar(240) NOT NULL,
 section_text longtext NOT NULL,
 section_sha256 char(64) NOT NULL,
 source_xml_url varchar(1000) NOT NULL,
 extraction_status enum('SOURCE_EXACT_TEXT','EMPTY_REJECTED','REVIEW_REQUIRED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 extracted_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(agent_key,set_id,section_code),
 KEY idx_p81_section_code(section_code),
 KEY idx_p81_section_sha(section_sha256)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE OR REPLACE VIEW v_ilmb_psoriasis_label_section_coverage AS
SELECT a.agent_key,r.section_code,r.section_name,
 COUNT(s.set_id) source_label_count,
 COUNT(DISTINCT s.section_sha256) distinct_text_count,
 CASE WHEN COUNT(s.set_id)>0 THEN 'SOURCE_TEXT_AVAILABLE' ELSE 'MISSING' END coverage_status
FROM ilb_psoriasis_pharma_agent a
CROSS JOIN ilb_psoriasis_label_section_requirement r
LEFT JOIN ilb_psoriasis_regulatory_label_section s ON s.agent_key=a.agent_key AND s.section_code=r.section_code AND s.extraction_status='SOURCE_EXACT_TEXT'
GROUP BY a.agent_key,r.section_code,r.section_name;
COMMIT;
