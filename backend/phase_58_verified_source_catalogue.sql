-- Phase 58: verified source catalogue from ILMB_Data_Delivery_Final_Manifest_2026-08-30.
START TRANSACTION;
CREATE TABLE IF NOT EXISTS ilb_source_dataset (
 source_dataset_id bigint unsigned NOT NULL AUTO_INCREMENT,
 source_name varchar(255) NOT NULL,
 source_release varchar(120) NOT NULL,
 retrieval_date date NOT NULL,
 authority_name varchar(255) NOT NULL,
 manifest_file_name varchar(255) NOT NULL,
 manifest_url varchar(1000) NOT NULL,
 licence_note varchar(1000) NULL,
 mapping_policy varchar(1000) NOT NULL,
 source_status enum('VERIFIED_MANIFEST','PENDING_IMPORT','REJECTED') NOT NULL DEFAULT 'VERIFIED_MANIFEST',
 PRIMARY KEY(source_dataset_id),
 UNIQUE KEY uq_ilb_source_dataset(source_name,source_release,manifest_file_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO ilb_source_dataset(source_name,source_release,retrieval_date,authority_name,manifest_file_name,manifest_url,licence_note,mapping_policy) VALUES
('LOINC','2.83','2026-08-30','Regenstrief Institute','Diagnostics_Laboratory_Mathematics_Enterprise_System_Full_LOINC_2.83.xlsx','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','LOINC License 5.8','Only explicit source identifiers'),
('Uberon','2026-06-19','2026-08-30','Uberon ontology release','ILMB_UBERON release workbooks','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Preserved release metadata','No name-only mappings'),
('Cell Ontology','2026-06-08','2026-08-30','Cell Ontology release','ILMB_CL release workbooks','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Preserved release metadata','No name-only mappings'),
('Gene Ontology','2026-07-26','2026-08-30','Gene Ontology release','ILMB_GO release workbooks','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Preserved release metadata','No name-only mappings'),
('Human Phenotype Ontology','2026-06-23','2026-08-30','Human Phenotype Ontology release','ILMB_HPO release workbooks','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Preserved release metadata','No name-only mappings'),
('IFCT and USDA FoodData Central','Workbook v1.5.1','2026-08-30','Source datasets preserved separately','Nutrition_Food_Medicine_Enterprise_v1.5.1_Complete_IFCT_USDA.xlsx','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Source-specific terms apply','Indian and USDA identities remain separate'),
('National List of Essential Medicines','Official All 384','2026-08-30','National List of Essential Medicines','Pharmaceutical_Illness_Medicine_Intelligence_System_NLEM_Official_All_384.xlsx','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','Government source','No inferred RxNorm or ChEBI equivalence'),
('LOINC Part File to ChEBI','LOINC 2.83','2026-08-30','Official LOINC PartRelatedCodeMapping','ILMB_Crosswalks_LOINC_CHEBI_2.83.xlsx','https://drive.google.com/file/d/1CEYhBBA5Rp5p0wIjG0zrkfBjRZaRnGWQ','LOINC and ChEBI terms apply','14,047 exact approved; no name matching')
ON DUPLICATE KEY UPDATE authority_name=VALUES(authority_name),manifest_url=VALUES(manifest_url),licence_note=VALUES(licence_note),mapping_policy=VALUES(mapping_policy),source_status=VALUES(source_status);
COMMIT;