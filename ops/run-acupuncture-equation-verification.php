<?php
declare(strict_types=1);
error_reporting(E_ALL);
ini_set('display_errors', 'stderr');
set_exception_handler(static function (Throwable $e): void {
    fwrite(STDERR, json_encode(['verified'=>false,'error_type'=>get_class($e),'error_message'=>$e->getMessage()], JSON_PRETTY_PRINT).PHP_EOL);
    exit(70);
});
if ($argc !== 3) { fwrite(STDERR, "Usage: php {$argv[0]} <config.php> <migration.sql>\n"); exit(64); }
$c=require $argv[1]; $sql=file_get_contents($argv[2]);
if (!is_array($c) || $sql===false) throw new RuntimeException('Configuration or migration unavailable.');
if (isset($c['dsn'],$c['username'],$c['password'])) {
    $dsn=(string)$c['dsn']; $user=(string)$c['username']; $pass=(string)$c['password'];
} elseif (isset($c['host'],$c['db'],$c['user'],$c['pass'])) {
    $dsn=sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',(string)$c['host'],isset($c['port'])?(int)$c['port']:3306,(string)$c['db'],isset($c['charset'])?(string)$c['charset']:'utf8mb4');
    $user=(string)$c['user']; $pass=(string)$c['pass'];
} else throw new RuntimeException('Unsupported configuration contract.');
$options=[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION];
if (!empty($c['init_command']) && defined('PDO::MYSQL_ATTR_INIT_COMMAND')) $options[PDO::MYSQL_ATTR_INIT_COMMAND]=(string)$c['init_command'];
$pdo=new PDO($dsn,$user,$pass,$options);
$pdo->exec($sql);
$summary=$pdo->query('SELECT * FROM v_ilb_acupuncture_equation_verification_summary')->fetch(PDO::FETCH_ASSOC);
$details=$pdo->query('SELECT equation_key,mathematical_status,acupuncture_input_status,operational_status FROM v_ilb_acupuncture_equation_verification ORDER BY equation_key')->fetchAll(PDO::FETCH_ASSOC);
$ok=$summary && (int)$summary['active_equation_count']===11 && (int)$summary['mathematically_verified_count']===11 && (int)$summary['operationally_evaluable_count']===5 && (int)$summary['operationally_blocked_count']===6 && (int)$summary['missing_verification_count']===0;
echo json_encode(['migration'=>'phase_74_acupuncture_equation_verification','verified'=>$ok,'summary'=>$summary,'equations'=>$details],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
exit($ok?0:65);

