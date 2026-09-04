-- Phase 91: resolve B and R directional-evidence gaps without promoting to cure.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_candidate_state_source (
 candidate_key varchar(80) NOT NULL,
 state_key char(1) NOT NULL,
 source_id varchar(80) NOT NULL,
 source_url varchar(1000) NOT NULL,
 evidence_model enum('HUMAN','3D_SKIN','ANIMAL') NOT NULL,
 measured_result text NOT NULL,
 limitation text NOT NULL,
 PRIMARY KEY(candidate_key,state_key,source_id),
 CONSTRAINT fk_p91_candidate FOREIGN KEY(candidate_key) REFERENCES ilb_psoriasis_candidate(candidate_key),
 CONSTRAINT fk_p91_state FOREIGN KEY(state_key) REFERENCES ilb_psoriasis_skin_state_variable(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_candidate(candidate_key,candidate_name,domain,evidence_model,combination_context,source_id,source_url) VALUES
('SECUKINUMAB_IL17','secukinumab / IL-17A blockade','PHARMACEUTICAL','HUMAN',NULL,'PMID:32199992','https://pubmed.ncbi.nlm.nih.gov/32199992/'),
('CALCIPOTRIOL_VDR','calcipotriol / vitamin-D-receptor agonism','PHARMACEUTICAL','HUMAN',NULL,'PMID:25904071','https://pubmed.ncbi.nlm.nih.gov/25904071/')
ON DUPLICATE KEY UPDATE candidate_name=VALUES(candidate_name),domain=VALUES(domain),evidence_model=VALUES(evidence_model),source_id=VALUES(source_id),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_candidate_state_source VALUES
('GUSELKUMAB_IL23','B','PMID:38992724','https://pubmed.ncbi.nlm.nih.gov/38992724/','HUMAN','Randomized controlled trial reported normalization of the stratum-corneum ceramide profile and alleviation of barrier dysfunction.','Directional treatment evidence; persistence after withdrawal was not established.'),
('GUSELKUMAB_IL23','R','PMID:33524368','https://pubmed.ncbi.nlm.nih.gov/33524368/','HUMAN','Guselkumab reduced measured memory T-cell populations in psoriatic skin while maintaining regulatory T cells.','Reduction is not elimination; IL-17A/IL-17F-positive T-cell frequencies were not modified, and withdrawal/rechallenge were not tested.'),
('SECUKINUMAB_IL17','R','PMID:32199992','https://pubmed.ncbi.nlm.nih.gov/32199992/','HUMAN','Pathogenic migratory and resident T-cell infiltration decreased during secukinumab treatment.','On-treatment reduction does not demonstrate durable removal after withdrawal.'),
('CALCIPOTRIOL_VDR','R','PMID:25904071','https://pubmed.ncbi.nlm.nih.gov/25904071/','HUMAN','Frequency of CD8-positive IL-17-positive T cells decreased in treated psoriasis lesions.','The study did not establish that measured cells were eliminated resident-memory cells or that the change persisted after withdrawal.')
ON DUPLICATE KEY UPDATE source_url=VALUES(source_url),evidence_model=VALUES(evidence_model),measured_result=VALUES(measured_result),limitation=VALUES(limitation);

UPDATE ilb_psoriasis_candidate_state_evidence SET evidence_status='SUPPORTED_DIRECTION',observed_result='Randomized human evidence reports ceramide-profile normalization and alleviated barrier dysfunction.',direct_state_measurement=1,withdrawal_tested=0,rechallenge_tested=0 WHERE candidate_key='GUSELKUMAB_IL23' AND state_key='B';
UPDATE ilb_psoriasis_candidate_state_evidence SET evidence_status='SUPPORTED_DIRECTION',observed_result='Human lesional flow-cytometry evidence reports reduced memory T-cell populations; cytokine-positive frequencies persisted.',direct_state_measurement=1,withdrawal_tested=0,rechallenge_tested=0 WHERE candidate_key='GUSELKUMAB_IL23' AND state_key='R';
INSERT INTO ilb_psoriasis_candidate_state_evidence(candidate_key,state_key,evidence_status,observed_result,direct_state_measurement,withdrawal_tested,rechallenge_tested) VALUES
('SECUKINUMAB_IL17','P','NOT_MEASURED',NULL,0,0,0),('SECUKINUMAB_IL17','D','NOT_MEASURED',NULL,0,0,0),('SECUKINUMAB_IL17','B','NOT_MEASURED',NULL,0,0,0),('SECUKINUMAB_IL17','I','SUPPORTED_DIRECTION','IL-17A pathway blockade reduced active inflammatory disease.',1,0,0),('SECUKINUMAB_IL17','R','SUPPORTED_DIRECTION','Human skin study reported decreased pathogenic migratory and resident T-cell infiltration during treatment.',1,0,0),
('CALCIPOTRIOL_VDR','P','NOT_ESTABLISHED','Histological improvement reported; no universal proliferation threshold registered.',0,0,0),('CALCIPOTRIOL_VDR','D','NOT_ESTABLISHED','Differentiation effects were not sufficient for a withdrawal-stable state claim.',0,0,0),('CALCIPOTRIOL_VDR','B','NOT_MEASURED',NULL,0,0,0),('CALCIPOTRIOL_VDR','I','SUPPORTED_DIRECTION','Frequency of CD8-positive IL-17-positive cells decreased in treated lesions.',1,0,0),('CALCIPOTRIOL_VDR','R','NOT_ESTABLISHED','The measured CD8-positive IL-17-positive population was not established as eliminated resident memory.',0,0,0)
ON DUPLICATE KEY UPDATE evidence_status=VALUES(evidence_status),observed_result=VALUES(observed_result),direct_state_measurement=VALUES(direct_state_measurement),withdrawal_tested=VALUES(withdrawal_tested),rechallenge_tested=VALUES(rechallenge_tested);
COMMIT;
