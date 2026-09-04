-- Phase 89: measurable psoriasis skin-state model and non-patient experiment gates.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_skin_state_variable (
 state_key char(1) NOT NULL,
 state_name varchar(100) NOT NULL,
 biological_definition text NOT NULL,
 desired_direction enum('DOWN','UP','NORMALISE') NOT NULL,
 source_url varchar(1000) NOT NULL,
 PRIMARY KEY(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_skin_state_observable (
 observable_key varchar(80) NOT NULL,
 state_key char(1) NOT NULL,
 observable_name varchar(160) NOT NULL,
 measurement_method varchar(160) NOT NULL,
 unit varchar(100) NULL,
 psoriasis_direction enum('UP','DOWN','ALTERED','CONTEXT_DEPENDENT') NOT NULL,
 specimen_model varchar(160) NOT NULL,
 evidence_scope enum('HUMAN_SKIN','3D_SKIN','HUMAN_AND_3D') NOT NULL,
 source_id varchar(80) NOT NULL,
 source_url varchar(1000) NOT NULL,
 universal_threshold_available tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(observable_key),
 KEY idx_p89_state(state_key),
 CONSTRAINT fk_p89_observable_state FOREIGN KEY(state_key) REFERENCES ilb_psoriasis_skin_state_variable(state_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE IF NOT EXISTS ilb_psoriasis_modification_gate (
 gate_order tinyint unsigned NOT NULL,
 gate_key varchar(80) NOT NULL,
 required_result text NOT NULL,
 failure_meaning text NOT NULL,
 patient_experiment tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(gate_key), UNIQUE KEY uq_p89_gate_order(gate_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_skin_state_variable VALUES
('P','KERATINOCYTE_PROLIFERATION','Rate or extent of proliferating epidermal keratinocytes.','DOWN','https://pmc.ncbi.nlm.nih.gov/articles/PMC8801538/'),
('D','KERATINOCYTE_DIFFERENTIATION','Completion and spatial organisation of the epidermal differentiation programme.','NORMALISE','https://pmc.ncbi.nlm.nih.gov/articles/PMC9062876/'),
('B','EPIDERMAL_BARRIER','Functional permeability and hydration barrier of the epidermis.','UP','https://pmc.ncbi.nlm.nih.gov/articles/PMC3346907/'),
('I','ACTIVE_INFLAMMATION','Active IL-17/IL-22-associated inflammatory signalling in skin.','DOWN','https://pmc.ncbi.nlm.nih.gov/articles/PMC10846593/'),
('R','RESIDENT_IMMUNE_MEMORY','Relapse-capable tissue-resident T-cell population and cytokine potential retained after clearance.','DOWN','https://pmc.ncbi.nlm.nih.gov/articles/PMC3962894/')
ON DUPLICATE KEY UPDATE state_name=VALUES(state_name),biological_definition=VALUES(biological_definition),desired_direction=VALUES(desired_direction),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_skin_state_observable VALUES
('P_MKI67','P','MKI67/Ki-67 positive basal keratinocytes','immunohistochemistry or transcript measurement',NULL,'UP','human skin or reconstructed epidermis','HUMAN_AND_3D','PMCID:PMC8801538','https://pmc.ncbi.nlm.nih.gov/articles/PMC8801538/',0),
('P_KRT16','P','KRT16 expression','immunostaining or transcript measurement',NULL,'UP','epidermis','HUMAN_SKIN','PMCID:PMC5674702','https://pmc.ncbi.nlm.nih.gov/articles/PMC5674702/',0),
('D_KRT10','D','KRT10 differentiation pattern','immunohistochemistry',NULL,'ALTERED','epidermis or 3D skin','HUMAN_AND_3D','PMID:20553063','https://pubmed.ncbi.nlm.nih.gov/20553063/',0),
('D_FLG','D','filaggrin expression and localisation','immunostaining or transcript measurement',NULL,'DOWN','human skin or keratinocytes','HUMAN_SKIN','PMCID:PMC8609659','https://pmc.ncbi.nlm.nih.gov/articles/PMC8609659/',0),
('D_LOR','D','loricrin expression and localisation','immunostaining or transcript measurement',NULL,'DOWN','human skin or keratinocytes','HUMAN_SKIN','PMCID:PMC8609659','https://pmc.ncbi.nlm.nih.gov/articles/PMC8609659/',0),
('B_TEWL','B','transepidermal water loss','closed- or open-chamber evaporimetry','g m^-2 h^-1','UP','human skin','HUMAN_SKIN','PMCID:PMC6536057','https://pmc.ncbi.nlm.nih.gov/articles/PMC6536057/',0),
('B_HYDRATION','B','stratum-corneum hydration','corneometry','instrument units','DOWN','human skin','HUMAN_SKIN','PMCID:PMC3346907','https://pmc.ncbi.nlm.nih.gov/articles/PMC3346907/',0),
('B_AQP3','B','AQP3 abundance and membrane localisation','immunofluorescence and immunoblot',NULL,'DOWN','human lesional and perilesional epidermis','HUMAN_SKIN','PMCID:PMC3346907','https://pmc.ncbi.nlm.nih.gov/articles/PMC3346907/',0),
('I_IL17A','I','IL-17A tissue signal','protein or transcript assay',NULL,'UP','human or cytokine-induced 3D skin','HUMAN_AND_3D','PMCID:PMC10846593','https://pmc.ncbi.nlm.nih.gov/articles/PMC10846593/',0),
('I_IL22','I','IL-22 tissue signal','protein or transcript assay',NULL,'UP','human or cytokine-induced 3D skin','HUMAN_AND_3D','PMCID:PMC10846593','https://pmc.ncbi.nlm.nih.gov/articles/PMC10846593/',0),
('R_TRM','R','CD69/CD103 tissue-resident T-cell phenotype','flow cytometry or immunostaining',NULL,'CONTEXT_DEPENDENT','clinically healed epidermis','HUMAN_SKIN','PMCID:PMC3962894','https://pmc.ncbi.nlm.nih.gov/articles/PMC3962894/',0),
('R_CYTOKINE_POTENTIAL','R','resident-cell IL-17/IL-22 production potential','ex vivo stimulation plus intracellular cytokine assay',NULL,'UP','clinically healed epidermis','HUMAN_SKIN','PMCID:PMC3962894','https://pmc.ncbi.nlm.nih.gov/articles/PMC3962894/',0)
ON DUPLICATE KEY UPDATE state_key=VALUES(state_key),observable_name=VALUES(observable_name),measurement_method=VALUES(measurement_method),unit=VALUES(unit),psoriasis_direction=VALUES(psoriasis_direction),specimen_model=VALUES(specimen_model),evidence_scope=VALUES(evidence_scope),source_id=VALUES(source_id),source_url=VALUES(source_url),universal_threshold_available=VALUES(universal_threshold_available);

INSERT INTO ilb_psoriasis_modification_gate VALUES
(1,'G1_PHENOTYPE','Psoriasis-like phenotype is reproducibly induced in a non-patient experimental system.','No valid disease model exists.',0),
(2,'G2_PROLIFERATION','P moves toward the matched healthy-control state.','Candidate does not correct hyperproliferation.',0),
(3,'G3_DIFFERENTIATION','D markers and epidermal layer organisation move toward matched healthy control.','Cell production changed without restoring normal maturation.',0),
(4,'G4_BARRIER','Barrier function improves using a functional measurement such as TEWL or permeability.','Appearance improved without functional barrier restoration.',0),
(5,'G5_INFLAMMATION','Active inflammatory observables decrease without nonspecific tissue destruction.','Inflammation persists or apparent benefit is toxic injury.',0),
(6,'G6_MEMORY','Resident-memory abundance or cytokine potential decreases in a memory-containing model.','Relapse-capable inflammatory memory remains.',0),
(7,'G7_WITHDRAWAL','After candidate removal, P,D,B and I remain in the healthy-control region for the prespecified observation window.','Temporary suppression, not demonstrated disease modification.',0),
(8,'G8_RECHALLENGE','After a prespecified inflammatory rechallenge, the model does not return to the psoriatic attractor more readily than healthy control.','The system remains relapse-prone.',0)
ON DUPLICATE KEY UPDATE gate_order=VALUES(gate_order),required_result=VALUES(required_result),failure_meaning=VALUES(failure_meaning),patient_experiment=VALUES(patient_experiment);
COMMIT;
