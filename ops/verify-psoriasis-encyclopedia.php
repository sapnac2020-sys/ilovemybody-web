<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
$config=require($argv[1]??'');
$db=is_array($config['db']??null)?$config['db']:['host'=>$config['host']??null,'port'=>$config['port']??3306,'name'=>$config['db']??null,'user'=>$config['user']??null,'pass'=>$config['pass']??null,'charset'=>$config['charset']??'utf8mb4'];
if(($db['name']??'')!==EXPECTED_DATABASE)throw new RuntimeException('Refusing non-ILMB database.');
$pdo=new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$db['host'],$db['port']??3306,EXPECTED_DATABASE,$db['charset']??'utf8mb4'),(string)$db['user'],(string)$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$sql=file_get_contents($argv[2]??''); if(!$sql)throw new RuntimeException('Migration empty.');
try {
  $s=$pdo->prepare($sql); $s->execute(); do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());
} catch(Throwable $e) {
  fwrite(STDERR,"MIGRATION_ERROR: ".$e->getMessage()."\n");
  throw $e;
}
$r=$pdo->query('SELECT * FROM v_ilb_psoriasis_encyclopedia_readiness')->fetch(PDO::FETCH_ASSOC);
$expect=['phenotypes'=>7,'sites'=>6,'morphology_terms'=>12,'histopathology_features'=>12,'cells'=>12,'bioentities'=>20,'pathway_edges'=>20,'triggers'=>15,'comorbidities'=>10,'differentials'=>18,'measurement_tools'=>12,'treatment_classes'=>15,'medicine_refs'=>23,'modality_refs'=>12,'red_flags'=>7,'research_gaps'=>8,'sources'=>20,'encyclopedia_inputs'=>6];
foreach($expect as $k=>$v){ if((int)($r[$k]??-1)!==$v) throw new RuntimeException("Count check failed $k=".json_encode($r[$k]??null)." expected $v"); }
if(($r['readiness_status']??'')!=='FOUNDATION_READY')throw new RuntimeException('Safety readiness blocked: '.json_encode($r));
$gpp=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_phenotype WHERE phenotype_id='PSO-PH-004' AND safety_class LIKE 'URGENT%'")->fetchColumn();
$ery=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_phenotype WHERE phenotype_id='PSO-PH-007' AND safety_class LIKE 'URGENT%'")->fetchColumn();
if($gpp!==1||$ery!==1)throw new RuntimeException('Urgent phenotype safety labels missing.');
$emdr=$pdo->query("SELECT role_type,evidence_position,governance_rule FROM ilb_psoriasis_modality_reference WHERE modality_id='MOD-EMDR'")->fetch(PDO::FETCH_ASSOC);
if(!$emdr)throw new RuntimeException('EMDR encyclopedia reference missing.');
if(stripos((string)$emdr['governance_rule'],'not an IL-17')===false)throw new RuntimeException('EMDR direct-immune safety wording lost.');
echo json_encode(['database'=>EXPECTED_DATABASE,'phase'=>106,'encyclopedia'=>$r,'emdr_reference'=>$emdr,'safety'=>'GPP and erythrodermic red flags are urgent; encyclopedia facts do not create treatment or cure claims.'],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
