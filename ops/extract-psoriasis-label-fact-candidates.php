<?php
declare(strict_types=1);
ini_set('display_errors','stderr');ini_set('log_errors','0');error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli')exit(2);
$config=require($argv[1]??'');if(isset($config['database'])&&is_array($config['database']))$config=$config['database'];
$database=$config['db']??($config['name']??null);if($database!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??'';if(!is_file($sqlPath))throw new RuntimeException('Phase 82 SQL missing');
$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$stmt=$pdo->prepare(file_get_contents($sqlPath));$stmt->execute();do{if($stmt->columnCount())$stmt->fetchAll();}while($stmt->nextRowset());$stmt->closeCursor();
$rows=$pdo->query("SELECT agent_key,set_id,section_code,section_text,section_sha256 FROM ilb_psoriasis_regulatory_label_section WHERE extraction_status='SOURCE_EXACT_TEXT' AND section_code IN ('DOSAGE','PHARMACOKINETICS','CLINICAL_PHARMACOLOGY','IMMUNOGENICITY','ADVERSE_REACTIONS','WARNINGS','CONTRAINDICATIONS') ORDER BY agent_key,set_id,section_code")->fetchAll();
if(!$rows)throw new RuntimeException('No exact regulatory-label sections available');
function kind(string $section):string{return match($section){'DOSAGE'=>'DOSING','PHARMACOKINETICS','CLINICAL_PHARMACOLOGY'=>'PHARMACOKINETIC','IMMUNOGENICITY'=>'IMMUNOGENICITY','ADVERSE_REACTIONS','WARNINGS','CONTRAINDICATIONS'=>'SAFETY',default=>'OTHER'};}
function context(string $text,int $offset,int $length):string{$start=max(0,$offset-180);$span=substr($text,$start,$length+360);return trim((string)preg_replace('/\s+/u',' ',$span));}
$pattern='/\b(\d+(?:\.\d+)?)\s*(mg\/kg|ng\/mL|mcg\/mL|µg\/mL|ug\/mL|mg\/mL|mcg|µg|ug|mg|mL|L|%|hours?|days?|weeks?|months?|years?)\b/iu';
$candidates=[];
foreach($rows as $row){if(!preg_match_all($pattern,$row['section_text'],$matches,PREG_SET_ORDER|PREG_OFFSET_CAPTURE))continue;foreach($matches as $m){$exact=$m[0][0];$offset=$m[0][1];$span=context($row['section_text'],$offset,strlen($exact));$key=hash('sha256',$row['agent_key'].'|'.$row['set_id'].'|'.$row['section_code'].'|'.$span.'|'.$exact);$candidates[$key]=['agent'=>$row['agent_key'],'setid'=>$row['set_id'],'section'=>$row['section_code'],'kind'=>kind($row['section_code']),'exact'=>$exact,'context'=>$span,'value'=>$m[1][0],'unit'=>$m[2][0],'context_sha'=>hash('sha256',$span),'section_sha'=>$row['section_sha256']];}}
if(!$candidates)throw new RuntimeException('No source-bound numeric candidates found');
$covered=array_values(array_unique(array_column($candidates,'agent')));
$pdo->beginTransaction();try{$pdo->exec("DELETE FROM ilb_psoriasis_label_fact_candidate WHERE review_status='UNREVIEWED' AND computation_eligible=0");$ins=$pdo->prepare("INSERT INTO ilb_psoriasis_label_fact_candidate(agent_key,set_id,section_code,candidate_kind,exact_match,context_span,numeric_value,source_unit,context_sha256,source_section_sha256,review_status,computation_eligible,extracted_at) VALUES(?,?,?,?,?,?,?,?,?,?,'UNREVIEWED',0,UTC_TIMESTAMP())");foreach($candidates as $r)$ins->execute([$r['agent'],$r['setid'],$r['section'],$r['kind'],$r['exact'],$r['context'],$r['value'],$r['unit'],$r['context_sha'],$r['section_sha']]);$pdo->commit();}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
$byKind=$pdo->query("SELECT candidate_kind,COUNT(*) row_count FROM ilb_psoriasis_label_fact_candidate GROUP BY candidate_kind ORDER BY candidate_kind")->fetchAll();
$readiness=$pdo->query("SELECT readiness_status,COUNT(*) agent_count FROM v_ilmb_psoriasis_label_fact_readiness GROUP BY readiness_status ORDER BY readiness_status")->fetchAll();
$registeredAgents=(int)$pdo->query("SELECT COUNT(*) FROM v_ilmb_psoriasis_label_fact_readiness")->fetchColumn();if($registeredAgents!==11)throw new RuntimeException('Readiness registry does not cover all 11 agents');
$eligible=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_label_fact_candidate WHERE computation_eligible=1")->fetchColumn();if($eligible!==0)throw new RuntimeException('Unreviewed label candidates became computation eligible');
echo json_encode(['database'=>$database,'phase'=>'P82_LABEL_FACT_CANDIDATES','source_sections_scanned'=>count($rows),'registered_agents'=>$registeredAgents,'source_candidate_agents'=>count($covered),'agents_without_numeric_candidates'=>$registeredAgents-count($covered),'candidate_count'=>count($candidates),'by_kind'=>$byKind,'readiness'=>$readiness,'computation_eligible_candidates'=>$eligible,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
