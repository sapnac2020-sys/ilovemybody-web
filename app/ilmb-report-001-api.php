<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';

$pdo = db();
$case = require_case();
$modelCode = 'PSO_COP_LIFESTYLE_V4';
$action = (string)($_GET['action'] ?? 'bootstrap');

function latest_by_code(array $rows, string $codeKey): array {
    $out = [];
    foreach ($rows as $row) {
        $code = (string)($row[$codeKey] ?? '');
        if ($code === '' || isset($out[$code])) continue;
        $out[$code] = $row;
    }
    return $out;
}

if ($action === 'bootstrap' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        $defs = $pdo->prepare("SELECT input_id,input_code,category_code,label,value_domain,canonical_unit_code,time_basis,body_site_required,provenance_required,release_required
                                 FROM ilb_model_input_definition
                                WHERE model_code=?
                                ORDER BY category_code,label");
        $defs->execute([$modelCode]);
        $definitions = $defs->fetchAll();

        $obs = $pdo->prepare("SELECT o.observation_id,o.input_id,o.observed_at,o.value_number,o.value_text,o.unit_code,o.body_site,o.method_code,o.quality_status,o.entered_by,
                                     d.input_code,d.category_code,d.label,d.value_domain,d.canonical_unit_code
                                FROM ilb_subject_observation o
                                JOIN ilb_model_input_definition d ON d.input_id=o.input_id
                               WHERE o.subject_key=? AND d.model_code=?
                               ORDER BY o.observed_at DESC,o.created_at DESC");
        $obs->execute([$case['subject_key'],$modelCode]);
        $latestObservations = latest_by_code($obs->fetchAll(), 'input_code');

        $param = $pdo->prepare("SELECT d.parameter_id,d.parameter_code,d.label,d.equation_code,d.canonical_unit_code,d.parameter_role,
                                      v.value_number,v.unit_code,v.valid_from,v.source_status,v.approval_status,v.version_no
                                 FROM ilb_model_parameter_definition d
                                 LEFT JOIN ilb_model_parameter_value v
                                   ON v.parameter_id=d.parameter_id AND v.subject_key=?
                                WHERE d.model_code=?
                                ORDER BY d.parameter_role,d.parameter_code,v.version_no DESC");
        $param->execute([$case['subject_key'],$modelCode]);
        $parameters = latest_by_code($param->fetchAll(), 'parameter_code');

        $gates = $pdo->prepare("SELECT gate_code,gate_order,gate_status,reason_text,checked_at
                                  FROM ilb_model_release_gate
                                 WHERE model_code=? ORDER BY gate_order");
        $gates->execute([$modelCode]);

        $docs = $pdo->prepare("SELECT document_id,document_type,document_date,original_filename,mime_type,extraction_status,human_review_status,created_at
                                 FROM ilb_subject_document
                                WHERE subject_key=?
                                ORDER BY COALESCE(document_date,DATE(created_at)) DESC,document_id DESC");
        $docs->execute([$case['subject_key']]);

        $meds = $pdo->prepare("SELECT medicine_report_id,reported_name,strength_text,dose_text,frequency_text,usual_time_text,reason_text,verification_status,status
                                 FROM ilb_subject_medicine_report
                                WHERE subject_key=? AND status='active'
                                ORDER BY medicine_report_id");
        $meds->execute([$case['subject_key']]);

        $exposures = $pdo->prepare("SELECT exposure_id,medicine_entity_id,medicine_name_as_recorded,dose_value,dose_unit,route_code,start_at,end_at,schedule_text,prescribed_flag,verification_status
                                      FROM ilb_medicine_exposure
                                     WHERE subject_key=? ORDER BY COALESCE(start_at,'1000-01-01') DESC");
        $exposures->execute([$case['subject_key']]);

        $events = $pdo->prepare("SELECT adverse_event_id,exposure_id,event_label,onset_at,resolved_at,severity,seriousness_flag,action_taken,outcome_text,attribution,clinician_review_status
                                   FROM ilb_adverse_event_observation
                                  WHERE subject_key=? ORDER BY COALESCE(onset_at,'1000-01-01') DESC");
        $events->execute([$case['subject_key']]);

        $formulaSummary = [
            'parameters' => (int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_master WHERE status='ACTIVE'")->fetchColumn(),
            'verified_formulas' => (int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_master WHERE formula_status IN ('VERIFIED','APPROVED')")->fetchColumn(),
            'formula_inputs' => (int)$pdo->query("SELECT COUNT(*) FROM ilmb_formula_input")->fetchColumn(),
            'approved_identifiers' => (int)$pdo->query("SELECT COUNT(*) FROM ilmb_parameter_identifier WHERE verification_status='APPROVED'")->fetchColumn(),
        ];

        $known = 0; $required = 0; $requiredKnown = 0;
        foreach ($definitions as $d) {
            $code = (string)$d['input_code'];
            $has = isset($latestObservations[$code]) && (($latestObservations[$code]['value_number'] ?? null) !== null || trim((string)($latestObservations[$code]['value_text'] ?? '')) !== '');
            if ($has) $known++;
            if ((int)$d['release_required'] === 1) { $required++; if ($has) $requiredKnown++; }
        }

        json_out([
            'ok'=>true,
            'report'=>[
                'report_code'=>'ILMB-RPT-001',
                'title'=>'Psoriasis Baseline + Personalisation',
                'disease'=>'Psoriasis',
                'model_code'=>$modelCode,
                'generated_at'=>date(DATE_ATOM),
                'principle'=>'Baseline plan first. More verified information increases personalisation and recalculates the plan.'
            ],
            'case'=>[
                'public_case_key'=>$case['public_case_key'],
                'label'=>$case['frontend_label'],
                'age'=>$case['allowed_age_display'],
                'sex'=>$case['allowed_sex_display']
            ],
            'completeness'=>[
                'defined_fields'=>count($definitions),
                'known_fields'=>$known,
                'release_required_fields'=>$required,
                'release_required_known'=>$requiredKnown,
                'personalisation_percent'=>count($definitions) ? round(($known/count($definitions))*100,1) : 0
            ],
            'input_definitions'=>$definitions,
            'latest_observations'=>$latestObservations,
            'parameters'=>$parameters,
            'release_gates'=>$gates->fetchAll(),
            'documents'=>$docs->fetchAll(),
            'medicines'=>$meds->fetchAll(),
            'medicine_exposures'=>$exposures->fetchAll(),
            'adverse_events'=>$events->fetchAll(),
            'formula_summary'=>$formulaSummary
        ]);
    } catch (Throwable $e) {
        error_log('ILMB report bootstrap: '.$e->getMessage());
        json_out(['ok'=>false,'error'=>'The connected report could not be loaded from the database.'],503);
    }
}

if ($action === 'save-observations' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $d = request_data();
    $items = is_array($d['observations'] ?? null) ? $d['observations'] : [];
    if (!$items) json_out(['ok'=>false,'error'=>'No fields were supplied.'],422);

    $defStmt = $pdo->prepare("SELECT input_id,input_code,value_domain,canonical_unit_code,body_site_required
                               FROM ilb_model_input_definition WHERE model_code=? AND input_code=? LIMIT 1");
    $insert = $pdo->prepare("INSERT INTO ilb_subject_observation
      (observation_id,subject_key,episode_key,input_id,observed_at,value_number,value_text,unit_code,body_site,method_code,quality_status,entered_by)
      VALUES (?,?,?,?,?,?,?,?,?,?,'UNVERIFIED','participant_report_edit')");

    $saved = 0;
    $pdo->beginTransaction();
    try {
        foreach ($items as $item) {
            $code = preg_replace('/[^A-Z0-9_:-]/','', strtoupper((string)($item['input_code'] ?? '')));
            if ($code === '') continue;
            $defStmt->execute([$modelCode,$code]);
            $def = $defStmt->fetch();
            if (!$def) continue;

            $valueNumber = null; $valueText = null;
            if (in_array($def['value_domain'],['NUMBER','INTEGER'],true)) {
                $valueNumber = nullable_number($item['value'] ?? null);
                if ($valueNumber === null) continue;
                if ($def['value_domain']==='INTEGER') $valueNumber=(int)$valueNumber;
            } else if ($def['value_domain']==='BOOLEAN') {
                $v = strtolower(trim((string)($item['value'] ?? '')));
                if (!in_array($v,['true','false','yes','no','1','0'],true)) continue;
                $valueText = in_array($v,['true','yes','1'],true) ? 'true' : 'false';
            } else {
                $valueText = text_or_null($item['value'] ?? null,5000);
                if ($valueText === null) continue;
            }

            $bodySite = text_or_null($item['body_site'] ?? null,255);
            if ((int)$def['body_site_required'] === 1 && !$bodySite) continue;
            $unit = text_or_null($item['unit_code'] ?? null,64) ?: ($def['canonical_unit_code'] ?: null);
            $observedAt = (string)($item['observed_at'] ?? '');
            if (!preg_match('/^\d{4}-\d{2}-\d{2}(?:[ T]\d{2}:\d{2}(?::\d{2})?)?$/',$observedAt)) $observedAt=date('Y-m-d H:i:s');
            $episode = text_or_null($item['episode_key'] ?? null,255) ?: 'PSO-BASELINE';
            $observationId = hash('sha256',$case['subject_key'].'|'.$code.'|'.microtime(true).'|'.random_bytes(12));
            $insert->execute([$observationId,$case['subject_key'],$episode,$def['input_id'],$observedAt,$valueNumber,$valueText,$unit,$bodySite,'ILMB_REPORT_001_UI']);
            $saved++;
        }
        $pdo->commit();
        json_out(['ok'=>true,'saved'=>$saved,'message'=>'Saved as new source observations. Previous observations were preserved.']);
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        error_log('ILMB report save: '.$e->getMessage());
        json_out(['ok'=>false,'error'=>'The observations could not be saved.'],500);
    }
}

json_out(['ok'=>false,'error'=>'Unsupported report action.'],405);
