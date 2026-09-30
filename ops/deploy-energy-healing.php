<?php
declare(strict_types=1);
// CLI only. Uses installed app configuration; never prints credentials or case data.
if(PHP_SAPI!=='cli')exit(1);
try {
 $target=$argv[1];$work=$argv[2];$backup=$argv[3];
 require $target.'/app/lib.php';$p=db();
 if($p->query('SELECT DATABASE()')->fetchColumn()!=='u756742628_ilovemybody')throw new RuntimeException('Wrong database');
 $lock=$p->query("SELECT GET_LOCK('ilmb-energy-healing-deploy',30)")->fetchColumn();
 if((int)$lock!==1)throw new RuntimeException('Deployment lock unavailable');
 foreach([
 'ilb_subject_test_result_ledger'=>'result_id,subject_key,observed_on,reported_test_name,reported_value_text,reported_numeric_value,reported_unit,reported_specimen_text,reported_reference_range_text,laboratory_name,source_document_id,exact_loinc_num,exact_crosswalk_id,identity_status,entry_status',
 'ilb_test_atlas_loinc_crosswalk'=>'crosswalk_id,candidate_id,loinc_num,mapping_status,mapping_evidence,evidence_locator',
 'ilb_test_atlas_candidate'=>'candidate_id,validation_state',
 'v_ilb_subject_test_result_visible'=>'result_id,subject_key,observed_on,reported_test_name,identity_status',
 'ilb_participant_login'=>'login_id,public_case_key,subject_key,must_change_pin,status',
 'ilb_subject_frontend_alias'=>'public_case_key,frontend_label,allowed_age_display,allowed_sex_display,status'
 ] as $table=>$cols)$p->query("SELECT $cols FROM $table LIMIT 0");
 if(!is_dir($backup)||str_contains(realpath($backup),'/public_html/'))throw new RuntimeException('Private backup path required');
 umask(0077);
 $tables=$p->query("SELECT TABLE_NAME,TABLE_TYPE FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND LEFT(TABLE_NAME,8)='ilb_ehr_'")->fetchAll();
 foreach($tables as $t){
  if($t['TABLE_TYPE']!=='BASE TABLE')continue;
  $name=$t['TABLE_NAME'];if(!preg_match('/^ilb_ehr_[a-z_]+$/',$name))throw new RuntimeException('Invalid table name');
  $ddl=$p->query("SHOW CREATE TABLE $name")->fetch(PDO::FETCH_NUM)[1];
  $fh=fopen($backup.'/'.$name.'.jsonl','x');if(!$fh)throw new RuntimeException('Backup write failed');
  fwrite($fh,json_encode(['ddl'=>$ddl],JSON_THROW_ON_ERROR)."\n");
  $st=$p->query("SELECT * FROM $name");while($row=$st->fetch(PDO::FETCH_ASSOC))fwrite($fh,json_encode($row,JSON_THROW_ON_ERROR)."\n");fclose($fh);
 }
 foreach(['energy_healing_department.sql','energy_healing_loinc_links.sql','energy_healing_pranic_entry.sql','energy_healing_magnified_entry.sql','energy_healing_process_maps.sql','energy_healing_catalogue.sql','energy_healing_convergence.sql','energy_healing_process_reviews.sql','energy_healing_literature.sql'] as $file){
  // PDO connection disallows multi-statements. Execute with a dedicated connection.
  $c=cfg()['db'];
  $m=new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$c['host'],$c['port'],$c['name'],$c['charset']),$c['user'],$c['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  $st=$m->query(file_get_contents($work.'/backend/'.$file));do{if($st->columnCount())$st->fetchAll();}while($st->nextRowset());
 }
 $count=(int)$p->query("SELECT COUNT(*) FROM ilb_ehr_section WHERE practice_code='PRANIC_HEALING' AND publication_status='PUBLISHED'")->fetchColumn();
 if($count!==8)throw new RuntimeException('Entry count verification failed');
 $mhCount=(int)$p->query("SELECT COUNT(*) FROM ilb_ehr_section WHERE practice_code='MAGNIFIED_HEALING' AND publication_status='PUBLISHED'")->fetchColumn();
 if($mhCount!==8)throw new RuntimeException('Magnified entry verification failed');
 $catalogueCount=(int)$p->query("SELECT COUNT(*) FROM ilb_ehr_catalogue WHERE publication_status='PUBLISHED'")->fetchColumn();
 if($catalogueCount<50)throw new RuntimeException('Catalogue verification failed');
 try{
  $st=$p->prepare("SELECT c.*,p.practice_name,p.review_status,p.publication_status AS entry_status,parent.practice_name AS parent_name FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code LEFT JOIN ilb_ehr_practice parent ON parent.practice_code=c.parent_practice_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' ORDER BY c.category_name,p.practice_name");
  $st->execute();$st->fetchAll();
  $searchCheck=$p->prepare("SELECT c.practice_code FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code WHERE p.practice_name LIKE ? OR c.aliases_text LIKE ? OR c.category_name LIKE ?");
  $searchCheck->execute(['%Jikiden%','%Jikiden%','%Jikiden%']);if(!$searchCheck->fetchAll())throw new RuntimeException('Catalogue search check failed');
 }catch(PDOException $e){fwrite(STDERR,"Catalogue read query: ".($e->errorInfo[1]??0)." ".($e->errorInfo[2]??'query failure')."\n");throw $e;}
 $convergence=$p->query("SELECT COUNT(*) FROM ilb_ehr_convergence_observation WHERE finding_status='TEACHING_SIMILARITY'")->fetchColumn();
 if((int)$convergence!==34)throw new RuntimeException('Convergence source verification failed');
 if((int)$p->query("SELECT COUNT(*) FROM ilb_ehr_process_review")->fetchColumn()<50)throw new RuntimeException('Process reviews missing');
 if((int)$p->query("SELECT COUNT(DISTINCT practice_code) FROM ilb_ehr_search_audit")->fetchColumn()<50)throw new RuntimeException('Literature discovery records missing');
 if((int)$p->query("SELECT COUNT(*) FROM ilb_ehr_study_scope")->fetchColumn()<12)throw new RuntimeException('Study appraisals missing');
 $p->query("SELECT * FROM v_ilb_ehr_session_loinc_result LIMIT 0");
 $p->query("SELECT RELEASE_LOCK('ilmb-energy-healing-deploy')");
 echo "Energy healing migration and schema checks passed.\n";
} catch(Throwable $e){fwrite(STDERR,"Energy healing deployment stopped: configuration, schema, backup or migration check failed.\n");exit(1);}
