<?php
declare(strict_types=1);

/** Import the source-first COSMOS_* workbook layer into Saral Pavan MariaDB. */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

function fail(string $message, int $code = 1): never { fwrite(STDERR, "ERROR: {$message}\n"); exit($code); }
function clean(mixed $value): ?string { $value = trim((string)$value); return $value === '' ? null : $value; }
function colNo(string $ref): int { preg_match('/[A-Z]+/', $ref, $m); $n=0; foreach(str_split($m[0]??'A') as $c)$n=$n*26+ord($c)-64; return $n; }
function textCell(SimpleXMLElement $c, array $shared): string { $a=$c->attributes();$t=(string)($a['t']??'');$values=$c->xpath('./*[local-name()="v"]');$value=(string)(($values?:[])[0]??'');if($t==='s')return $shared[(int)$value]??'';if($t==='inlineStr'){$parts=$c->xpath('.//*[local-name()="t"]');return implode('',array_map('strval',$parts?:[]));}return $value; }
function readXlsx(string $path): array {
    if (!class_exists('ZipArchive')) fail('PHP ZipArchive is required.');
    $z=new ZipArchive(); if($z->open($path)!==true) fail('Workbook cannot be opened.');
    $shared=[]; if(($s=$z->getFromName('xl/sharedStrings.xml'))!==false){$x=simplexml_load_string($s);$x->registerXPathNamespace('m','http://schemas.openxmlformats.org/spreadsheetml/2006/main');foreach($x->xpath('//m:si') as $si){$parts=$si->xpath('.//*[local-name()="t"]');$shared[]=implode('',array_map('strval',$parts?:[]));}}
    $wb=simplexml_load_string((string)$z->getFromName('xl/workbook.xml'));$wb->registerXPathNamespace('m','http://schemas.openxmlformats.org/spreadsheetml/2006/main');
    $rels=simplexml_load_string((string)$z->getFromName('xl/_rels/workbook.xml.rels'));$rels->registerXPathNamespace('r','http://schemas.openxmlformats.org/package/2006/relationships');$targets=[];foreach($rels->xpath('//r:Relationship') as $r)$targets[(string)$r['Id']]=(string)$r['Target'];
    $out=[];foreach($wb->xpath('//m:sheet') as $sheet){$a=$sheet->attributes();$ra=$sheet->attributes('http://schemas.openxmlformats.org/officeDocument/2006/relationships');$rid=(string)$ra['id'];$raw=$targets[$rid]??'';$target=str_starts_with($raw,'/')?ltrim($raw,'/'):'xl/'.ltrim($raw,'/');$xml=$z->getFromName($target);if($xml===false)continue;$x=simplexml_load_string($xml);$x->registerXPathNamespace('m','http://schemas.openxmlformats.org/spreadsheetml/2006/main');$rows=[];foreach($x->xpath('//m:sheetData/m:row') as $row){$cells=[];foreach($row->xpath('./*[local-name()="c"]') as $cell)$cells[colNo((string)$cell['r'])]=textCell($cell,$shared);if($cells){$line=[];for($i=1;$i<=max(array_keys($cells));$i++)$line[]=$cells[$i]??'';$rows[]=$line;}}$out[(string)$a['name']]=$rows;}
    $z->close();return $out;
}

$options=getopt('', ['workbook:','private-root:']);
$workbook=(string)($options['workbook']??'');
$root=rtrim((string)($options['private-root']??dirname(__DIR__,2).'/saralpavan_private'),'/');
if(!is_readable($workbook))fail('Workbook is not readable.',2);
$configPath=$root.'/config.php';if(!is_readable($configPath))fail('Private config is missing.',2);$config=require $configPath;
$db=$config['db']??[];foreach(['host','name','user','pass','charset'] as $key)if(!isset($db[$key]))fail('Incomplete DB config.',2);
if($db['name']!=='u756742628_saralpavan')fail('Refusing non-Saral-Pavan database.',2);
$pdo=new PDO(sprintf('mysql:host=%s;dbname=%s;charset=%s',$db['host'],$db['name'],$db['charset']),$db['user'],$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_EMULATE_PREPARES=>false]);
$book=readXlsx($workbook);
foreach(['COSMOS_CONTROL','COSMOS_IMPORT','C18_BIBLIOGRAPHY','C20_EOP_RECORD'] as $required)if(!isset($book[$required]))fail("Missing required cosmos sheet: {$required}");
$allowed=[];foreach(array_slice($book['COSMOS_IMPORT'],1) as $row){$sheet=clean($row[1]??null);$table=clean($row[2]??null);$mode=strtoupper((string)($row[3]??''));$status=strtoupper((string)($row[5]??''));if(!$sheet||!$table||$mode!=='UPSERT'||$status!=='READY')continue;if(!preg_match('/^C\d{2}_[A-Z0-9_]+$/',$sheet)||!preg_match('/^sp_cosmos_[a-z0-9_]+$/',$table))fail('Unsafe import manifest entry.');$allowed[$sheet]=$table;}
$batch008=[
    'C24_HORIZONS_REQUEST'=>'sp_cosmos_horizons_request',
    'C25_HORIZONS_RESPONSE'=>'sp_cosmos_horizons_response',
    'C26_EPHEMERIS_STATE'=>'sp_cosmos_ephemeris_state',
    'C27_GEOMETRY_EQUATIONS'=>'sp_cosmos_equation',
    'C28_EVENT_DEFINITION'=>'sp_cosmos_event_definition',
    'C29_UNCERTAINTY_RULE'=>'sp_cosmos_uncertainty_rule',
    'C30_DATA_LINEAGE'=>'sp_cosmos_data_lineage',
    'C31_VALIDATION_RECORD'=>'sp_cosmos_validation_record',
];
foreach($batch008 as $sheet=>$table){if(!isset($book[$sheet]))fail("Missing Batch 008 sheet: {$sheet}");$allowed[$sheet]=$table;}
$batch009=[
    'C32_FREEZE_KERNEL'=>'sp_cosmos_freeze_kernel',
    'C33_SPICE_VALIDATION'=>'sp_cosmos_spice_validation',
    'C34_COVERAGE_EXCEPTION'=>'sp_cosmos_coverage_exception',
    'C35_OBSERVER_REQUEST'=>'sp_cosmos_observer_request',
    'C36_OBSERVER_RESPONSE'=>'sp_cosmos_observer_response',
    'C37_APPARENT_OBSERVATION'=>'sp_cosmos_apparent_observation',
    'C38_FREEZE_MANIFEST'=>'sp_cosmos_freeze_manifest',
];
foreach($batch009 as $sheet=>$table){if(!isset($book[$sheet]))fail("Missing Batch 009 freeze sheet: {$sheet}");$allowed[$sheet]=$table;}
if(count($allowed)<39)fail('COSMOS_IMPORT must contain at least 39 READY mappings; parsed '.count($allowed).'.');
$rowsWritten=0;$pdo->beginTransaction();
try{
    foreach($allowed as $sheet=>$table){
        $rows=$book[$sheet]??null;if(!$rows)fail("Missing mapped sheet: {$sheet}");
        $headers=array_map(fn($v)=>strtolower(trim((string)$v)),$rows[0]);
        $columns=[];foreach($pdo->query("DESCRIBE `{$table}`") as $meta)$columns[(string)$meta['Field']]=true;
        $indexes=[];foreach($headers as $i=>$header)if(isset($columns[$header])&&preg_match('/^[a-z][a-z0-9_]*$/',$header))$indexes[$i]=$header;
        if(!$indexes)fail("No compatible columns for {$sheet} -> {$table}");
        $names=array_values($indexes);$quoted=array_map(fn($v)=>"`{$v}`",$names);$updates=array_map(fn($v)=>"`{$v}`=VALUES(`{$v}`)",$names);
        $sql='INSERT INTO `'.$table.'` ('.implode(',',$quoted).') VALUES ('.implode(',',array_fill(0,count($names),'?')).') ON DUPLICATE KEY UPDATE '.implode(',',$updates);
        $statement=$pdo->prepare($sql);
        foreach(array_slice($rows,1) as $row){$values=[];$hasValue=false;foreach($indexes as $i=>$name){$value=clean($row[$i]??null);$values[]=$value;if($value!==null)$hasValue=true;}if(!$hasValue)continue;$statement->execute($values);$rowsWritten++;}
    }
    $pdo->commit();
}catch(Throwable $e){if($pdo->inTransaction())$pdo->rollBack();throw $e;}
$syncId=bin2hex(random_bytes(16));$hash=hash_file('sha256',$workbook);
$statement=$pdo->prepare('INSERT INTO cg_workbook_sync(sync_id,direction,drive_file_id,workbook_name,workbook_sha256,status,rows_written,completed_at) VALUES(?,?,?,?,?,?,?,UTC_TIMESTAMP())');
$statement->execute([$syncId,'INTAKE_TO_MARIADB',$config['drive']['master_file_id']??null,basename($workbook),$hash,'IMPORTED',$rowsWritten]);
echo "COSMOS IMPORTED {$rowsWritten} rows; SHA256 {$hash}; sync {$syncId}\n";
