<?php
// Phase 107 verifier: execute migration statement-by-statement and prove governance invariants.
header('Content-Type: application/json');

$stage = 'bootstrap';
$statementIndex = 0;
try {
    require_once __DIR__ . '/../backend/db.php';
    if (!isset($pdo) || !($pdo instanceof PDO)) {
        throw new RuntimeException('PDO connection not available from backend/db.php');
    }
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stage = 'load_migration';
    $sqlPath = __DIR__ . '/../backend/phase_107_psoriasis_genetic_modifiable_pathway.sql';
    $sql = file_get_contents($sqlPath);
    if ($sql === false) throw new RuntimeException('Cannot read Phase 107 migration');

    // Statements in this migration do not contain semicolons inside strings.
    $statements = array_values(array_filter(array_map('trim', preg_split('/;\s*(?:\r?\n|$)/', $sql)), fn($s) => $s !== '' && !preg_match('/^--(?:.|\n)*$/', $s)));

    $stage = 'migration';
    foreach ($statements as $i => $statement) {
        $statementIndex = $i + 1;
        // Strip leading comment lines from the executable chunk.
        $statement = preg_replace('/\A(?:\s*--[^\n]*(?:\n|$))+/', '', $statement);
        $statement = trim($statement);
        if ($statement === '') continue;
        try {
            $pdo->exec($statement);
        } catch (Throwable $e) {
            throw new RuntimeException('Phase 107 SQL statement '.$statementIndex.' failed: '.substr(preg_replace('/\s+/', ' ', $statement), 0, 220).' :: '.$e->getMessage(), 0, $e);
        }
    }

    $stage = 'readiness';
    $row = $pdo->query('SELECT * FROM v_ilb_psoriasis_genetic_modifiable_readiness')->fetch(PDO::FETCH_ASSOC);
    if (!$row) throw new RuntimeException('Readiness view returned no row');

    $expected = [
        'genetic_factors' => 8,
        'modifiable_nodes' => 12,
        'genetic_node_links' => 8,
        'modality_node_links' => 9,
        'emotional_narrative_notes' => 6,
        'hypothesis_modality_links' => 2,
    ];
    foreach ($expected as $k => $v) {
        if ((int)$row[$k] !== $v) throw new RuntimeException("Unexpected $k: {$row[$k]} expected $v");
    }

    $stage = 'governance';
    $badGenetic = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_genetic_factor WHERE modifiability_class <> 'FIXED_GENOTYPE'")->fetchColumn();
    if ($badGenetic !== 0) throw new RuntimeException('Genetic susceptibility factors must remain FIXED_GENOTYPE');

    $badNarrative = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_emotional_narrative_note WHERE biological_claim_status <> 'NOT_VERIFIED_CAUSE'")->fetchColumn();
    if ($badNarrative !== 0) throw new RuntimeException('Emotional narratives were promoted beyond NOT_VERIFIED_CAUSE');

    $unsafeAlt = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_modality_node_crosswalk WHERE modality_code IN ('EMDR','ACUPUNCTURE','LOUISE_HAY','REDIKALL') AND (claim_boundary LIKE '%cures psoriasis%' OR (node_id='PSONODE-04' AND directness='DIRECT'))")->fetchColumn();
    if ($unsafeAlt !== 0) throw new RuntimeException('Unsafe direct-cytokine/cure claim detected for alternative modality');

    $uv = $pdo->query("SELECT psoriasis_evidence_status, clinical_use_status, claim_boundary FROM ilb_psoriasis_modality_node_crosswalk WHERE modality_code='PHOTOTHERAPY_UV'")->fetch(PDO::FETCH_ASSOC);
    if (!$uv || $uv['psoriasis_evidence_status'] !== 'ESTABLISHED' || stripos($uv['claim_boundary'], 'conventional non-drug medical treatment') === false) {
        throw new RuntimeException('UV phototherapy classification/governance missing');
    }

    $emdr = $pdo->query("SELECT directness, psoriasis_evidence_status, claim_boundary FROM ilb_psoriasis_modality_node_crosswalk WHERE modality_code='EMDR'")->fetch(PDO::FETCH_ASSOC);
    if (!$emdr || $emdr['directness'] !== 'INDIRECT' || stripos($emdr['claim_boundary'], 'no direct IL-17') === false) {
        throw new RuntimeException('EMDR governance boundary missing');
    }

    $stage = 'complete';
    echo json_encode([
        'ok' => true,
        'stage' => $stage,
        'database' => $pdo->query('SELECT DATABASE()')->fetchColumn(),
        'migration_statements' => count($statements),
        'readiness' => array_map('intval', $row),
        'model' => 'FIXED_GENETIC_SUSCEPTIBILITY -> MODIFIABLE_BIOLOGICAL_STATE -> MEASURED_PHENOTYPE',
        'safety_rule' => 'Alternative/emotional modalities may only map to evidence-labelled nodes; no unsupported direct IL-17 or cure claims.'
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'ok' => false,
        'stage' => $stage,
        'statement_index' => $statementIndex,
        'exception' => get_class($e),
        'message' => $e->getMessage(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
}
