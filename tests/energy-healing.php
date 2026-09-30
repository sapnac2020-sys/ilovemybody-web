<?php
declare(strict_types=1);
$p=new PDO('mysql:host=127.0.0.1;dbname=ehr_test;charset=utf8mb4','root','ci-only-password',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
function runSql(PDO $p,string $path): void {$s=$p->query(file_get_contents($path));do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());}
function check(bool $ok,string $msg):void{if(!$ok)throw new RuntimeException($msg);}
runSql($p,__DIR__.'/fixtures/energy-healing.sql');
foreach([1,2] as $pass)foreach(['energy_healing_department.sql','energy_healing_loinc_links.sql','energy_healing_pranic_entry.sql','energy_healing_magnified_entry.sql','energy_healing_process_maps.sql'] as $f)runSql($p,__DIR__.'/../backend/'.$f);
check((int)$p->query('SELECT COUNT(*) FROM ilb_ehr_practice')->fetchColumn()===10,'Rerun duplicated practices');
check((int)$p->query('SELECT COUNT(*) FROM ilb_ehr_section')->fetchColumn()===16,'Rerun duplicated sections');
check((int)$p->query('SELECT COUNT(*) FROM ilb_ehr_evidence_review')->fetchColumn()===1,'Rerun duplicated reviews');
check((int)$p->query("SELECT COUNT(*) FROM ilb_ehr_claim WHERE practice_code='MAGNIFIED_HEALING'")->fetchColumn()===5,'Magnified claims missing or duplicated');
check((int)$p->query("SELECT COUNT(*) FROM ilb_ehr_protocol WHERE practice_code='MAGNIFIED_HEALING' AND research_status='DRAFT'")->fetchColumn()===3,'Magnified draft protocols missing');
$p->exec("INSERT INTO ilb_ehr_session(session_key,practice_code,subject_key,started_at,delivery_mode,status) VALUES('fixture','PRANIC_HEALING','test-subject','2026-01-01','PROXIMITY','COMPLETED')");
$id=(int)$p->lastInsertId();$p->exec("INSERT INTO ilb_ehr_session_result_link VALUES($id,1,'BASELINE','Synthetic','test-login',CURRENT_TIMESTAMP),($id,2,'BASELINE','Synthetic','test-login',CURRENT_TIMESTAMP)");
check((int)$p->query('SELECT COUNT(*) FROM v_ilb_ehr_session_loinc_result')->fetchColumn()===1,'Cross-subject result visible');
check($p->query('SELECT reported_value_text FROM v_ilb_ehr_session_loinc_result')->fetchColumn()==='positive','Qualitative result lost');
$p->exec("UPDATE ilb_test_atlas_loinc_crosswalk SET mapping_status='REJECTED'");
check((int)$p->query('SELECT COUNT(*) FROM v_ilb_ehr_session_loinc_result')->fetchColumn()===0,'Revoked mapping visible');
$p->exec("UPDATE ilb_test_atlas_loinc_crosswalk SET mapping_status='APPROVED'; UPDATE ilb_ehr_session SET status='CANCELLED'");
check((int)$p->query('SELECT COUNT(*) FROM v_ilb_ehr_session_loinc_result')->fetchColumn()===0,'Cancelled session visible');
$p->exec("UPDATE ilb_ehr_session SET status='COMPLETED'; UPDATE ilb_subject_test_result_ledger SET entry_status='VOID' WHERE result_id=1");
check((int)$p->query('SELECT COUNT(*) FROM v_ilb_ehr_session_loinc_result')->fetchColumn()===0,'Void result visible');
$p->exec("UPDATE ilb_subject_test_result_ledger SET entry_status='ACTIVE' WHERE result_id=1; DELETE FROM ilb_ehr_session_result_link; DELETE FROM ilb_ehr_session;");
check((int)$p->query('SELECT COUNT(*) FROM ilb_ehr_process_map')->fetchColumn()===2,'Process maps duplicated');
check((int)$p->query('SELECT COUNT(*) FROM ilb_ehr_process_connection')->fetchColumn()===7,'Process connections duplicated');
check((int)$p->query("SELECT COUNT(*) FROM ilb_ehr_process_connection WHERE modality_causal_status='SUPPORTED' OR sequence_position IS NOT NULL")->fetchColumn()===0,'Unsupported process validation or sequence inserted');
$p->exec("INSERT INTO ilb_ehr_process_map VALUES('TEST_DRAFT','REIKI','Synthetic hidden outcome','SOURCE_GAP','UNKNOWN',NULL,'Synthetic fixture','Synthetic private draft')");
echo "SQL integration checks passed\n";
