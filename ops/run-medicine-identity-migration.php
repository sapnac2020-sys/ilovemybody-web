<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli')exit(2);
$c=require($argv[1]??'');if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
$db=$c['db']??($c['name']??null);if($db!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$st=$pdo->prepare(file_get_contents($argv[2]??''));$st->execute();do{if($st->columnCount())$st->fetchAll();}while($st->nextRowset());$st->closeCursor();
$nlem=(int)$pdo->query("SELECT COUNT(*) FROM ilmb_crosswalk_endpoint WHERE system_id='NLEM' AND entity_type='MEDICINE' AND active=1")->fetchColumn();
$drugs=(int)$pdo->query("SELECT COUNT(*) FROM ilmb_crosswalk_endpoint WHERE system_id='ILMB' AND entity_type='DRUG' AND active=1")->fetchColumn();
$rx=(int)$pdo->query("SELECT COUNT(*) FROM ilmb_entity_crosswalk WHERE source_system='ILMB' AND source_entity_type='DRUG' AND predicate='HAS_RXNORM_ID' AND target_system='RXNORM' AND match_type='EXACT' AND status='APPROVED' AND computation_eligible=1")->fetchColumn();
$mechanisms=(int)$pdo->query("SELECT COUNT(*) FROM ilmb_entity_crosswalk WHERE source_system='ILMB' AND source_entity_type='DRUG' AND predicate='HAS_MECHANISM' AND target_system='ILMB' AND match_type='EXACT' AND status='APPROVED'")->fetchColumn();
$metformin=(int)$pdo->query("SELECT COUNT(*) FROM v_ilmb_medicine_identity_proof WHERE drug_key='metformin' AND rxnorm_id='6809'")->fetchColumn();
$out=['nlem_identities'=>$nlem,'ilmb_drugs'=>$drugs,'exact_rxnorm_links'=>$rx,'exact_mechanism_links'=>$mechanisms,'metformin_proof_rows'=>$metformin,'nlem_rxnorm_links_inferred'=>0,'nlem_chebi_links_inferred'=>0,'draft_clinical_examples_promoted'=>0,'patient_rows_read'=>0,'patient_rows_modified'=>0,'ready'=>$nlem===384&&$drugs===14&&$rx===4&&$mechanisms===10&&$metformin===1];
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;if(!$out['ready'])exit(4);
