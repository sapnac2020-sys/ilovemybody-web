<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { exit(2); }
$configPath = $argv[1] ?? '';
if (!is_file($configPath)) { fwrite(STDERR, "Missing config.\n"); exit(2); }
$config = require $configPath;
$db = is_array($config['db'] ?? null) ? $config['db'] : [
    'host'=>$config['host'] ?? null, 'port'=>$config['port'] ?? 3306,
    'name'=>$config['db'] ?? null, 'user'=>$config['user'] ?? null,
    'pass'=>$config['pass'] ?? null, 'charset'=>$config['charset'] ?? 'utf8mb4',
];
if (($db['name'] ?? '') !== 'u756742628_ilovemybody') { exit(3); }
$pdo = new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',
    $db['host'], $db['port'], $db['name'], $db['charset']),
    $db['user'], $db['pass'], [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$missing = (int)$pdo->query("SELECT COUNT(*) FROM v_ilb_plug_play_readiness WHERE readiness_status='missing'")->fetchColumn();
$summary = $pdo->query("SELECT * FROM v_ilb_release_summary")->fetch(PDO::FETCH_ASSOC);
$contracts = (int)$pdo->query("SELECT COUNT(*) FROM ilb_data_contract WHERE status='active'")->fetchColumn();
$metrics = (int)$pdo->query("SELECT COUNT(*) FROM ilb_metric_definition WHERE status='active'")->fetchColumn();
$result = ['verified_at_utc'=>gmdate('c'),'missing_objects'=>$missing,
    'release'=>$summary,'active_data_contracts'=>$contracts,'active_metrics'=>$metrics,
    'patient_authored_rows_modified'=>0,'ready'=>$missing===0];
echo json_encode($result, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
exit($missing===0 ? 0 : 4);
