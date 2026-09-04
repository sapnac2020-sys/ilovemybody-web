<?php
declare(strict_types=1);

ini_set('display_errors','stderr');
ini_set('log_errors','0');
error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody';
const HUMAN_TAXON=9606;
if(PHP_SAPI!=='cli') exit(2);
$config=require($argv[1]??'');
if(isset($config['database'])&&is_array($config['database'])) $config=$config['database'];
$database=$config['db']??($config['name']??null);
if($database!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??'';
if(!is_file($sqlPath)) throw new RuntimeException('Phase 79 SQL missing');

function getJson(string $url):array{
 $context=stream_context_create(['http'=>['timeout'=>30,'ignore_errors'=>true,'header'=>"Accept: application/json\r\nUser-Agent: ILoveMyBody-Research/1.0\r\n"],'ssl'=>['verify_peer'=>true,'verify_peer_name'=>true]]);
 $raw=file_get_contents($url,false,$context);
 if($raw===false) throw new RuntimeException('Source request failed: '.$url);
 $status=$http_response_header[0]??'';
 if(!preg_match('/\s2\d\d\s/',$status)) throw new RuntimeException('Source response '.$status.': '.$url);
 $data=json_decode($raw,true,512,JSON_THROW_ON_ERROR);
 if(!is_array($data)) throw new RuntimeException('Non-object JSON: '.$url);
 return $data;
}

$agents=['ADALIMUMAB'=>'adalimumab','BIMEKIZUMAB'=>'bimekizumab','BRODALUMAB'=>'brodalumab','ETANERCEPT'=>'etanercept','GUSELKUMAB'=>'guselkumab','INFLIXIMAB'=>'infliximab','IXEKIZUMAB'=>'ixekizumab','RISANKIZUMAB'=>'risankizumab','SECUKINUMAB'=>'secukinumab','TILDRAKIZUMAB'=>'tildrakizumab','USTEKINUMAB'=>'ustekinumab'];
$rx=[];
foreach($agents as $agentKey=>$name){
 $lookup='https://rxnav.nlm.nih.gov/REST/rxcui.json?name='.rawurlencode($name).'&search=2';
 $ids=getJson($lookup)['idGroup']['rxnormId']??[];
 $matches=[];
 foreach($ids as $id){
  if(!preg_match('/^[0-9]+$/',(string)$id)) continue;
  $properties=getJson('https://rxnav.nlm.nih.gov/REST/rxcui/'.rawurlencode((string)$id).'/properties.json')['properties']??null;
  if(!is_array($properties)) continue;
  $resolvedName=mb_strtolower(trim((string)($properties['name']??'')),'UTF-8');
  $tty=(string)($properties['tty']??'');
  if($resolvedName===$name && in_array($tty,['IN','PIN','MIN'],true)) $matches[]=['rxcui'=>(string)$id,'name'=>$resolvedName,'tty'=>$tty,'url'=>'https://rxnav.nlm.nih.gov/REST/rxcui/'.rawurlencode((string)$id).'/properties.json'];
 }
 if(count($matches)!==1) throw new RuntimeException('RxNorm exact ingredient resolution count for '.$name.': '.count($matches));
 $rx[$agentKey]=$matches[0];
}

$targets=[
 ['IL17A','IL17A','LIGAND','Q16552'],
 ['IL17A_IL17F','IL17A','LIGAND','Q16552'],['IL17A_IL17F','IL17F','LIGAND','Q96PD4'],
 ['IL17_RECEPTOR','IL17RA','RECEPTOR_SUBUNIT','Q96F46'],['IL17_RECEPTOR','IL17RC','RECEPTOR_SUBUNIT','Q8NAC3'],
 ['IL23_P19','IL23A','LIGAND_SUBUNIT','Q9NPF7'],
 ['IL12_IL23_P40','IL12B','SHARED_LIGAND_SUBUNIT','P29460'],
 ['TNF','TNF','LIGAND','P01375']
];
$verifiedTargets=[];
foreach($targets as [$targetKey,$componentKey,$role,$accession]){
 $url='https://rest.uniprot.org/uniprotkb/'.$accession.'.json';
 $record=getJson($url);
 if(($record['primaryAccession']??null)!==$accession) throw new RuntimeException('UniProt accession mismatch: '.$accession);
 if((int)($record['organism']['taxonId']??0)!==HUMAN_TAXON) throw new RuntimeException('UniProt non-human target: '.$accession);
 $verifiedTargets[]=[$targetKey,$componentKey,$role,'UNIPROT',$accession,HUMAN_TAXON,$url];
}

$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$stmt=$pdo->prepare(file_get_contents($sqlPath));$stmt->execute();do{if($stmt->columnCount())$stmt->fetchAll();}while($stmt->nextRowset());$stmt->closeCursor();
$runKey='P79_'.gmdate('Ymd_His');
$pdo->beginTransaction();
try{
 $insId=$pdo->prepare("INSERT INTO ilb_psoriasis_pharma_identifier(agent_key,identifier_system,identifier_value,match_type,approval_status,computation_eligible,evidence_url) VALUES(?,'RXNORM',?,'EXACT','APPROVED',1,?) ON DUPLICATE KEY UPDATE match_type='EXACT',approval_status='APPROVED',computation_eligible=1,evidence_url=VALUES(evidence_url)");
 $agentUpdate=$pdo->prepare("UPDATE ilb_psoriasis_pharma_agent SET identity_status='EXACT_APPROVED' WHERE agent_key=? AND ingredient_name=?");
 foreach($rx as $agentKey=>$row){$insId->execute([$agentKey,$row['rxcui'],$row['url']]);$agentUpdate->execute([$agentKey,$agents[$agentKey]]);if($agentUpdate->rowCount()>1)throw new RuntimeException('Unexpected agent update count');}
 $insTarget=$pdo->prepare("INSERT INTO ilb_psoriasis_target_component VALUES(?,?,?,?,?,?,?,'SOURCE_VERIFIED',UTC_TIMESTAMP(),1) ON DUPLICATE KEY UPDATE component_role=VALUES(component_role),organism_taxon_id=VALUES(organism_taxon_id),source_url=VALUES(source_url),verification_status='SOURCE_VERIFIED',verified_at=UTC_TIMESTAMP(),computation_eligible=1");
 foreach($verifiedTargets as $row)$insTarget->execute($row);
 $targetKeys=array_values(array_unique(array_column($verifiedTargets,0)));
 foreach($targetKeys as $targetKey){
  $q=$pdo->prepare("SELECT COUNT(*) FROM ilb_psoriasis_target_component WHERE target_key=? AND verification_status='SOURCE_VERIFIED' AND computation_eligible=1");$q->execute([$targetKey]);
  if((int)$q->fetchColumn()<1)throw new RuntimeException('Unverified target '.$targetKey);
  $u=$pdo->prepare("UPDATE ilb_psoriasis_pharma_target SET mapping_status='STRUCTURAL_EXACT',computation_eligible=1 WHERE target_key=?");$u->execute([$targetKey]);
 }
 $exactAgents=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_pharma_agent WHERE identity_status='EXACT_APPROVED'")->fetchColumn();
 $eligibleTargets=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_pharma_target WHERE computation_eligible=1")->fetchColumn();
 if($exactAgents!==11||$eligibleTargets!==11)throw new RuntimeException("Promotion counts agents={$exactAgents},targets={$eligibleTargets}");
 $pdo->exec("UPDATE ilb_psoriasis_release_gate SET status='PASSED',evidence_note='All 11 ingredients resolved exactly through RxNorm and verified at source.' WHERE gate_code='G03_PHARMA_IDENTITIES'");
 $pdo->exec("UPDATE ilb_psoriasis_release_gate SET status='PASSED',evidence_note='All registered target mappings have source-verified human UniProt components and an explicit intervention operator.' WHERE gate_code='G05_TARGET_CROSSWALK'");
 $run=$pdo->prepare("INSERT INTO ilb_psoriasis_external_resolution_run VALUES(?,'RXNORM',?,11,11,0,0,0,'PASSED',UTC_TIMESTAMP()),(?,'UNIPROT',?,8,8,0,0,0,'PASSED',UTC_TIMESTAMP())");
 $run->execute([$runKey,'https://rxnav.nlm.nih.gov/REST/',$runKey,'https://rest.uniprot.org/uniprotkb/']);
 $pdo->commit();
}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
$gateCounts=$pdo->query("SELECT status,COUNT(*) row_count FROM ilb_psoriasis_release_gate GROUP BY status ORDER BY status")->fetchAll();
echo json_encode(['database'=>$database,'phase'=>'P79_IDENTITY_TARGET','run_key'=>$runKey,'rxnorm_exact_agents'=>count($rx),'uniprot_verified_components'=>count($verifiedTargets),'eligible_target_mappings'=>11,'gate_counts'=>$gateCounts,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
