<?php
declare(strict_types=1);
try {
    if ($argc < 3) throw new RuntimeException('Usage: php run-body-need-input-links.php CONFIG SQL_FILE');
    $config=require $argv[1]; if(isset($config['database']))$config=$config['database'];
    $dbName=$config['db']??$config['name']??null; if(!$dbName)throw new RuntimeException('Database name missing');
    $pdo=new PDO("mysql:host={$config['host']};dbname={$dbName};charset=utf8mb4",$config['user'],$config['pass']??$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
    $sql=file_get_contents($argv[2]); if($sql===false||trim($sql)==='')throw new RuntimeException('Input-link SQL missing');
    $stmt=$pdo->prepare($sql); $stmt->execute(); do{if($stmt->columnCount())$stmt->fetchAll();}while($stmt->nextRowset());
    $count=(int)$pdo->query('SELECT COUNT(*) FROM ilmb_formula_input')->fetchColumn();
    echo json_encode(['case_formula_input_links'=>$count,'patient_rows_modified'=>0],JSON_UNESCAPED_SLASHES),PHP_EOL;
} catch(Throwable $e){echo 'BODY_NEED_INPUT_LINK_ERROR: '.$e->getMessage(),PHP_EOL;exit(1);}
