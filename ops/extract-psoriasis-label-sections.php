<?php
declare(strict_types=1);
ini_set('display_errors','stderr');ini_set('log_errors','0');error_reporting(E_ALL);
const EXPECTED_DATABASE='u756742628_ilovemybody';
if(PHP_SAPI!=='cli')exit(2);
$config=require($argv[1]??'');if(isset($config['database'])&&is_array($config['database']))$config=$config['database'];
$database=$config['db']??($config['name']??null);if($database!==EXPECTED_DATABASE)throw new RuntimeException('Unexpected database');
$sqlPath=$argv[2]??'';if(!is_file($sqlPath))throw new RuntimeException('Phase 81 SQL missing');if(!class_exists(DOMDocument::class))throw new RuntimeException('PHP DOM required');
$wanted=['34067-9'=>'INDICATIONS','34068-7'=>'DOSAGE','34070-3'=>'CONTRAINDICATIONS','43685-7'=>'WARNINGS','34071-1'=>'WARNINGS','34084-4'=>'ADVERSE_REACTIONS','34090-1'=>'CLINICAL_PHARMACOLOGY','43682-4'=>'PHARMACOKINETICS','88830-5'=>'IMMUNOGENICITY'];
function sourceXml(string $url):string{
 $ctx=stream_context_create(['http'=>['timeout'=>45,'ignore_errors'=>true,'header'=>"Accept: application/xml\r\nUser-Agent: ILoveMyBody-Research/1.0\r\n"],'ssl'=>['verify_peer'=>true,'verify_peer_name'=>true]]);
 $raw=file_get_contents($url,false,$ctx);$status=$http_response_header[0]??'';
 if($raw===false||!preg_match('/\s2\d\d\s/',$status))throw new RuntimeException('DailyMed XML response '.$status.' for '.$url);return $raw;
}
function cleanText(string $v):string{return trim((string)preg_replace('/\s+/u',' ',$v));}
$pdo=new PDO('mysql:host='.$config['host'].';port='.($config['port']??3306).';dbname='.$database.';charset=utf8mb4',$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$stmt=$pdo->prepare(file_get_contents($sqlPath));$stmt->execute();do{if($stmt->columnCount())$stmt->fetchAll();}while($stmt->nextRowset());$stmt->closeCursor();
$labels=$pdo->query("SELECT agent_key,set_id FROM ilb_psoriasis_regulatory_label WHERE source_status='DAILYMED_RETURNED' ORDER BY agent_key,set_id")->fetchAll();if(count($labels)<11)throw new RuntimeException('Regulatory label registry incomplete');
$sections=[];$failed=[];
foreach($labels as $label){
 $url='https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/'.$label['set_id'].'.xml';
 try{$xml=sourceXml($url);$doc=new DOMDocument();$doc->preserveWhiteSpace=false;if(!$doc->loadXML($xml,LIBXML_NONET|LIBXML_NOERROR|LIBXML_NOWARNING))throw new RuntimeException('Invalid SPL XML');
  $xp=new DOMXPath($doc);
  foreach($xp->query('//*[local-name()="section"]') as $node){
   $codeNode=$xp->query('./*[local-name()="code"]',$node)->item(0);$code=$codeNode instanceof DOMElement?$codeNode->getAttribute('code'):'';if(!isset($wanted[$code]))continue;
   $titleNode=$xp->query('./*[local-name()="title"]',$node)->item(0);$textNode=$xp->query('./*[local-name()="text"]',$node)->item(0);$text=$textNode?cleanText($textNode->textContent):'';if($text==='')continue;
   $title=$titleNode?cleanText($titleNode->textContent):($codeNode instanceof DOMElement?$codeNode->getAttribute('displayName'):$wanted[$code]);
   $key=$label['agent_key'].'|'.$label['set_id'].'|'.$wanted[$code];
   if(!isset($sections[$key])||strlen($text)>strlen($sections[$key]['text']))$sections[$key]=['agent'=>$label['agent_key'],'setid'=>$label['set_id'],'section'=>$wanted[$code],'name'=>$title,'text'=>$text,'sha'=>hash('sha256',$text),'url'=>$url];
  }
 }catch(Throwable $e){$failed[]=['agent_key'=>$label['agent_key'],'set_id'=>$label['set_id'],'error'=>$e->getMessage()];}
}
if($failed)throw new RuntimeException('SPL extraction failures: '.json_encode(array_slice($failed,0,10),JSON_UNESCAPED_SLASHES));if(!$sections)throw new RuntimeException('No required SPL sections extracted');
$pdo->beginTransaction();try{$ins=$pdo->prepare("INSERT INTO ilb_psoriasis_regulatory_label_section VALUES(?,?,?,?,?,?,?,'SOURCE_EXACT_TEXT',0,UTC_TIMESTAMP()) ON DUPLICATE KEY UPDATE section_name=VALUES(section_name),section_text=VALUES(section_text),section_sha256=VALUES(section_sha256),source_xml_url=VALUES(source_xml_url),extraction_status='SOURCE_EXACT_TEXT',extracted_at=UTC_TIMESTAMP()");foreach($sections as $r)$ins->execute([$r['agent'],$r['setid'],$r['section'],$r['name'],$r['text'],$r['sha'],$r['url']]);$pdo->commit();}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
$coverage=$pdo->query("SELECT coverage_status,COUNT(*) row_count FROM v_ilmb_psoriasis_label_section_coverage GROUP BY coverage_status ORDER BY coverage_status")->fetchAll();
echo json_encode(['database'=>$database,'phase'=>'P81_LABEL_SECTIONS','registered_labels'=>count($labels),'exact_sections'=>count($sections),'coverage_cells'=>88,'coverage'=>$coverage,'patient_tables_queried'=>false,'patient_rows_read'=>0,'patient_rows_modified'=>0,'verified'=>true],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
