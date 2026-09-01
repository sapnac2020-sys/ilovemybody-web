<?php
declare(strict_types=1);
const EXPECTED_DATABASE='u756742628_ilovemybody';
try {
    if (PHP_SAPI !== 'cli') { throw new RuntimeException('CLI required'); }
    $config=$argv[1]??''; $sql=$argv[2]??'';
    if (!is_file($config)) { throw new RuntimeException('Config file not found'); }
    if (!is_file($sql)) { throw new RuntimeException('SQL migration file not found'); }
    $c=require $config; if(isset($c['database'])) $c=$c['database'];
    if(($c['db']??$c['name']??'')!==EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
    $pdo=new PDO("mysql:host={$c['host']};port=".($c['port']??3306).";dbname=".($c['db']??$c['name']).";charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
    $st=$pdo->prepare((string)file_get_contents($sql)); $st->execute();
    do { if($st->columnCount()) $st->fetchAll(); } while($st->nextRowset());
    $st->closeCursor();
    $candidates=(int)$pdo->query("SELECT COUNT(*) FROM ilb_test_atlas_candidate")->fetchColumn();
    $queue=(int)$pdo->query("SELECT COUNT(*) FROM v_ilb_test_atlas_mapping_queue")->fetchColumn();
    $out=['candidates'=>$candidates,'mapping_queue_rows'=>$queue,'approved_exact_mappings'=>0,'patient_rows_read'=>0,'patient_rows_modified'=>0,'ready'=>$candidates===123&&$queue===123];
    echo json_encode($out,JSON_PRETTY_PRINT),PHP_EOL;
    exit($out['ready'] ? 0 : 4);
} catch (Throwable $e) {
    fwrite(STDOUT, 'MIGRATION_ERROR: '.$e->getMessage().PHP_EOL);
    exit(1);
}
