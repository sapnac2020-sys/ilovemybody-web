<?php
declare(strict_types=1);
// Post-hard-clean verification refresh: 2026-09-13.

function rows(PDO $pdo, string $sql): array { return $pdo->query($sql)->fetchAll(PDO::FETCH_ASSOC); }
function scalar(PDO $pdo, string $sql): int { return (int)$pdo->query($sql)->fetchColumn(); }
function existsTable(PDO $pdo, string $name): bool {
  $s=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
  $s->execute([$name]); return (int)$s->fetchColumn()===1;
}
function scanFiles(string $root, int $limit=5000): array {
  $out=[]; if(!is_dir($root)) return $out;
  $it=new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS));
  foreach($it as $f){
    if(count($out)>=$limit || !$f->isFile()) break;
    $path=$f->getPathname(); $size=$f->getSize();
    $ext=strtolower(pathinfo($path,PATHINFO_EXTENSION));
    if(!in_array($ext,['php','html','htm','js','css','json','xlsx','xls','csv','md','txt','sql'],true)) continue;
    $out[]=[
      'path'=>$path,'relative'=>ltrim(str_replace($root,'',$path),'/'),
      'size'=>$size,'mtime'=>gmdate('c',$f->getMTime()),
      'sha256'=>$size<=20*1024*1024 ? hash_file('sha256',$path) : null,
      'suspicious_name'=>(bool)preg_match('/(^|[._-])(old|bak|backup|copy|temp|tmp|test|legacy|archive|v[0-9]+)([._-]|$)/i',basename($path))
    ];
  }
  return $out;
}
function duplicateFileGroups(array $files): array {
  $g=[]; foreach($files as $f){ if(!$f['sha256']) continue; $g[$f['sha256']][]=$f; }
  return array_values(array_filter($g,fn($x)=>count($x)>1));
}

try{
  if($argc<2) throw new RuntimeException('Usage: php duplicate-connectivity-audit.php CONFIG');
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $db=$c['db']??$c['name']??null; if(!$db) throw new RuntimeException('Database name missing');
  $pdo=new PDO("mysql:host={$c['host']};dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
  $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE,PDO::FETCH_ASSOC);

  $tables=rows($pdo,"SELECT table_name,table_type,engine,table_rows,create_time,update_time FROM information_schema.tables WHERE table_schema=DATABASE() ORDER BY table_name");
  $fkRows=rows($pdo,"SELECT table_name,referenced_table_name,COUNT(*) column_count FROM information_schema.key_column_usage WHERE table_schema=DATABASE() AND referenced_table_name IS NOT NULL GROUP BY table_name,referenced_table_name");
  $outFk=[];$inFk=[]; foreach($fkRows as $r){$outFk[$r['table_name']]=($outFk[$r['table_name']]??0)+(int)$r['column_count'];$inFk[$r['referenced_table_name']]=($inFk[$r['referenced_table_name']]??0)+(int)$r['column_count'];}
  $base=[];$empty=[];$disconnected=[];$suspicious=[];
  foreach($tables as $t){
    if($t['table_type']!=='BASE TABLE') continue;
    $name=$t['table_name'];$rowCount=(int)($t['table_rows']??0);$in=$inFk[$name]??0;$out=$outFk[$name]??0;
    $item=$t+['incoming_fk_columns'=>$in,'outgoing_fk_columns'=>$out];$base[]=$item;
    if($rowCount===0) $empty[]=$item;
    if($in===0 && $out===0) $disconnected[]=$item;
    if(preg_match('/(^|_)(old|bak|backup|copy|temp|tmp|test|legacy|archive|v[0-9]+)($|_)/i',$name)) $suspicious[]=$item;
  }

  $columnSigs=rows($pdo,"SELECT table_name, SHA2(GROUP_CONCAT(CONCAT_WS(':',ordinal_position,column_name,column_type,is_nullable,COALESCE(column_default,''),extra) ORDER BY ordinal_position SEPARATOR '|'),256) signature FROM information_schema.columns WHERE table_schema=DATABASE() GROUP BY table_name ORDER BY table_name");
  $sigGroups=[]; foreach($columnSigs as $r){$sigGroups[$r['signature']][]=$r['table_name'];}
  $duplicateSchemas=[]; foreach($sigGroups as $sig=>$names){ if(count($names)>1) $duplicateSchemas[]=['signature'=>$sig,'tables'=>$names]; }

  $viewRows=rows($pdo,"SELECT table_name,MD5(view_definition) definition_hash FROM information_schema.views WHERE table_schema=DATABASE() ORDER BY table_name");
  $viewGroups=[];foreach($viewRows as $r){$viewGroups[$r['definition_hash']][]=$r['table_name'];}
  $duplicateViews=[];foreach($viewGroups as $h=>$names){if(count($names)>1)$duplicateViews[]=['definition_hash'=>$h,'views'=>$names];}

  $formulaDupes=existsTable($pdo,'ilmb_formula_duplicate_candidate')?scalar($pdo,"SELECT COUNT(*) FROM ilmb_formula_duplicate_candidate WHERE disposition='OPEN'"):0;
  $parameterDupes=existsTable($pdo,'ilmb_parameter_duplicate_candidate')?scalar($pdo,"SELECT COUNT(*) FROM ilmb_parameter_duplicate_candidate WHERE disposition='OPEN'"):0;

  $home=getenv('HOME')?:'';
  $exchangeFiles=scanFiles($home.'/ilmb-data-exchange');
  $publicFiles=scanFiles($home.'/domains/ilovemybody.in/public_html');
  $exchangeDupes=duplicateFileGroups($exchangeFiles);
  $publicDupes=duplicateFileGroups($publicFiles);
  $exchangeSusp=array_values(array_filter($exchangeFiles,fn($f)=>$f['suspicious_name']));
  $publicSusp=array_values(array_filter($publicFiles,fn($f)=>$f['suspicious_name']));

  $manifestRefs=[];
  foreach($exchangeFiles as $f){
    if(strtolower(basename($f['path']))!=='manifest.json') continue;
    $j=json_decode(@file_get_contents($f['path']),true); if(!is_array($j)) continue;
    $flat=new RecursiveIteratorIterator(new RecursiveArrayIterator($j));
    foreach($flat as $v){if(is_string($v) && preg_match('/\.(xlsx|xls|csv|json)$/i',$v))$manifestRefs[basename($v)]=true;}
  }
  $exchangeDisconnected=[];
  foreach($exchangeFiles as $f){
    $ext=strtolower(pathinfo($f['path'],PATHINFO_EXTENSION));
    if(in_array($ext,['xlsx','xls','csv'],true) && !isset($manifestRefs[basename($f['path'])])) $exchangeDisconnected[]=$f;
  }

  $result=[
    'generated_at_utc'=>gmdate('c'),'schema'=>$db,
    'summary'=>[
      'objects'=>count($tables),'base_tables'=>count($base),'views'=>count($viewRows),
      'empty_base_tables'=>count($empty),'fk_disconnected_base_tables'=>count($disconnected),
      'suspicious_named_tables'=>count($suspicious),'duplicate_schema_groups'=>count($duplicateSchemas),
      'duplicate_view_definition_groups'=>count($duplicateViews),'open_parameter_duplicates'=>$parameterDupes,'open_formula_duplicates'=>$formulaDupes,
      'exchange_files'=>count($exchangeFiles),'exchange_duplicate_file_groups'=>count($exchangeDupes),'exchange_unreferenced_excel_csv'=>count($exchangeDisconnected),
      'public_files_scanned'=>count($publicFiles),'public_duplicate_file_groups'=>count($publicDupes),'public_suspicious_named_files'=>count($publicSusp)
    ],
    'database'=>[
      'empty_base_tables'=>$empty,'fk_disconnected_base_tables'=>$disconnected,'suspicious_named_tables'=>$suspicious,
      'duplicate_schema_groups'=>$duplicateSchemas,'duplicate_view_definition_groups'=>$duplicateViews
    ],
    'files'=>[
      'exchange_duplicate_groups'=>$exchangeDupes,'exchange_unreferenced_excel_csv'=>$exchangeDisconnected,'exchange_suspicious_names'=>$exchangeSusp,
      'public_duplicate_groups'=>$publicDupes,'public_suspicious_names'=>$publicSusp
    ],
    'safety_note'=>'Candidates only. No database rows or files were modified.'
  ];
  echo json_encode($result,JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT),PHP_EOL;
}catch(Throwable $e){fwrite(STDERR,'AUDIT_ERROR: '.$e->getMessage().PHP_EOL);exit(1);}