<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
$config=require($argv[1]??'');
$db=is_array($config['db']??null)?$config['db']:['host'=>$config['host']??null,'port'=>$config['port']??3306,'name'=>$config['db']??null,'user'=>$config['user']??null,'pass'=>$config['pass']??null,'charset'=>$config['charset']??'utf8mb4'];
if(($db['name']??'')!==EXPECTED_DATABASE)throw new RuntimeException('Refusing non-ILMB database.');
$pdo=new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$db['host'],$db['port']??3306,EXPECTED_DATABASE,$db['charset']??'utf8mb4'),(string)$db['user'],(string)$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$sql=file_get_contents($argv[2]??'');if(!$sql)throw new RuntimeException('Migration empty.');$s=$pdo->prepare($sql);$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());
$r=$pdo->query('SELECT * FROM v_ilb_psoriasis_input_readiness')->fetch(PDO::FETCH_ASSOC);
if((int)$r['input_definitions']!==40||(int)$r['parameter_definitions']!==21||(int)$r['missing_parameters']!==21||(int)$r['blocking_gates']!==10)throw new RuntimeException('Input-contract counts failed: '.json_encode($r));
if($r['readiness_status']!=='BLOCKED_COLLECTION_REQUIRED')throw new RuntimeException('Unsafe readiness state.');
echo json_encode(['database'=>EXPECTED_DATABASE,'input_contract'=>$r,'release_rule'=>'Collection, validation and clinician approval are mandatory.'],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
