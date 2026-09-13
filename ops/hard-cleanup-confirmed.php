<?php
declare(strict_types=1);

function one(PDO $pdo, string $sql, array $args=[]): mixed {
    $s=$pdo->prepare($sql); $s->execute($args); return $s->fetchColumn();
}
function existsTable(PDO $pdo,string $name): bool {
    return (int)one($pdo,"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? AND table_type='BASE TABLE'",[$name])===1;
}
function dependencyCounts(PDO $pdo,string $name): array {
    $incoming=(int)one($pdo,"SELECT COUNT(*) FROM information_schema.key_column_usage WHERE referenced_table_schema=DATABASE() AND referenced_table_name=?",[$name]);
    $outgoing=(int)one($pdo,"SELECT COUNT(*) FROM information_schema.key_column_usage WHERE table_schema=DATABASE() AND table_name=? AND referenced_table_name IS NOT NULL",[$name]);
    $viewRefs=(int)one($pdo,"SELECT COUNT(*) FROM information_schema.views WHERE table_schema=DATABASE() AND LOWER(view_definition) LIKE ?",['%'.strtolower($name).'%']);
    $triggerRefs=(int)one($pdo,"SELECT COUNT(*) FROM information_schema.triggers WHERE trigger_schema=DATABASE() AND LOWER(action_statement) LIKE ?",['%'.strtolower($name).'%']);
    $routineRefs=(int)one($pdo,"SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema=DATABASE() AND LOWER(COALESCE(routine_definition,'')) LIKE ?",['%'.strtolower($name).'%']);
    return compact('incoming','outgoing','viewRefs','triggerRefs','routineRefs');
}

try {
    if ($argc < 2) throw new RuntimeException('Usage: php hard-cleanup-confirmed.php CONFIG');
    $config=require $argv[1]; if(isset($config['database']))$config=$config['database'];
    $db=$config['db']??$config['name']??null; if(!$db)throw new RuntimeException('Database name missing');
    $pdo=new PDO("mysql:host={$config['host']};dbname={$db};charset=utf8mb4",$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);

    // Explicit allow-list from the 2026-09-13 duplicate/connectivity audit.
    $candidates=['ilb_gita_formula_test'];
    $deleted=[]; $blocked=[];
    foreach($candidates as $name){
        if(!existsTable($pdo,$name)){ $blocked[]=['table'=>$name,'reason'=>'not_present']; continue; }
        $rows=(int)one($pdo,'SELECT COUNT(*) FROM `'.str_replace('`','``',$name).'`');
        $deps=dependencyCounts($pdo,$name);
        $depTotal=array_sum($deps);
        if($rows!==0 || $depTotal!==0){
            $blocked[]=['table'=>$name,'reason'=>'guard_failed','rows'=>$rows,'dependencies'=>$deps];
            continue;
        }
        $pdo->exec('DROP TABLE `'.str_replace('`','``',$name).'`');
        $deleted[]=['table'=>$name,'rows_before'=>0,'dependencies'=>$deps];
    }
    echo json_encode(['deleted'=>$deleted,'blocked'=>$blocked,'deleted_count'=>count($deleted),'blocked_count'=>count($blocked)],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
} catch(Throwable $e){ fwrite(STDERR,'HARD_CLEANUP_ERROR: '.$e->getMessage().PHP_EOL); exit(1); }
