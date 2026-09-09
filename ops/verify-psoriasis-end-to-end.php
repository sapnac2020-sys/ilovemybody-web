<?php
require_once __DIR__ . '/../backend/db.php';
header('Content-Type: application/json');
$out=['ok'=>false,'stage'=>'init'];
try {
    $sql=file_get_contents(__DIR__.'/../backend/phase_117_psoriasis_end_to_end_closure.sql');
    if($sql===false) throw new RuntimeException('Cannot read Phase 117 SQL');
    $parts=array_filter(array_map('trim',preg_split('/;\s*(?:\r?\n|$)/',$sql)));
    $stmtNo=0;
    foreach($parts as $stmt){
        $stmtNo++;
        try { $pdo->exec($stmt); }
        catch(Throwable $e){
            $out=['ok'=>false,'stage'=>'migration','statement_no'=>$stmtNo,'statement_head'=>substr(preg_replace('/\s+/',' ',$stmt),0,240),'exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
            echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
        }
    }
    $required=['ilb_psoriasis_episode','ilb_psoriasis_safety_screen','ilb_psoriasis_baseline_state','ilb_psoriasis_intervention_plan','ilb_psoriasis_intervention_plan_item','ilb_psoriasis_model_prediction','ilb_psoriasis_outcome_checkpoint','ilb_psoriasis_prediction_verification','ilb_psoriasis_project_gate'];
    foreach($required as $t){
        $q=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
        $q->execute([$t]);
        if((int)$q->fetchColumn()!==1) throw new RuntimeException("Missing table: $t");
    }
    $r=$pdo->query("SELECT * FROM v_ilb_psoriasis_project_readiness")->fetch(PDO::FETCH_ASSOC);
    $gates=$pdo->query("SELECT gate_code,gate_status,reason_text FROM ilb_psoriasis_project_gate ORDER BY gate_order")->fetchAll(PDO::FETCH_ASSOC);
    if((int)$r['gate_count']!==8) throw new RuntimeException('Expected 8 project gates');
    if((int)$r['fail_count']!==0) throw new RuntimeException('Project gate failure present');
    $out=['ok'=>true,'stage'=>'complete','database'=>$pdo->query('SELECT DATABASE()')->fetchColumn(),'migration_statements'=>$stmtNo,'readiness'=>$r,'gates'=>$gates,'rule'=>'DERIVE -> PREDICT -> VERIFY; external modality workbooks remain verification-only; universal alternate cure claim remains blocked.'];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
} catch(Throwable $e){
    $out=['ok'=>false,'stage'=>'fatal','exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
}
