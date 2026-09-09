<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';

function splitSqlStatements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $length = strlen($sql);
    $quote = null;
    $lineComment = false;
    $blockComment = false;

    for ($i = 0; $i < $length; $i++) {
        $ch = $sql[$i];
        $next = $i + 1 < $length ? $sql[$i + 1] : '';

        if ($lineComment) {
            $buffer .= $ch;
            if ($ch === "\n") {
                $lineComment = false;
            }
            continue;
        }

        if ($blockComment) {
            $buffer .= $ch;
            if ($ch === '*' && $next === '/') {
                $buffer .= '/';
                $i++;
                $blockComment = false;
            }
            continue;
        }

        if ($quote !== null) {
            $buffer .= $ch;
            if ($ch === '\\' && $i + 1 < $length) {
                $buffer .= $sql[++$i];
                continue;
            }
            if ($ch === $quote) {
                if (($quote === "'" || $quote === '"') && $next === $quote) {
                    $buffer .= $next;
                    $i++;
                    continue;
                }
                $quote = null;
            }
            continue;
        }

        if ($ch === '-' && $next === '-' && ($i + 2 >= $length || ctype_space($sql[$i + 2]))) {
            $buffer .= '--';
            $i++;
            $lineComment = true;
            continue;
        }
        if ($ch === '#') {
            $buffer .= $ch;
            $lineComment = true;
            continue;
        }
        if ($ch === '/' && $next === '*') {
            $buffer .= '/*';
            $i++;
            $blockComment = true;
            continue;
        }
        if ($ch === "'" || $ch === '"' || $ch === '`') {
            $quote = $ch;
            $buffer .= $ch;
            continue;
        }
        if ($ch === ';') {
            $trimmed = trim($buffer);
            if ($trimmed !== '') {
                $statements[] = $trimmed;
            }
            $buffer = '';
            continue;
        }

        $buffer .= $ch;
    }

    $trimmed = trim($buffer);
    if ($trimmed !== '') {
        $statements[] = $trimmed;
    }

    return $statements;
}

function statementHead(string $sql): string
{
    $oneLine = preg_replace('/\s+/', ' ', trim($sql)) ?: trim($sql);
    return mb_substr($oneLine, 0, 500);
}

$stage = 'startup';
$statementNumber = null;
$statementPreview = null;

try {
    $configPath = $argv[1] ?? '';
    $migrationPath = $argv[2] ?? '';

    $stage = 'load_config';
    if ($configPath === '' || !is_file($configPath)) {
        throw new RuntimeException('Config file missing: ' . $configPath);
    }
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

    if (($db['name'] ?? '') !== EXPECTED_DATABASE) {
        throw new RuntimeException('Refusing non-ILMB database: ' . ($db['name'] ?? '<missing>'));
    }

    $stage = 'connect_database';
    $pdo = new PDO(
        sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            $db['host'],
            $db['port'] ?? 3306,
            EXPECTED_DATABASE,
            $db['charset'] ?? 'utf8mb4'
        ),
        (string) $db['user'],
        (string) $db['pass'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );

    $stage = 'load_migration';
    $sql = file_get_contents($migrationPath);
    if (!$sql) {
        throw new RuntimeException('Migration empty or unreadable: ' . $migrationPath);
    }

    $stage = 'split_migration';
    $statements = splitSqlStatements($sql);
    if ($statements === []) {
        throw new RuntimeException('Migration contains no executable SQL statements.');
    }

    $stage = 'apply_migration';
    foreach ($statements as $index => $statement) {
        $statementNumber = $index + 1;
        $statementPreview = statementHead($statement);
        try {
            $pdo->exec($statement);
        } catch (PDOException $e) {
            $errorInfo = $e->errorInfo;
            $detail = [
                'statement_number' => $statementNumber,
                'statement_head' => $statementPreview,
                'sqlstate' => $errorInfo[0] ?? $e->getCode(),
                'driver_code' => $errorInfo[1] ?? null,
                'driver_message' => $errorInfo[2] ?? $e->getMessage(),
            ];
            throw new RuntimeException('Migration statement failed: ' . json_encode($detail, JSON_UNESCAPED_SLASHES), 0, $e);
        }
    }

    $statementNumber = null;
    $statementPreview = null;

    $stage = 'read_readiness_view';
    $r = $pdo->query('SELECT * FROM v_ilb_emdr_psoriasis_modality')->fetch(PDO::FETCH_ASSOC);
    if (!$r) throw new RuntimeException('EMDR modality view missing.');
    if ($r['modality_code'] !== 'EMDR') throw new RuntimeException('Wrong modality code.');
    if ($r['psoriasis_role'] !== 'UPSTREAM_MODIFIER') throw new RuntimeException('Unsafe psoriasis role.');
    if ((int) $r['pathway_links'] !== 5) throw new RuntimeException('Expected 5 pathway links: ' . json_encode($r));
    if ((int) $r['protocol_steps'] !== 8) throw new RuntimeException('Expected 8 protocol steps: ' . json_encode($r));
    if ((int) $r['measurement_links'] !== 8) throw new RuntimeException('Expected 8 measurement links: ' . json_encode($r));
    if ((int) $r['evidence_records'] !== 4) throw new RuntimeException('Expected 4 evidence records: ' . json_encode($r));
    if ((int) $r['hypothesis_links'] < 3) throw new RuntimeException('Hypothesis labelling lost: ' . json_encode($r));

    $stage = 'verify_inputs';
    $inputs = (int) $pdo->query("SELECT COUNT(*) FROM ilb_model_input_definition WHERE model_code='PSO_COP_LIFESTYLE_V4' AND category_code IN ('EMDR','AUTONOMIC') AND input_code IN ('EMDR_TARGET_LABEL','EMDR_SUD','EMDR_VOC','EMDR_BODY_SENSATION','HRV_RMSSD','EMDR_SESSION_STATUS')")->fetchColumn();
    if ($inputs !== 6) throw new RuntimeException('EMDR input definitions incomplete: ' . $inputs);

    $stage = 'verify_safety_claims';
    $direct = (int) $pdo->query("SELECT COUNT(*) FROM ilb_modality_pathway_link p JOIN ilb_modality_definition m ON m.modality_id=p.modality_id WHERE m.modality_code='EMDR' AND p.disease_code='PSO-001' AND p.target_node_code='I4' AND p.relation_type<>'HYPOTHESIZED_DOWNSTREAM_EFFECT'")->fetchColumn();
    if ($direct !== 0) throw new RuntimeException('Unsafe direct IL-17 claim detected.');

    echo json_encode([
        'ok' => true,
        'stage' => 'complete',
        'database' => EXPECTED_DATABASE,
        'migration_statements' => count($statements),
        'emdr_modality' => $r,
        'emdr_inputs' => $inputs,
        'safety_rule' => 'EMDR is stored as a separate upstream-modifier modality; downstream psoriasis effects remain evidence-labelled hypotheses until measured.',
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
} catch (Throwable $e) {
    $payload = [
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
    ];
    fwrite(STDERR, 'EMDR_VERIFIER_FAILURE ' . json_encode($payload, JSON_UNESCAPED_SLASHES) . "\n");
    exit(1);
}
