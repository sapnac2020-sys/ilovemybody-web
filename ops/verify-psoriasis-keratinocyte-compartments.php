<?php
require_once __DIR__ . '/../backend/db.php';
header('Content-Type: application/json');
$out=['ok'=>false,'stage'=>'init'];
try {
    $sql=file_get_contents(__DIR__.'/../backend/phase_118_psoriasis_keratinocyte_compartments.sql');
    if($sql===false) throw new RuntimeException('Cannot read Phase 118 SQL');
    $parts=array_filter(array_map('trim',preg_split('/;\s*(?:\r?\n|$)/',$sql)));
    $stmtNo=0;
    foreach($parts as $stmt){
        $stmtNo++;
        try {$pdo->exec($stmt);} catch(Throwable $e){
            $out=['ok'=>false,'stage'=>'migration','statement_no'=>$stmtNo,'statement_head'=>substr(preg_replace('/\s+/',' ',$stmt),0,220),'exception'=>$e->getMessage()];
            echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
        }
    }
    $r=$pdo->query('SELECT * FROM v_ilb_psoriasis_compartment_model_readiness')->fetch(PDO::FETCH_ASSOC);
    if((int)$r['compartment_count']!==5) throw new RuntimeException('Expected 5 keratinocyte compartments');
    if((int)$r['equation_count']!==7) throw new RuntimeException('Expected 7 compartment equations');
    $bad=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_compartment_response_rule WHERE compartment_code='KSC' AND signal_code='IL17A' AND response_dimension='PROLIFERATION' AND direction='INCREASES'")->fetchColumn();
    if($bad!==0) throw new RuntimeException('Unsafe universal IL-17A -> KSC proliferation rule detected');
    $out=['ok'=>true,'stage'=>'complete','database'=>$pdo->query('SELECT DATABASE()')->fetchColumn(),'migration_statements'=>$stmtNo,'readiness'=>$r,'scientific_boundary'=>'Whole-epidermis hyperplasia may increase while individual keratinocyte subpopulations show distinct or opposing proliferative responses.'];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
} catch(Throwable $e){
    $out=['ok'=>false,'stage'=>'fatal','exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES); exit(1);
}
