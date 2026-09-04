<?php
declare(strict_types=1);
ini_set('display_errors','stderr');ini_set('log_errors','0');error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli')exit(2);
$config=require($argv[1]??'');if(isset($config['database'])&&is_array($config['database']))$config=$config['database'];
$database=$config['db']??($config['name']??null);if($database!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??'';if(!is_file($sqlPath))throw new RuntimeException('Phase 80 SQL missing');
function sourceJson(string $url):array{
 $ctx=stream_context_create(['http'=>['timeout'=>40,'ignore_errors'=>true,'header'=>"Accept: application/json\r\nUser-Agent: ILoveMyBody-Research/1.0\r\n"],'ssl'=>['verify_peer'=>true,'verify_peer_name'=>true]]);
 $raw=file_get_contents($url,false,$ctx);$status=$http_response_header[0]??'';
 if($raw===false||!preg_match('/\s2\d\d\s/',$status))throw new RuntimeException('DailyMed response '.$status.' for '.$url);
 $v=json_decode($raw,true,512,JSON_THROW_ON_ERROR);if(!is_array($v))throw new RuntimeException('DailyMed non-object response');return $v;
}
$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$stmt=$pdo->prepare(file_get_contents($sqlPath));$stmt->execute();do{if($stmt->columnCount())$stmt->fetchAll();}while($stmt->nextRowset());$stmt->closeCursor();
$agents=$pdo->query("SELECT a.agent_key,a.ingredient_name,i.identifier_value rxcui FROM ilb_psoriasis_pharma_agent a JOIN ilb_psoriasis_pharma_identifier i ON i.agent_key=a.agent_key AND i.identifier_system='RXNORM' AND i.match_type='EXACT' AND i.approval_status='APPROVED' AND i.computation_eligible=1 ORDER BY a.agent_key")->fetchAll();
if(count($agents)!==11)throw new RuntimeException('Expected 11 verified RxNorm agents, got '.count($agents));
$all=[];$perAgent=[];
foreach($agents as $agent){
 $page=1;$rows=[];
 do{
  $url='https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?rxcui='.rawurlencode($agent['rxcui']).'&pagesize=100&page='.$page;
  $payload=sourceJson($url);$data=$payload['data']??[];if(!is_array($data))throw new RuntimeException('DailyMed data missing for '.$agent['agent_key']);
  foreach($data as $row){
   $setid=strtolower((string)($row['setid']??''));
   if(!preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/',$setid))throw new RuntimeException('Invalid DailyMed setid for '.$agent['agent_key']);
   $rows[$setid]=['agent_key'=>$agent['agent_key'],'rxcui'=>$agent['rxcui'],'setid'=>$setid,'spl_version'=>(string)($row['spl_version']??''),'published_date'=>(string)($row['published_date']??''),'title'=>(string)($row['title']??''),'api_url'=>$url,'document_url'=>'https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid='.$setid];
  }
  $totalPages=max(1,(int)($payload['metadata']['total_pages']??1));$page++;
 }while($page<=$totalPages);
 if(count($rows)<1)throw new RuntimeException('No DailyMed SPL returned for '.$agent['agent_key'].' RxCUI '.$agent['rxcui']);
 $perAgent[$agent['agent_key']]=count($rows);array_push($all,...array_values($rows));
}
$pdo->beginTransaction();
try{
 $insert=$pdo->prepare("INSERT INTO ilb_psoriasis_regulatory_label(agent_key,rxcui,set_id,spl_version,published_date_text,label_title,source_api_url,label_document_url,source_status,computation_eligible,retrieved_at) VALUES(?,?,?,?,?,?,?,?,'DAILYMED_RETURNED',0,UTC_TIMESTAMP()) ON DUPLICATE KEY UPDATE rxcui=VALUES(rxcui),spl_version=VALUES(spl_version),published_date_text=VALUES(published_date_text),label_title=VALUES(label_title),source_api_url=VALUES(source_api_url),label_document_url=VALUES(label_document_url),source_status='DAILYMED_RETURNED',retrieved_at=UTC_TIMESTAMP()");
 foreach($all as $r)$insert->execute([$r['agent_key'],$r['rxcui'],$r['setid'],$r['spl_version'],$r['published_date'],$r['title'],$r['api_url'],$r['document_url']]);
 $pdo->commit();
}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
$live=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_regulatory_label WHERE source_status='DAILYMED_RETURNED'")->fetchColumn();
echo json_encode(['database'=>$database,'phase'=>'P80_REGULATORY_LABELS','verified_agents'=>count($agents),'source_returned_labels'=>$live,'labels_per_agent'=>$perAgent,'required_sections'=>8,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
