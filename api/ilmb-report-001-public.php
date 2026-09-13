<?php
declare(strict_types=1);
require __DIR__ . '/../app/lib.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: public, max-age=120');

$pdo = db();
$modelCode = 'PSO_COP_LIFESTYLE_V4';

try {
    $defs = $pdo->prepare("SELECT input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,release_required FROM ilb_model_input_definition WHERE model_code=? ORDER BY category_code,label");
    $defs->execute([$modelCode]);
    $definitions = $defs->fetchAll();

    $params = $pdo->prepare("SELECT parameter_code,label,equation_code,canonical_unit_code,parameter_role FROM ilb_model_parameter_definition WHERE model_code=? ORDER BY parameter_role,parameter_code");
    $params->execute([$modelCode]);

    $gates = $pdo->prepare("SELECT gate_code,gate_order,gate_status,reason_text,checked_at FROM ilb_model_release_gate WHERE model_code=? ORDER BY gate_order");
    $gates->execute([$modelCode]);

    $summary = [
        'active_parameters'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_master WHERE status='ACTIVE'")->fetchColumn(),
        'verified_formulas'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_master WHERE formula_status IN ('VERIFIED','APPROVED')")->fetchColumn(),
        'formula_inputs'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_input")->fetchColumn(),
        'approved_identifiers'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_identifier WHERE verification_status='APPROVED'")->fetchColumn(),
    ];

    $required = 0;
    foreach ($definitions as $d) if ((int)$d['release_required'] === 1) $required++;

    echo json_encode([
        'ok'=>true,
        'access_mode'=>'public_read_only',
        'report'=>[
            'report_code'=>'ILMB-RPT-001',
            'title'=>'Psoriasis Baseline + Personalisation',
            'disease'=>'Psoriasis',
            'model_code'=>$modelCode,
            'principle'=>'Baseline plan first. More verified information increases personalisation and recalculates the plan.'
        ],
        'completeness'=>[
            'defined_fields'=>count($definitions),
            'release_required_fields'=>$required
        ],
        'input_definitions'=>$definitions,
        'parameters'=>$params->fetchAll(),
        'release_gates'=>$gates->fetchAll(),
        'formula_summary'=>$summary
    ], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    error_log('ILMB public report API: '.$e->getMessage());
    http_response_code(503);
    echo json_encode(['ok'=>false,'error'=>'The ILMB database report could not be loaded.']);
}
