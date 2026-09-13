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

    $treatmentClasses = $pdo->query("SELECT class_id,class_name,route_or_type,mechanism_summary,typical_role,major_safety_theme,governance_text FROM ilb_psoriasis_treatment_class ORDER BY class_id")->fetchAll();
    $medicineReferences = $pdo->query("SELECT drug_id,generic_name,class_name,route_text,mechanism_text,psoriasis_role,major_safety_theme FROM ilb_psoriasis_medicine_reference ORDER BY drug_id")->fetchAll();

    $summary = [
        'active_parameters'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_master WHERE status='ACTIVE'")->fetchColumn(),
        'verified_formulas'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_master WHERE formula_status IN ('VERIFIED','APPROVED')")->fetchColumn(),
        'formula_inputs'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_input")->fetchColumn(),
        'approved_identifiers'=>(int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_identifier WHERE verification_status='APPROVED'")->fetchColumn(),
        'psoriasis_treatment_classes'=>count($treatmentClasses),
        'psoriasis_medicine_references'=>count($medicineReferences),
    ];

    $required = 0;
    foreach ($definitions as $d) if ((int)$d['release_required'] === 1) $required++;

    echo json_encode([
        'ok'=>true,
        'access_mode'=>'public_read_only',
        'report'=>[
            'report_code'=>'ILMB-RPT-001',
            'title'=>'Psoriasis · Two Paths · Personalisation',
            'disease'=>'Psoriasis',
            'model_code'=>$modelCode,
            'principle'=>'Two paths first. Disease understanding next. Personalisation and planning follow from governed database fields.'
        ],
        'completeness'=>[
            'defined_fields'=>count($definitions),
            'release_required_fields'=>$required
        ],
        'input_definitions'=>$definitions,
        'parameters'=>$params->fetchAll(),
        'release_gates'=>$gates->fetchAll(),
        'treatment_classes'=>$treatmentClasses,
        'medicine_references'=>$medicineReferences,
        'formula_summary'=>$summary
    ], JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    error_log('ILMB public report API: '.$e->getMessage());
    http_response_code(503);
    echo json_encode(['ok'=>false,'error'=>'The ILMB database report could not be loaded.']);
}
