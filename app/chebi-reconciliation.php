<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');header('Cache-Control: no-store');
try{
$c=require dirname(__DIR__,2).'/ilmb-config.php';if(isset($c['database'])&&is_array($c['database']))$c=$c['database'];
$p=new PDO("mysql:host=".$c['host'].";port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$tables=$p->query("SELECT table_name,table_type,table_rows estimated_rows FROM information_schema.tables WHERE table_schema=DATABASE() AND LOWER(table_name) LIKE '%chebi%' ORDER BY table_type,table_name")->fetchAll();
$batches=$p->query("SELECT system_id,status,COUNT(*) batch_count,COALESCE(SUM(total_rows),0) total_rows,COALESCE(SUM(valid_rows),0) valid_rows,COALESCE(SUM(error_rows),0) error_rows FROM ilmb_sync_batch WHERE UPPER(system_id) LIKE '%CHEBI%' OR UPPER(file_name) LIKE '%CHEBI%' GROUP BY system_id,status ORDER BY system_id,status")->fetchAll();
$x=$p->query("SELECT source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible,COUNT(*) row_count FROM ilmb_entity_crosswalk WHERE source_system='CHEBI' OR target_system='CHEBI' GROUP BY source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible ORDER BY row_count DESC")->fetchAll();
echo json_encode(['ok'=>true,'mode'=>'read_only_non_patient_chebi_schema_inventory','patient_data_read'=>false,'patient_data_written'=>false,'chebi_tables'=>$tables,'sync_batches'=>$batches,'crosswalk_groups'=>$x],JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
}catch(Throwable $e){http_response_code(500);echo json_encode(['ok'=>false,'error'=>'ChEBI reconciliation unavailable']);}
