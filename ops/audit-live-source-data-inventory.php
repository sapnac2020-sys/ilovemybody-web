<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
try {
  if (PHP_SAPI !== 'cli') throw new RuntimeException('CLI required');
  $config=$argv[1]??''; if (!is_file($config)) throw new RuntimeException('Config file not found');
  $c=require $config; if(isset($c['database'])) $c=$c['database'];
  $db=$c['db']??$c['name']??''; if($db!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
  $pdo=new PDO("mysql:host={$c['host']};port=".($c['port']??3306).";dbname=$db;charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $tables=$pdo->query("SELECT table_name, table_type FROM information_schema.tables WHERE table_schema=DATABASE() ORDER BY table_name")->fetchAll(PDO::FETCH_ASSOC);
  $registry=[];
  try { foreach($pdo->query("SELECT object_name,domain_key,canonical_role,decision_note,release_key FROM ilb_backend_object_registry")->fetchAll(PDO::FETCH_ASSOC) as $r) $registry[$r['object_name']]=$r; } catch(Throwable $e) {}
  $out=['database'=>$db,'objects_total'=>count($tables),'tables'=>0,'views'=>0,'registered_objects'=>0,'unregistered_objects'=>0,'objects'=>[]];
  foreach($tables as $t) {
    $name=$t['table_name']; $type=$t['table_type']; $isTable=$type==='BASE TABLE';
    $rows=null;
    if($isTable) { $out['tables']++; $q=chr(96).str_replace(chr(96),chr(96).chr(96),$name).chr(96); $rows=(int)$pdo->query('SELECT COUNT(*) FROM '.$q)->fetchColumn(); } else $out['views']++;
    $r=$registry[$name]??null; if($r) $out['registered_objects']++; else $out['unregistered_objects']++;
    $out['objects'][]=['name'=>$name,'type'=>$type,'rows'=>$rows,'registered'=>$r!==null,'domain'=>$r['domain_key']??null,'role'=>$r['canonical_role']??null,'release'=>$r['release_key']??null];
  }
  echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
} catch(Throwable $e) { fwrite(STDOUT,'INVENTORY_ERROR: '.$e->getMessage().PHP_EOL); exit(1); }
