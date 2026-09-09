-- ILoveMyBody Phase 106 split seed
-- Extracted verbatim from canonical Phase 106 migration artifact.

INSERT INTO ilb_psoriasis_differential(diff_id,psoriasis_context,differential_name,distinguishing_features,confirmatory_approach,source_url) VALUES
('DIF-001','Plaque psoriasis','Atopic/nummular eczema','Less sharply demarcated, more spongiosis/ooze; flexural pattern may differ','Clinical; biopsy if unclear','https://dermnetnz.org/topics/psoriasis'),
('DIF-002','Plaque psoriasis','Tinea corporis','Annular advancing border; fungal microscopy/culture when indicated','KOH/fungal testing if uncertain','https://dermnetnz.org/topics/psoriasis'),
('DIF-003','Scalp psoriasis','Seborrheic dermatitis','Greasy yellow scale vs more sharply demarcated psoriasiform scale; overlap can occur','Clinical ± biopsy rarely','https://dermnetnz.org/topics/psoriasis'),
('DIF-004','Guttate psoriasis','Pityriasis rosea','Herald patch/collarette scale and cleavage-line distribution','Clinical','https://dermnetnz.org/topics/psoriasis'),
('DIF-005','Guttate psoriasis','Pityriasis lichenoides chronica','Different lesion evolution/distribution','Clinical ± biopsy','https://dermnetnz.org/topics/psoriasis'),
('DIF-006','Guttate psoriasis','Secondary syphilis','Systemic/sexual history; palms/soles possible','Serology when indicated','https://dermnetnz.org/topics/psoriasis'),
('DIF-007','Inverse psoriasis','Candidal intertrigo','Satellite pustules, maceration; fungal evidence','KOH/culture if needed','https://dermnetnz.org/topics/psoriasis'),
('DIF-008','Inverse psoriasis','Tinea cruris','Advancing scaly border; asymmetry common','KOH/culture','https://dermnetnz.org/topics/psoriasis'),
('DIF-009','Inverse psoriasis','Erythrasma','Brown-red fold patches; coral-red Wood lamp fluorescence','Wood lamp','https://dermnetnz.org/topics/psoriasis'),
('DIF-010','Palmoplantar plaque psoriasis','Chronic hand/foot eczema','Spongiosis and exposure history; can overlap clinically','Clinical ± biopsy','https://dermnetnz.org/topics/psoriasis'),
('DIF-011','Palmoplantar disease','Tinea manuum/pedis','Fungal evidence; often asymmetric','KOH/culture','https://dermnetnz.org/topics/psoriasis'),
('DIF-012','Nail psoriasis','Onychomycosis','Fungal infection can mimic/coexist','Mycology before systemic antifungal therapy','https://dermnetnz.org/topics/psoriasis'),
('DIF-013','Nail psoriasis','Nail lichen planus','Longitudinal ridging, thinning, pterygium patterns','Clinical/dermatology','https://dermnetnz.org/topics/psoriasis'),
('DIF-014','GPP','Acute generalized exanthematous pustulosis (AGEP)','Drug-linked acute pustulosis; histology/clinical criteria differ','Urgent specialist + biopsy often useful','https://dermnetnz.org/topics/psoriasis'),
('DIF-015','GPP','Subcorneal pustular dermatosis','Chronic flaccid pustules; different histology/immunology','Dermatology/biopsy','https://dermnetnz.org/topics/psoriasis'),
('DIF-016','Erythrodermic psoriasis','Erythrodermic eczema / drug eruption / CTCL','History, morphology, systemic findings and biopsy','Urgent specialist work-up','https://dermnetnz.org/topics/psoriasis'),
('DIF-017','Genital psoriasis','Contact dermatitis','Exposure-linked irritation/eczema morphology','Clinical','https://dermnetnz.org/topics/psoriasis'),
('DIF-018','Genital psoriasis','Lichen sclerosus','Atrophic white plaques/scarring pattern','Specialist evaluation','https://dermnetnz.org/topics/psoriasis')
ON DUPLICATE KEY UPDATE psoriasis_context=VALUES(psoriasis_context),differential_name=VALUES(differential_name),distinguishing_features=VALUES(distinguishing_features),confirmatory_approach=VALUES(confirmatory_approach),source_url=VALUES(source_url);

INSERT INTO ilb_psoriasis_measurement_tool(measure_id,abbrev,name,domain_name,what_it_measures,range_text,reported_by,ilmb_rule,source_url) VALUES
('MEAS-PSO-001','PASI','Psoriasis Area and Severity Index','Plaque psoriasis','Composite erythema, induration, scale and regional area','0–72','Clinician','Core trial/clinical severity measure; less suitable alone for special sites.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-002','BSA','Body Surface Area','Cutaneous psoriasis','Percent body surface affected','0–100%','Clinician','Simple extent measure; high-impact sites can be severe despite low BSA.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-003','PGA/IGA','Physician/Investigator Global Assessment','General/plaque','Global lesion severity scale','Scale varies by instrument','Clinician','Instrument version must be stored.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-004','DLQI','Dermatology Life Quality Index','Adult skin disease','Quality-of-life impact','0–30','Patient','Important for high-impact sites.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-005','NAPSI','Nail Psoriasis Severity Index','Nails','Matrix + nail-bed signs by quadrants','Instrument-dependent total','Clinician','Dedicated nail measure.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-006','PSSI','Psoriasis Scalp Severity Index','Scalp','Scalp erythema, infiltration, scaling and area','Instrument-specific','Clinician','Useful for scalp disease.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-007','PPPASI','Palmoplantar Pustular Psoriasis Area and Severity Index','Palmoplantar pustular disease','Site-specific area/severity','Instrument-specific','Clinician','Use only with documented instrument definition.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-008','GPPGA/GPPPGA','Generalized Pustular Psoriasis Physician Global Assessment','GPP','Global disease and pustulation severity','Instrument-specific','Clinician','Used in GPP studies; pustulation subscore may be reported.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-009','PEST','Psoriasis Epidemiology Screening Tool','PsA screening','Five-item PsA screening questionnaire','0–5','Patient','Screening, not diagnosis.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-010','Itch NRS','Numeric rating scale','Symptoms','Patient-rated itch intensity','typically 0–10','Patient','Store anchors and time window.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-011','Pain NRS','Numeric rating scale','Symptoms','Patient-rated pain','typically 0–10','Patient','Especially relevant in fissures, genital, GPP.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis'),
('MEAS-PSO-012','Standardized lesion photography','Imaging','Any visible lesion','Consistent lighting/distance/body site','N/A','Imaging','Useful longitudinally; not a substitute for clinical review.','https://www.aad.org/member/clinical-quality/guidelines/psoriasis')
ON DUPLICATE KEY UPDATE abbrev=VALUES(abbrev),name=VALUES(name),what_it_measures=VALUES(what_it_measures),ilmb_rule=VALUES(ilmb_rule),source_url=VALUES(source_url);
