<?php
declare(strict_types=1);
header('Content-Type: application/json; charset=utf-8');
$configPath = $argv[1] ?? '';
if ($configPath === '' || !is_file($configPath)) { fwrite(STDERR, "Config missing\n"); exit(2); }
$c = require $configPath;
if (isset($c['database']) && is_array($c['database'])) $c = $c['database'];
$host=$c['host']??null; $port=(int)($c['port']??3306); $db=$c['db']??($c['name']??null); $user=$c['user']??null; $pass=$c['pass']??($c['password']??null);
if (!$host||!$db||!$user||$pass===null) { fwrite(STDERR, "DB config incomplete\n"); exit(2); }
$pdo=new PDO("mysql:host={$host};port={$port};dbname={$db};charset=utf8mb4",$user,$pass,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
$out=['database'=>$db,'patient_rows_read'=>0,'patient_rows_modified'=>0];
$q=$pdo->prepare("SELECT table_name,table_type FROM information_schema.tables WHERE table_schema=? AND (LOWER(table_name) LIKE '%loinc%' OR LOWER(table_name) LIKE '%formula%' OR LOWER(table_name) LIKE '%reference%' OR LOWER(table_name) LIKE '%observation%' OR LOWER(table_name) LIKE '%crosswalk%' OR LOWER(table_name) LIKE '%laboratory%') ORDER BY table_name");
$q->execute([$db]); $out['candidate_objects']=$q->fetchAll();
$q=$pdo->query("SELECT sheet_name,COUNT(*) rows_count FROM ilmb_canonical_record WHERE system_id='SYS-001' AND active=1 GROUP BY sheet_name ORDER BY rows_count DESC");
$out['loinc_canonical_sheets']=$q->fetchAll();
$q=$pdo->query("SELECT sheet_name,JSON_KEYS(payload_json) payload_keys FROM ilmb_canonical_record WHERE system_id='SYS-001' AND active=1 GROUP BY sheet_name ORDER BY sheet_name");
$out['loinc_payload_keys']=$q->fetchAll();
$q=$pdo->query("SELECT source_system,source_entity_type,predicate,target_system,target_entity_type,COUNT(*) mappings,SUM(match_type='EXACT' AND status='APPROVED') exact_approved,SUM(computation_eligible=1) computation_eligible FROM ilmb_entity_crosswalk WHERE source_system LIKE '%LOINC%' OR target_system LIKE '%LOINC%' OR source_system='SYS-001' OR target_system='SYS-001' GROUP BY source_system,source_entity_type,predicate,target_system,target_entity_type ORDER BY mappings DESC");
$out['loinc_crosswalk_routes']=$q->fetchAll();
$q=$pdo->query("SELECT mapping_id,source_system,source_entity_type,source_id,predicate,target_system,target_entity_type,target_id,evidence_source,evidence_version,evidence_locator,confidence FROM ilmb_entity_crosswalk WHERE computation_eligible=1 AND (source_system LIKE '%LOINC%' OR target_system LIKE '%LOINC%' OR source_system='SYS-001' OR target_system='SYS-001') ORDER BY mapping_id LIMIT 20");
$out['eligible_mapping_samples']=$q->fetchAll();
$q=$pdo->query("SELECT system_id,entity_type,COUNT(*) endpoint_count FROM ilmb_crosswalk_endpoint WHERE system_id IN ('LOINC','CHEBI') GROUP BY system_id,entity_type ORDER BY system_id,entity_type");$out['endpoint_counts']=$q->fetchAll();
$q=$pdo->query("SELECT source_id,target_id,source_endpoint_resolved,target_endpoint_resolved,match_type,status,computation_eligible FROM ilmb_entity_crosswalk WHERE source_system='LOINC' AND target_system='CHEBI' ORDER BY mapping_id LIMIT 10");$out['crosswalk_identifier_samples']=$q->fetchAll();
$q=$pdo->query("SELECT source_key,JSON_KEYS(payload_json) payload_keys,COALESCE(JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.chebi_id')),JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.CHEBI_ID')),JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.id')),JSON_UNQUOTE(JSON_EXTRACT(payload_json,'$.ID'))) payload_id FROM ilmb_canonical_record WHERE system_id='REF-CHEBI' AND sheet_name='Entities' AND active=1 LIMIT 10");$out['chebi_identity_samples']=$q->fetchAll();
$q=$pdo->query("SELECT metric_key,metric_name,metric_class,expression_text,input_contract,output_unit,minimum_observations,meaning_text,limitation_text,frontend_label FROM ilb_metric_definition WHERE status='active' ORDER BY metric_key");
$out['active_metrics']=$q->fetchAll();
$q=$pdo->prepare("SELECT table_name,column_name,column_type FROM information_schema.columns WHERE table_schema=? AND (LOWER(table_name) LIKE '%formula%' OR LOWER(table_name) LIKE '%reference%' OR LOWER(table_name) LIKE '%observation%' OR LOWER(table_name) LIKE '%laboratory%') ORDER BY table_name,ordinal_position");
$q->execute([$db]); $out['candidate_columns']=$q->fetchAll();
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
