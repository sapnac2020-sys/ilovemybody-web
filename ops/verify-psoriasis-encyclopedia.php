<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';

function splitSqlStatements(string $sql): array
{
    $out = [];
    $buf = '';
    $quote = null;
    $lineComment = false;
    $blockComment = false;
    $n = strlen($sql);

    for ($i = 0; $i < $n; $i++) {
        $ch = $sql[$i];
        $next = $i + 1 < $n ? $sql[$i + 1] : '';

        if ($lineComment) {
            $buf .= $ch;
            if ($ch === "\n") $lineComment = false;
            continue;
        }
        if ($blockComment) {
            $buf .= $ch;
            if ($ch === '*' && $next === '/') {
                $buf .= '/';
                $i++;
                $blockComment = false;
            }
            continue;
        }
        if ($quote !== null) {
            $buf .= $ch;
            if ($ch === '\\' && $i + 1 < $n) {
                $buf .= $sql[++$i];
                continue;
            }
            if ($ch === $quote) {
                if (($quote === "'" || $quote === '"') && $next === $quote) {
                    $buf .= $next;
                    $i++;
                    continue;
                }
                $quote = null;
            }
            continue;
        }
        if ($ch === '-' && $next === '-' && ($i + 2 >= $n || ctype_space($sql[$i + 2]))) {
            $buf .= '--';
            $i++;
            $lineComment = true;
            continue;
        }
        if ($ch === '#') {
            $buf .= $ch;
            $lineComment = true;
            continue;
        }
        if ($ch === '/' && $next === '*') {
            $buf .= '/*';
            $i++;
            $blockComment = true;
            continue;
        }
        if ($ch === "'" || $ch === '"' || $ch === '`') {
            $quote = $ch;
            $buf .= $ch;
            continue;
        }
        if ($ch === ';') {
            $trim = trim($buf);
            if ($trim !== '') $out[] = $trim;
            $buf = '';
            continue;
        }
        $buf .= $ch;
    }

    $trim = trim($buf);
    if ($trim !== '') $out[] = $trim;
    return $out;
}

function statementHead(string $sql): string
{
    $line = preg_replace('/\s+/', ' ', trim($sql)) ?: trim($sql);
    return mb_substr($line, 0, 500);
}

$stage = 'startup';
$statementNumber = null;
$statementPreview = null;

try {
    $configPath = $argv[1] ?? '';
    $migrationPath = $argv[2] ?? '';

    $stage = 'load_config';
    if ($configPath === '' || !is_file($configPath)) throw new RuntimeException('Config file missing: ' . $configPath);
    $config = require $configPath;
    $db = is_array($config['db'] ?? null)
        ? $config['db']
        : [
            'host' => $config['host'] ?? null,
            'port' => $config['port'] ?? 3306,
            'name' => $config['db'] ?? null,
            'user' => $config['user'] ?? null,
            'pass' => $config['pass'] ?? null,
            'charset' => $config['charset'] ?? 'utf8mb4',
        ];
    if (($db['name'] ?? '') !== EXPECTED_DATABASE) throw new RuntimeException('Refusing non-ILMB database: ' . ($db['name'] ?? '<missing>'));

    $stage = 'connect_database';
    $pdo = new PDO(
        sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $db['host'], $db['port'] ?? 3306, EXPECTED_DATABASE, $db['charset'] ?? 'utf8mb4'),
        (string)$db['user'],
        (string)$db['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    $stage = 'load_migration';
    $sql = file_get_contents($migrationPath);
    if (!$sql) throw new RuntimeException('Migration empty or unreadable: ' . $migrationPath);

    $stage = 'split_migration';
    $statements = splitSqlStatements($sql);
    if ($statements === []) throw new RuntimeException('Migration contains no executable SQL statements.');

    $stage = 'apply_migration';
    foreach ($statements as $index => $statement) {
        $statementNumber = $index + 1;
        $statementPreview = statementHead($statement);
        try {
            $pdo->exec($statement);
        } catch (PDOException $e) {
            $ei = $e->errorInfo;
            throw new RuntimeException('Migration statement failed: ' . json_encode([
                'statement_number' => $statementNumber,
                'statement_head' => $statementPreview,
                'sqlstate' => $ei[0] ?? $e->getCode(),
                'driver_code' => $ei[1] ?? null,
                'driver_message' => $ei[2] ?? $e->getMessage(),
            ], JSON_UNESCAPED_SLASHES), 0, $e);
        }
    }

    $statementNumber = null;
    $statementPreview = null;

    $stage = 'read_readiness_view';
    $r = $pdo->query('SELECT * FROM v_ilb_psoriasis_encyclopedia_readiness')->fetch(PDO::FETCH_ASSOC);
    if (!$r) throw new RuntimeException('Phase 106 readiness view missing.');

    $expect = [
        'phenotypes' => 7,
        'sites' => 6,
        'morphology_terms' => 12,
        'histopathology_features' => 12,
        'cells' => 12,
        'bioentities' => 20,
        'pathway_edges' => 20,
        'triggers' => 15,
        'comorbidities' => 10,
        'differentials' => 18,
        'measurement_tools' => 12,
        'treatment_classes' => 15,
        'medicine_refs' => 23,
        'modality_refs' => 12,
        'red_flags' => 7,
        'research_gaps' => 8,
        'sources' => 20,
        'encyclopedia_inputs' => 6,
    ];
    foreach ($expect as $k => $v) {
        if ((int)($r[$k] ?? -1) !== $v) throw new RuntimeException("Count check failed $k=" . json_encode($r[$k] ?? null) . " expected $v");
    }
    if (($r['readiness_status'] ?? '') !== 'FOUNDATION_READY') throw new RuntimeException('Safety readiness blocked: ' . json_encode($r));

    $stage = 'verify_urgent_routing';
    $gpp = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_phenotype WHERE phenotype_id='PSO-PH-004' AND safety_class LIKE 'URGENT%'")->fetchColumn();
    $ery = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_phenotype WHERE phenotype_id='PSO-PH-007' AND safety_class LIKE 'URGENT%'")->fetchColumn();
    if ($gpp !== 1 || $ery !== 1) throw new RuntimeException('Urgent phenotype safety labels missing.');

    $stage = 'verify_emdr_governance';
    $emdr = $pdo->query("SELECT role_type,evidence_position,governance_rule FROM ilb_psoriasis_modality_reference WHERE modality_id='MOD-EMDR'")->fetch(PDO::FETCH_ASSOC);
    if (!$emdr) throw new RuntimeException('EMDR encyclopedia reference missing.');
    if (stripos((string)$emdr['governance_rule'], 'not an IL-17') === false) throw new RuntimeException('EMDR direct-immune safety wording lost.');

    echo json_encode([
        'ok' => true,
        'stage' => 'complete',
        'database' => EXPECTED_DATABASE,
        'phase' => 106,
        'migration_statements' => count($statements),
        'encyclopedia' => $r,
        'emdr_reference' => $emdr,
        'safety' => 'GPP and erythrodermic red flags are urgent; encyclopedia facts do not create treatment or cure claims.',
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'PHASE106_VERIFIER_FAILURE ' . json_encode([
        'ok' => false,
        'stage' => $stage,
        'statement_number' => $statementNumber,
        'statement_head' => $statementPreview,
        'exception' => get_class($e),
        'message' => $e->getMessage(),
        'previous_exception' => $e->getPrevious() ? get_class($e->getPrevious()) : null,
        'previous_message' => $e->getPrevious()?->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine(),
    ], JSON_UNESCAPED_SLASHES) . "\n");
    exit(1);
}
