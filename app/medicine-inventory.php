<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
try {
  $configPath=dirname(__DIR__,2).'/ilmb-config.php';
  $c=require $configPath;if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
  $pdo=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
  $sheet=$pdo->query("SELECT system_id,sheet_name,COUNT(*) row_count FROM ilmb_canonical_record WHERE active=1 AND (LOWER(sheet_name) REGEXP 'medicine|drug|pharma|nlem|rxnorm|ingredient|mechanism|adverse|interaction') GROUP BY system_id,sheet_name ORDER BY row_count DESC,sheet_name")->fetchAll();
  $samples=[];
  $masters=[['REF-MENTAL-HEALTH','07_NLEM_Medicines'],['SYS-018','Medicine_Master']];
  $q=$pdo->prepare("SELECT source_key,payload_json FROM ilmb_canonical_record WHERE active=1 AND system_id=? AND sheet_name=? ORDER BY source_key LIMIT 3");
  foreach($masters as [$system,$name]){$q->execute([$system,$name]);$rows=[];foreach($q->fetchAll() as $r){$p=json_decode((string)$r['payload_json'],true);$rows[]=['source_key'=>$r['source_key'],'fields'=>is_array($p)?array_slice($p,0,20,true):[]];}$samples[]=['system_id'=>$system,'sheet_name'=>$name,'rows'=>$rows];}
  $tables=$pdo->query("SELECT table_name,table_rows FROM information_schema.tables WHERE table_schema=DATABASE() AND (LOWER(table_name) REGEXP 'medicine|drug|pharma|nlem|rxnorm|ingredient|mechanism|adverse|interaction') ORDER BY table_name")->fetchAll();
  $tableSamples=[];$safeTables=['ilb_pharma_medicine','ilb_drug','ilb_drug_identifier','ilb_medicine_mechanism'];
  foreach($safeTables as $t){$cols=$pdo->query("SELECT column_name FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=".$pdo->quote($t)." ORDER BY ordinal_position")->fetchAll(PDO::FETCH_COLUMN);$rows=$pdo->query("SELECT * FROM `{$t}` LIMIT 3")->fetchAll();$tableSamples[]=['table'=>$t,'columns'=>$cols,'rows'=>$rows];}
  $x=$pdo->query("SELECT source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible,COUNT(*) row_count FROM ilmb_entity_crosswalk WHERE source_entity_type IN ('MEDICINE','DRUG','INGREDIENT') OR target_entity_type IN ('MEDICINE','DRUG','INGREDIENT') OR source_system IN ('RXNORM','NLEM') OR target_system IN ('RXNORM','NLEM') GROUP BY source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible ORDER BY row_count DESC")->fetchAll();
  echo json_encode(['ok'=>true,'mode'=>'read_only_non_patient_medicine_inventory','patient_data_read'=>false,'patient_data_written'=>false,'canonical_sheets'=>$sheet,'crosswalk_groups'=>$x,'matching_tables'=>$tables,'canonical_master_samples'=>$samples,'safe_table_samples'=>$tableSamples],JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
} catch(Throwable $e){http_response_code(500);echo json_encode(['ok'=>false,'error'=>'Medicine inventory unavailable']);}
