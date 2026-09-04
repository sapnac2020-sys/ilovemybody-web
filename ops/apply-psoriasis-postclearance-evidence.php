<?php
declare(strict_types=1);
ini_set('display_errors', 'stderr');
error_reporting(E_ALL);
const EXPECTED_DATABASE = 'u756742628_ilovemybody';
if (PHP_SAPI !== 'cli') exit(2);
$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$database = $config['db'] ?? ($config['name'] ?? null);
if ($database !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$sqlPath = $argv[2] ?? '';
if (!is_file($sqlPath)) throw new RuntimeException('Phase 88 SQL missing');
$pdo = new PDO(
    'mysql:host='.$config['host'].';port='.($config['port'] ?? 3306).';dbname='.$database.';charset=utf8mb4',
    $config['user'],
    $config['pass'] ?? $config['password'],
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
);
$statement = $pdo->prepare(file_get_contents($sqlPath));
$statement->execute();
do { if ($statement->columnCount()) $statement->fetchAll(); } while ($statement->nextRowset());
$statement->closeCursor();
$rows = $pdo->query('SELECT evidence_key,persistence_state,evidence_class,state_decision,source_id,source_url,computation_eligible,patient_use_allowed FROM ilb_psoriasis_postclearance_evidence ORDER BY evidence_key')->fetchAll();
$supportedR = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_postclearance_evidence WHERE persistence_state='R' AND state_decision='SUPPORTED'")->fetchColumn();
$executable = (int)$pdo->query('SELECT COUNT(*) FROM ilb_psoriasis_postclearance_evidence WHERE computation_eligible=1')->fetchColumn();
if (count($rows) !== 3 || $supportedR !== 2 || $executable !== 0) throw new RuntimeException('Phase 88 invariant failed');
echo json_encode([
    'database' => $database,
    'phase' => 'P88_POSTCLEARANCE_HUMAN_TISSUE_EVIDENCE',
    'registered_sources' => count($rows),
    'supported_R_records' => $supportedR,
    'state_decision' => ['R'=>'SUPPORTED','E'=>'CANDIDATE_UNRESOLVED','F'=>'CANDIDATE_UNRESOLVED','L'=>'UNRESOLVED'],
    'records' => $rows,
    'computation_eligible_records' => $executable,
    'patient_tables_queried' => false,
    'patient_rows_read' => 0,
    'patient_rows_modified' => 0,
    'verified' => true
], JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL;
