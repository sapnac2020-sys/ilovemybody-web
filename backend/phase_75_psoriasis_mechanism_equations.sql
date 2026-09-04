-- Phase 75: governed psoriasis IL-23/IL-17 mechanism and side-effect graph.
-- Symbolic mechanistic equations only; numerical execution is gated by sourced parameters.
START TRANSACTION;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_mechanism_node (
 node_key varchar(100) NOT NULL,
 node_type enum('DRUG','CELL','CYTOKINE','RECEPTOR','ADAPTOR','SIGNAL','TISSUE_PROCESS','CLINICAL_STATE','NORMAL_FUNCTION','ADVERSE_EVENT','INPUT') NOT NULL,
 label varchar(240) NOT NULL,
 external_system varchar(80) DEFAULT NULL,
 external_id varchar(120) DEFAULT NULL,
 compartment varchar(180) NOT NULL,
 source_url varchar(1000) NOT NULL,
 identity_status enum('EXACT','PATHWAY_LEVEL','UNRESOLVED') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 status enum('active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(node_key),
 UNIQUE KEY uq_p75_external(external_system,external_id,node_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_mechanism_edge (
 edge_key varchar(120) NOT NULL,
 source_node_key varchar(100) NOT NULL,
 predicate enum('ACTIVATES','PRODUCES','BINDS','RECRUITS','AMPLIFIES','DRIVES','REDUCES','SUPPORTS','ASSOCIATED_WITH') NOT NULL,
 target_node_key varchar(100) NOT NULL,
 polarity tinyint NOT NULL,
 equation_term varchar(500) NOT NULL,
 evidence_url varchar(1000) NOT NULL,
 evidence_status enum('CURATED_PATHWAY','REGULATORY_LABEL','PEER_REVIEWED','HYPOTHESIS') NOT NULL,
 computation_eligible tinyint(1) NOT NULL DEFAULT 0,
 decision_note varchar(1600) NOT NULL,
 status enum('active','retired') NOT NULL DEFAULT 'active',
 PRIMARY KEY(edge_key),
 KEY idx_p75_source(source_node_key),
 KEY idx_p75_target(target_node_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ilb_psoriasis_system_equation (
 equation_key varchar(100) NOT NULL,
 state_variable varchar(100) NOT NULL,
 equation_text varchar(3000) NOT NULL,
 required_parameters varchar(2400) NOT NULL,
 interpretation_text varchar(1800) NOT NULL,
 source_url varchar(1000) NOT NULL,
 validation_status enum('IDENTITY','MODEL_STRUCTURE','EXECUTABLE','BLOCKED') NOT NULL,
 PRIMARY KEY(equation_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO ilb_psoriasis_mechanism_node
(node_key,node_type,label,external_system,external_id,compartment,source_url,identity_status,computation_eligible,status) VALUES
('IXEKIZUMAB','DRUG','Ixekizumab','RXNORM','1745099','systemic/extracellular','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','EXACT',1,'active'),
('DENDRITIC_CELL','CELL','Activated dendritic cell','CL','CL:0000451','skin/lymphoid interface','https://pubmed.ncbi.nlm.nih.gov/23291100/','EXACT',1,'active'),
('IL23','CYTOKINE','Interleukin-23',NULL,NULL,'extracellular','https://pubmed.ncbi.nlm.nih.gov/23291100/','UNRESOLVED',1,'active'),
('TH17','CELL','T helper 17 cell','CL','CL:0000899','skin/immune compartment','https://pubmed.ncbi.nlm.nih.gov/23291100/','EXACT',1,'active'),
('IL17A','CYTOKINE','Interleukin-17A','UNIPROT','Q16552','extracellular','https://www.uniprot.org/uniprotkb/Q16552/entry','EXACT',1,'active'),
('IL17_RECEPTOR','RECEPTOR','IL17RA/IL17RC receptor complex','REACTOME','R-HSA-447246','plasma membrane','https://reactome.org/content/detail/R-HSA-447246','PATHWAY_LEVEL',1,'active'),
('TRAF3IP2','ADAPTOR','TRAF3IP2 / ACT1','REACTOME','R-HSA-8951104','cytosol/plasma membrane','https://reactome.org/content/detail/R-HSA-8951104','PATHWAY_LEVEL',1,'active'),
('TRAF6','ADAPTOR','TRAF6-containing receptor complex','REACTOME','R-HSA-8980293','cytosol/plasma membrane','https://reactome.org/content/detail/R-HSA-8980293','PATHWAY_LEVEL',1,'active'),
('IL17_SIGNAL','SIGNAL','IL-17 signalling','REACTOME','R-HSA-448424','cellular','https://reactome.org/content/detail/R-HSA-448424','EXACT',1,'active'),
('KERATINOCYTE_RESPONSE','TISSUE_PROCESS','Activated keratinocyte response',NULL,NULL,'epidermis','https://pubmed.ncbi.nlm.nih.gov/23291100/','UNRESOLVED',1,'active'),
('PSORIASIS_PLAQUE','CLINICAL_STATE','Psoriatic plaque burden',NULL,NULL,'skin','https://pubmed.ncbi.nlm.nih.gov/27883001/','UNRESOLVED',1,'active'),
('ANTIMICROBIAL_DEFENCE','NORMAL_FUNCTION','IL-17-supported antimicrobial defence',NULL,NULL,'barrier tissues','https://www.uniprot.org/uniprotkb/Q16552/entry','UNRESOLVED',0,'active'),
('INFECTION_EVENT','ADVERSE_EVENT','Serious or opportunistic infection',NULL,NULL,'systemic','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','UNRESOLVED',0,'active'),
('IBD_EVENT','ADVERSE_EVENT','Inflammatory bowel disease event',NULL,NULL,'gastrointestinal tract','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','UNRESOLVED',0,'active'),
('PH_COMPARTMENT','INPUT','Compartment-specific hydrogen ion activity','CHEBI','CHEBI:15378','declared measured compartment','https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:15378','EXACT',1,'active'),
('AUTONOMIC_INPUT','INPUT','Measured autonomic or neuroimmune input',NULL,NULL,'declared nervous-system compartment','https://pubmed.ncbi.nlm.nih.gov/41428266/','UNRESOLVED',0,'active')
ON DUPLICATE KEY UPDATE label=VALUES(label),external_system=VALUES(external_system),external_id=VALUES(external_id),compartment=VALUES(compartment),source_url=VALUES(source_url),identity_status=VALUES(identity_status),computation_eligible=VALUES(computation_eligible),status=VALUES(status);

INSERT INTO ilb_psoriasis_mechanism_edge
(edge_key,source_node_key,predicate,target_node_key,polarity,equation_term,evidence_url,evidence_status,computation_eligible,decision_note,status) VALUES
('DC_PRODUCES_IL23','DENDRITIC_CELL','PRODUCES','IL23',1,'+k_DC_IL23*DC','https://pubmed.ncbi.nlm.nih.gov/23291100/','PEER_REVIEWED',1,'IL-23/T17 axis structure.','active'),
('IL23_ACTIVATES_TH17','IL23','ACTIVATES','TH17',1,'+k_IL23_TH17*IL23','https://pubmed.ncbi.nlm.nih.gov/23291100/','PEER_REVIEWED',1,'IL-23 sustains pathogenic type-17 responses.','active'),
('TH17_PRODUCES_IL17A','TH17','PRODUCES','IL17A',1,'+k_TH17_IL17A*TH17','https://pubmed.ncbi.nlm.nih.gov/23291100/','PEER_REVIEWED',1,'Type-17 cell cytokine production.','active'),
('IL17A_BINDS_RECEPTOR','IL17A','BINDS','IL17_RECEPTOR',1,'+kon_R*IL17A*R-koff_R*IL17R_COMPLEX','https://reactome.org/content/detail/R-HSA-447246','CURATED_PATHWAY',1,'Curated receptor-binding event.','active'),
('RECEPTOR_RECRUITS_ACT1','IL17_RECEPTOR','RECRUITS','TRAF3IP2',1,'+k_R_ACT1*IL17R_COMPLEX','https://reactome.org/content/detail/R-HSA-8951104','CURATED_PATHWAY',1,'ACT1/TRAF3IP2 recruitment.','active'),
('ACT1_RECRUITS_TRAF6','TRAF3IP2','RECRUITS','TRAF6',1,'+k_ACT1_TRAF6*ACT1_COMPLEX','https://reactome.org/content/detail/R-HSA-8980293','CURATED_PATHWAY',1,'TRAF6 recruitment.','active'),
('TRAF6_DRIVES_SIGNAL','TRAF6','DRIVES','IL17_SIGNAL',1,'+k_TRAF6_SIGNAL*TRAF6_COMPLEX','https://reactome.org/content/detail/R-HSA-448424','CURATED_PATHWAY',1,'Curated IL-17 signal chain.','active'),
('SIGNAL_DRIVES_KC','IL17_SIGNAL','DRIVES','KERATINOCYTE_RESPONSE',1,'+k_SIGNAL_KC*IL17_SIGNAL','https://pubmed.ncbi.nlm.nih.gov/23291100/','PEER_REVIEWED',1,'Keratinocyte response amplifies the pathogenic axis.','active'),
('KC_DRIVES_PLAQUE','KERATINOCYTE_RESPONSE','DRIVES','PSORIASIS_PLAQUE',1,'+k_KC_PLAQUE*KC','https://pubmed.ncbi.nlm.nih.gov/27883001/','PEER_REVIEWED',1,'Links epidermal response to clinical plaque burden.','active'),
('KC_AMPLIFIES_AXIS','KERATINOCYTE_RESPONSE','AMPLIFIES','DENDRITIC_CELL',1,'+k_feedback*KC','https://pubmed.ncbi.nlm.nih.gov/23291100/','PEER_REVIEWED',1,'Positive feedback closes the disease loop.','active'),
('IXE_BINDS_IL17A','IXEKIZUMAB','BINDS','IL17A',-1,'-kon_D*D*IL17A+koff_D*D_IL17A','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','REGULATORY_LABEL',1,'Drug removes free signalling-available IL-17A through binding.','active'),
('IL17_SUPPORTS_DEFENCE','IL17A','SUPPORTS','ANTIMICROBIAL_DEFENCE',1,'+k_defence*IL17A_free','https://www.uniprot.org/uniprotkb/Q16552/entry','PEER_REVIEWED',0,'Normal-function edge; requires a defined assay before computation.','active'),
('IXE_ASSOC_INFECTION','IXEKIZUMAB','ASSOCIATED_WITH','INFECTION_EVENT',1,'risk_infection|exposure','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','REGULATORY_LABEL',0,'Regulatory safety association; not an individual prediction equation.','active'),
('IXE_ASSOC_IBD','IXEKIZUMAB','ASSOCIATED_WITH','IBD_EVENT',1,'risk_IBD|exposure','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','REGULATORY_LABEL',0,'Regulatory safety association; not an individual prediction equation.','active'),
('AUTONOMIC_AXIS_HYPOTHESIS','AUTONOMIC_INPUT','ASSOCIATED_WITH','DENDRITIC_CELL',0,'beta_neuroimmune*N(t)','https://pubmed.ncbi.nlm.nih.gov/41428266/','HYPOTHESIS',0,'Research connector; polarity and coefficient require direct measurement.','active'),
('PH_KC_HYPOTHESIS','PH_COMPARTMENT','ASSOCIATED_WITH','KERATINOCYTE_RESPONSE',0,'beta_pH*(pH-pH_ref)','https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:15378','HYPOTHESIS',0,'Hydrogen activity is exact; psoriasis direction and coefficient require compartment-specific evidence.','active')
ON DUPLICATE KEY UPDATE source_node_key=VALUES(source_node_key),predicate=VALUES(predicate),target_node_key=VALUES(target_node_key),polarity=VALUES(polarity),equation_term=VALUES(equation_term),evidence_url=VALUES(evidence_url),evidence_status=VALUES(evidence_status),computation_eligible=VALUES(computation_eligible),decision_note=VALUES(decision_note),status=VALUES(status);

INSERT INTO ilb_psoriasis_system_equation VALUES
('FREE_IL17A','IL17A_free','IL17A_free = IL17A_total - D_IL17A_complex','IL17A_total,D_IL17A_complex in compatible concentration units','Available ligand after drug binding.','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','IDENTITY'),
('DRUG_TARGET_BINDING','D_IL17A_complex','d[D_IL17A]/dt = kon_D*[D]*[IL17A_free] - koff_D*[D_IL17A]','kon_D,koff_D,free drug,free IL17A,complex,assay context','Mass-action ixekizumab/IL-17A binding structure.','https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ac96658a-d7dc-4c7c-8928-2adcdf4318b2','MODEL_STRUCTURE'),
('IL23_STATE','IL23','dIL23/dt = k_DC_IL23*DC - mu_IL23*IL23','DC,k_DC_IL23,mu_IL23','IL-23 production minus removal.','https://pubmed.ncbi.nlm.nih.gov/23291100/','MODEL_STRUCTURE'),
('TH17_STATE','TH17','dTH17/dt = k_IL23_TH17*IL23 - mu_TH17*TH17','IL23,k_IL23_TH17,mu_TH17','Type-17 activation minus resolution.','https://pubmed.ncbi.nlm.nih.gov/23291100/','MODEL_STRUCTURE'),
('IL17A_STATE','IL17A_free','dIL17A_free/dt = k_TH17_IL17A*TH17 - mu_IL17A*IL17A_free - kon_D*D*IL17A_free + koff_D*D_IL17A','TH17,drug,complex,k_TH17_IL17A,mu_IL17A,kon_D,koff_D','Production, natural removal and reversible drug binding.','https://pubmed.ncbi.nlm.nih.gov/23291100/','MODEL_STRUCTURE'),
('KERATINOCYTE_STATE','KC','dKC/dt = k_SIGNAL_KC*IL17_SIGNAL - mu_KC*(KC-KC_0)','IL17_SIGNAL,k_SIGNAL_KC,mu_KC,KC_0','Activated epidermal response minus return toward baseline.','https://pubmed.ncbi.nlm.nih.gov/23291100/','MODEL_STRUCTURE'),
('PLAQUE_STATE','P','dP/dt = k_KC_PLAQUE*KC - mu_P*P','KC,k_KC_PLAQUE,mu_P','Plaque formation minus clinical resolution.','https://pubmed.ncbi.nlm.nih.gov/27883001/','MODEL_STRUCTURE'),
('PH_IDENTITY','pH','pH = -log10(a_H+)','Measured hydrogen-ion activity in a declared compartment, method, temperature and time','Compartment-specific pH; no cross-compartment substitution.','https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:15378','IDENTITY')
ON DUPLICATE KEY UPDATE state_variable=VALUES(state_variable),equation_text=VALUES(equation_text),required_parameters=VALUES(required_parameters),interpretation_text=VALUES(interpretation_text),source_url=VALUES(source_url),validation_status=VALUES(validation_status);

CREATE OR REPLACE VIEW v_ilmb_psoriasis_mechanism_path AS
SELECT e.edge_key,s.label source_label,e.predicate,t.label target_label,e.polarity,
 e.equation_term,e.evidence_status,e.computation_eligible,e.decision_note
FROM ilb_psoriasis_mechanism_edge e
JOIN ilb_psoriasis_mechanism_node s ON s.node_key=e.source_node_key
JOIN ilb_psoriasis_mechanism_node t ON t.node_key=e.target_node_key
WHERE e.status='active' AND s.status='active' AND t.status='active';

CREATE OR REPLACE VIEW v_ilmb_psoriasis_mechanism_readiness AS
SELECT
 (SELECT COUNT(*) FROM ilb_psoriasis_mechanism_node WHERE status='active') active_nodes,
 (SELECT COUNT(*) FROM ilb_psoriasis_mechanism_edge WHERE status='active') active_edges,
 (SELECT COUNT(*) FROM ilb_psoriasis_mechanism_edge WHERE status='active' AND computation_eligible=1) computable_edges,
 (SELECT COUNT(*) FROM ilb_psoriasis_mechanism_edge WHERE status='active' AND evidence_status='HYPOTHESIS') hypothesis_edges,
 (SELECT COUNT(*) FROM ilb_psoriasis_system_equation WHERE validation_status='IDENTITY') identity_equations,
 (SELECT COUNT(*) FROM ilb_psoriasis_system_equation WHERE validation_status='MODEL_STRUCTURE') model_structure_equations,
 CASE WHEN
  (SELECT COUNT(*) FROM ilb_psoriasis_mechanism_edge WHERE edge_key IN
   ('DC_PRODUCES_IL23','IL23_ACTIVATES_TH17','TH17_PRODUCES_IL17A','IL17A_BINDS_RECEPTOR',
    'RECEPTOR_RECRUITS_ACT1','ACT1_RECRUITS_TRAF6','TRAF6_DRIVES_SIGNAL','SIGNAL_DRIVES_KC',
    'KC_DRIVES_PLAQUE','KC_AMPLIFIES_AXIS','IXE_BINDS_IL17A') AND computation_eligible=1)=11
 THEN 1 ELSE 0 END AS end_to_end_structure_ready,
 CASE WHEN
  (SELECT COUNT(*) FROM ilb_ixekizumab_parameter WHERE verification_status='MISSING')=0
 THEN 1 ELSE 0 END AS numerical_patient_execution_ready;

COMMIT;
