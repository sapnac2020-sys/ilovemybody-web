<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
$stage='startup';
try {
    $configPath=$argv[1]??'';
    $migrationPath=$argv[2]??'';
    $stage='load_config';
    if($configPath==='' || !is_file($configPath)) throw new RuntimeException('Config file missing: '.$configPath);
    $config=require $configPath;
    $db=is_array($config['db']??null)?$config['db']:['host'=>$config['host']??null,'port'=>$config['port']??3306,'name'=>$config['db']??null,'user'=>$config['user']??null,'pass'=>$config['pass']??null,'charset'=>$config['charset']??'utf8mb4'];
    if(($db['name']??'')!==EXPECTED_DATABASE) throw new RuntimeException('Refusing non-ILMB database: '.($db['name']??'<missing>'));

    $stage='connect_database';
    $pdo=new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$db['host'],$db['port']??3306,EXPECTED_DATABASE,$db['charset']??'utf8mb4'),(string)$db['user'],(string)$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);

    $stage='load_migration';
    $sql=file_get_contents($migrationPath);
    if(!$sql) throw new RuntimeException('Migration empty or unreadable: '.$migrationPath);

    $stage='apply_migration';
    $s=$pdo->prepare($sql);$s->execute();do{if($s->columnCount())$s->fetchAll();}while($s->nextRowset());

    $stage='read_readiness_view';
    $r=$pdo->query("SELECT * FROM v_ilb_emdr_psoriasis_modality")->fetch(PDO::FETCH_ASSOC);
    if(!$r) throw new RuntimeException('EMDR modality view missing.');
    if($r['modality_code']!=='EMDR') throw new RuntimeException('Wrong modality code.');
    if($r['psoriasis_role']!=='UPSTREAM_MODIFIER') throw new RuntimeException('Unsafe psoriasis role.');
    if((int)$r['pathway_links']!==5) throw new RuntimeException('Expected 5 pathway links: '.json_encode($r));
    if((int)$r['protocol_steps']!==8) throw new RuntimeException('Expected 8 protocol steps: '.json_encode($r));
    if((int)$r['measurement_links']!==8) throw new RuntimeException('Expected 8 measurement links: '.json_encode($r));
    if((int)$r['evidence_records']!==4) throw new RuntimeException('Expected 4 evidence records: '.json_encode($r));
    if((int)$r['hypothesis_links']<3) throw new RuntimeException('Hypothesis labelling lost: '.json_encode($r));

    $stage='verify_inputs';
    $inputs=(int)$pdo->query("SELECT COUNT(*) FROM ilb_model_input_definition WHERE model_code='PSO_COP_LIFESTYLE_V4' AND category_code IN ('EMDR','AUTONOMIC') AND input_code IN ('EMDR_TARGET_LABEL','EMDR_SUD','EMDR_VOC','EMDR_BODY_SENSATION','HRV_RMSSD','EMDR_SESSION_STATUS')")->fetchColumn();
    if($inputs!==6) throw new RuntimeException('EMDR input definitions incomplete: '.$inputs);

    $stage='verify_safety_claims';
    $direct=(int)$pdo->query("SELECT COUNT(*) FROM ilb_modality_pathway_link p JOIN ilb_modality_definition m ON m.modality_id=p.modality_id WHERE m.modality_code='EMDR' AND p.disease_code='PSO-001' AND p.target_node_code='I4' AND p.relation_type<>'HYPOTHESIZED_DOWNSTREAM_EFFECT'")->fetchColumn();
    if($direct!==0) throw new RuntimeException('Unsafe direct IL-17 claim detected.');

    echo json_encode(['ok'=>true,'stage'=>'complete','database'=>EXPECTED_DATABASE,'emdr_modality'=>$r,'emdr_inputs'=>$inputs,'safety_rule'=>'EMDR is stored as a separate upstream-modifier modality; downstream psoriasis effects remain evidence-labelled hypotheses until measured.'],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
} catch(Throwable $e) {
    $payload=['ok'=>false,'stage'=>$stage,'exception'=>get_class($e),'message'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
    fwrite(STDERR,"EMDR_VERIFIER_FAILURE ".json_encode($payload,JSON_UNESCAPED_SLASHES)."\n");
    exit(1);
}
