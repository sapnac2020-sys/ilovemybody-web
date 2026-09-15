<?php
declare(strict_types=1);

/* Read-only audit: resolve Shlok Chaturvedi and retrieve existing governed measurements/scan-derived rows. */
$configPath = $argv[1] ?? '';
if ($configPath === '' || !is_file($configPath)) { fwrite(STDERR, "Config file not found.\n"); exit(2); }
$config = require $configPath;
$db = isset($config['db']) && is_array($config['db']) ? $config['db'] : $config;
if (!is_array($db)) { fwrite(STDERR, "Database configuration unavailable.\n"); exit(3); }
$dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $db['host'] ?? '127.0.0.1', (int)($db['port'] ?? 3306), $db['name'] ?? $db['db'] ?? '', $db['charset'] ?? 'utf8mb4');
$pdo = new PDO($dsn, $db['user'] ?? '', $db['pass'] ?? '', [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES=>false]);
$schema = (string)($db['name'] ?? $db['db'] ?? '');

function tableExists(PDO $pdo, string $schema, string $table): bool {
  $s=$pdo->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=? AND table_name=?'); $s->execute([$schema,$table]); return (int)$s->fetchColumn()>0;
}
function cols(PDO $pdo, string $schema, string $table): array {
  $s=$pdo->prepare('SELECT column_name FROM information_schema.columns WHERE table_schema=? AND table_name=? ORDER BY ordinal_position'); $s->execute([$schema,$table]); return array_column($s->fetchAll(),'column_name');
}
function qi(string $s): string { return '`'.str_replace('`','``',$s).'`'; }

$out=['generated_at_utc'=>gmdate('c'),'subject_candidates'=>[],'subject_key'=>null,'measurements'=>[],'scanner_tables'=>[],'scanner_rows'=>[],'notes'=>[]];
$keys=[];
if (tableExists($pdo,$schema,'ilb_subject_private_identity')) {
  $stmt=$pdo->prepare("SELECT subject_key, full_name, date_of_birth, access_class FROM ilb_subject_private_identity WHERE LOWER(full_name) LIKE '%shlok%' OR date_of_birth='1997-04-05' ORDER BY updated_at DESC");
  $stmt->execute(); $rows=$stmt->fetchAll(); $out['subject_candidates']=$rows; foreach($rows as $r){$keys[$r['subject_key']]=true;}
}
if (!$keys && tableExists($pdo,$schema,'ilb_subject_profile')) {
  $stmt=$pdo->query("SELECT subject_key, display_name FROM ilb_subject_profile WHERE LOWER(display_name) LIKE '%shlok%'");
  foreach($stmt->fetchAll() as $r){$keys[$r['subject_key']]=true; $out['subject_candidates'][]=$r;}
}
if (!$keys && tableExists($pdo,$schema,'ilb_subject')) {
  $stmt=$pdo->query("SELECT subject_key, birth_date FROM ilb_subject WHERE birth_date='1997-04-05'");
  foreach($stmt->fetchAll() as $r){$keys[$r['subject_key']]=true; $out['subject_candidates'][]=$r;}
}
$subjectKeys=array_keys($keys); $out['subject_key']=$subjectKeys[0] ?? null;

if ($subjectKeys && tableExists($pdo,$schema,'ilb_subject_measurement')) {
  $placeholders=implode(',',array_fill(0,count($subjectKeys),'?'));
  $sql="SELECT measurement_id,subject_key,snapshot_id,marker_key,reported_measurement_name,value_numeric,value_text,unit_text,measured_at,method_or_device,laboratory_or_source,verification_status FROM ilb_subject_measurement WHERE subject_key IN ($placeholders) ORDER BY measured_at DESC,measurement_id DESC";
  $stmt=$pdo->prepare($sql); $stmt->execute($subjectKeys); $out['measurements']=$stmt->fetchAll();
}

// Discover all likely scanner/body-geometry tables in the live schema.
$stmt=$pdo->prepare("SELECT table_name FROM information_schema.tables WHERE table_schema=? AND table_type='BASE TABLE' AND (LOWER(table_name) LIKE '%scan%' OR LOWER(table_name) LIKE '%body%measure%' OR LOWER(table_name) LIKE '%anthrop%' OR LOWER(table_name) LIKE '%landmark%' OR LOWER(table_name) LIKE '%segment%' OR LOWER(table_name) LIKE '%slice%' OR LOWER(table_name) LIKE '%shape%' OR LOWER(table_name) LIKE '%lattice%') ORDER BY table_name");
$stmt->execute([$schema]); $tables=array_column($stmt->fetchAll(),'table_name');
foreach($tables as $table){
  $columns=cols($pdo,$schema,$table); $out['scanner_tables'][]=['table'=>$table,'columns'=>$columns];
  if(!$subjectKeys) continue;
  $subjectCol=null; foreach(['subject_key','patient_key','person_key','subject_id','patient_id','person_id'] as $c){ if(in_array($c,$columns,true)){ $subjectCol=$c; break; } }
  if(!$subjectCol) continue;
  $placeholders=implode(',',array_fill(0,count($subjectKeys),'?'));
  try {
    $sql='SELECT * FROM '.qi($table).' WHERE '.qi($subjectCol)." IN ($placeholders) LIMIT 500";
    $q=$pdo->prepare($sql); $q->execute($subjectKeys); $rows=$q->fetchAll();
    if($rows) $out['scanner_rows'][$table]=$rows;
  } catch(Throwable $e){ $out['notes'][]="Could not read $table by $subjectCol: ".$e->getMessage(); }
}

// Also search text-like key columns in likely scanner tables for name/key variants when no direct subject match was found.
if (!$out['scanner_rows']) {
  $needles=array_values(array_filter(array_merge($subjectKeys,['Shlok Chaturvedi','Shlok','1997-04-05'])));
  foreach($tables as $table){
    $columns=cols($pdo,$schema,$table);
    $textCols=[];
    $meta=$pdo->prepare("SELECT column_name,data_type FROM information_schema.columns WHERE table_schema=? AND table_name=?"); $meta->execute([$schema,$table]);
    foreach($meta->fetchAll() as $m){ if(in_array(strtolower($m['data_type']),['varchar','char','text','tinytext','mediumtext','longtext','date'],true)) $textCols[]=$m['column_name']; }
    foreach(array_slice($textCols,0,12) as $c){
      foreach($needles as $needle){
        try{ $q=$pdo->prepare('SELECT * FROM '.qi($table).' WHERE CAST('.qi($c).' AS CHAR) LIKE ? LIMIT 100'); $q->execute(['%'.$needle.'%']); $rows=$q->fetchAll(); if($rows){$out['scanner_rows'][$table]=$rows; break 2;} }catch(Throwable $e){}
      }
    }
  }
}

echo json_encode($out, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE),"\n";
