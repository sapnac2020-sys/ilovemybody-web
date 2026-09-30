<?php
declare(strict_types=1);
/** Read-only audit. Output contains public research metadata and aggregate counts only. */
function auditEnergyHealing(PDO $p): array {
 $checks = [
  'catalogue_without_practice' => "SELECT COUNT(*) FROM ilb_ehr_catalogue c LEFT JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code WHERE p.practice_code IS NULL",
  'branch_without_parent' => "SELECT COUNT(*) FROM ilb_ehr_catalogue WHERE record_kind='BRANCH' AND parent_practice_code IS NULL",
  'catalogue_without_source' => "SELECT COUNT(*) FROM ilb_ehr_catalogue WHERE TRIM(source_url)='' OR TRIM(source_name)=''",
  'cross_subject_session_links' => "SELECT COUNT(*) FROM ilb_ehr_session_result_link l JOIN ilb_ehr_session s ON s.session_id=l.session_id JOIN ilb_subject_test_result_ledger r ON r.result_id=l.result_id WHERE CONVERT(s.subject_key USING utf8mb4) COLLATE utf8mb4_bin <> CONVERT(r.subject_key USING utf8mb4) COLLATE utf8mb4_bin",
  'convergence_without_locator' => "SELECT COUNT(*) FROM ilb_ehr_convergence_observation WHERE TRIM(source_url)='' OR TRIM(source_locator)=''",
  'appraisal_without_effect_limits' => "SELECT COUNT(*) FROM ilb_ehr_evidence_review WHERE TRIM(limitations_text)='' OR TRIM(source_locator)=''",
  'process_review_without_locator' => "SELECT COUNT(*) FROM ilb_ehr_process_review WHERE TRIM(source_url)='' OR TRIM(source_locator)=''"
 ];
 $errors=[];foreach($checks as $name=>$sql){$n=(int)$p->query($sql)->fetchColumn();if($n)$errors[$name]=$n;}
 $rows=$p->query("SELECT c.practice_code,c.record_kind,c.scope_status,p.practice_name,p.review_status,
  (SELECT COUNT(*) FROM ilb_ehr_section s WHERE s.practice_code=c.practice_code AND s.publication_status='PUBLISHED') AS published_sections,
  (SELECT COUNT(*) FROM ilb_ehr_evidence_review e JOIN ilb_ehr_claim cl ON cl.claim_id=e.claim_id WHERE cl.practice_code=c.practice_code) AS evidence_reviews,
  (SELECT COUNT(*) FROM ilb_ehr_process_review r WHERE r.practice_code=c.practice_code) AS process_reviews,
  (SELECT COUNT(*) FROM ilb_ehr_search_audit a WHERE a.practice_code=c.practice_code) AS discovery_searches,
  (SELECT COUNT(*) FROM ilb_ehr_study_scope x JOIN ilb_ehr_claim cl ON cl.claim_key=x.claim_key WHERE cl.practice_code=c.practice_code AND x.material_reviewed='ABSTRACT') AS abstract_appraisals,
  (SELECT COUNT(*) FROM ilb_ehr_protocol t WHERE t.practice_code=c.practice_code AND t.research_status='COMPLETED' AND NULLIF(TRIM(t.results_text),'') IS NOT NULL) AS completed_protocols_with_results,
  (SELECT COUNT(*) FROM ilb_ehr_convergence_observation o WHERE o.practice_code=c.practice_code) AS convergence_observations
  FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code ORDER BY c.practice_code")->fetchAll(PDO::FETCH_ASSOC);
 $kinds=[];$pending=[];foreach($rows as &$r){
  foreach(['published_sections','evidence_reviews','process_reviews','discovery_searches','abstract_appraisals','completed_protocols_with_results','convergence_observations'] as $key)$r[$key]=(int)$r[$key];
  $kinds[$r['record_kind']]=($kinds[$r['record_kind']]??0)+1;
  $gaps=[];if(!$r['published_sections'])$gaps[]='DETAILED_ENTRY_MISSING';
  if(!$r['evidence_reviews'])$gaps[]='STRUCTURED_EVIDENCE_REVIEW_MISSING';
  if(!$r['process_reviews'])$gaps[]='PROCESS_REVIEW_MISSING';
  if($r['abstract_appraisals'])$gaps[]='FULL_TEXT_APPRAISAL_PENDING';
  if(!$r['discovery_searches'])$gaps[]='DISCOVERY_SEARCH_MISSING';
  if($r['review_status']!=='REVIEWED')$gaps[]='RESEARCH_REVIEW_INCOMPLETE';
  if(!$r['completed_protocols_with_results'])$gaps[]='NO_COMPLETED_DEPARTMENT_PROTOCOL_WITH_RESULTS';
  $r['gaps']=$gaps;if($gaps)$pending[]=$r['practice_code'];
 }unset($r);
 return ['schema_version'=>1,'generated_at_utc'=>gmdate('c'),'integrity_status'=>$errors?'FAIL':'PASS',
  'integrity_errors'=>$errors,'catalogue_records'=>count($rows),'record_kinds'=>$kinds,
  'records_with_open_research_gaps'=>count($pending),'coverage'=>$rows,
  'interpretation'=>'Counts verify stored coverage only. Evidence presence, completed protocols and teaching similarities do not by themselves validate efficacy or mechanism. No exhaustive global scope is asserted.'];
}
if(PHP_SAPI==='cli' && realpath($_SERVER['SCRIPT_FILENAME']??'')===__FILE__){
 try{
  require ($argv[1]??dirname(__DIR__)).'/app/lib.php';
  $report=auditEnergyHealing(db());echo json_encode($report,JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR)."\n";
  exit($report['integrity_status']==='PASS'?0:2);
 }catch(Throwable $e){fwrite(STDERR,"Energy healing audit failed: configuration or schema unavailable.\n");exit(1);}
}
