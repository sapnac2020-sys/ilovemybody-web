<?php
declare(strict_types=1);

function tableExists(PDO $pdo, string $name): bool {
    $s=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
    $s->execute([$name]); return (int)$s->fetchColumn()===1;
}
function tableColumns(PDO $pdo, string $name): array {
    $s=$pdo->prepare("SELECT column_name FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? ORDER BY ordinal_position");
    $s->execute([$name]); return array_map(fn($r)=>(string)$r['column_name'],$s->fetchAll(PDO::FETCH_ASSOC));
}
function firstColumn(array $columns, array $candidates): ?string {
    foreach($candidates as $c) if(in_array($c,$columns,true)) return $c;
    return null;
}
function qi(string $name): string { return '`'.str_replace('`','``',$name).'`'; }

try {
    if ($argc < 3) throw new RuntimeException('Usage: php run-body-need-master-migrations.php CONFIG MIGRATION_DIR');
    $config = require $argv[1];
    if (isset($config['database'])) $config = $config['database'];
    $dbName = $config['db'] ?? $config['name'] ?? null;
    if (!$dbName) throw new RuntimeException('Database name missing from config');

    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$dbName};charset=utf8mb4",
        $config['user'],
        $config['pass'] ?? $config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true]
    );
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

    $dir = rtrim($argv[2], '/');
    $files = [
        '005_body_need_master.sql','006_formula_duplicate_and_identifier_patch.sql',
        '007_formula_master_bootstrap.sql','008_loinc_parameter_bootstrap.sql',
        '009_body_need_execution_status_patch.sql',
    ];
    $applied = [];
    foreach ($files as $file) {
        $path = $dir . '/' . $file;
        if (!is_file($path) || filesize($path) === 0) throw new RuntimeException("Missing migration: {$file}");
        $stmt = $pdo->prepare(file_get_contents($path)); $stmt->execute();
        do { if($stmt->columnCount()) $stmt->fetchAll(); } while($stmt->nextRowset());
        $applied[] = $file;
    }

    // Adaptively index legacy governed equations without assuming one historical column contract.
    $equationBootstrap = [
        'registry_present' => tableExists($pdo,'ilb_equation_registry'),
        'detected_columns' => [],
        'mapped_columns' => [],
        'rows_seen' => 0,
        'rows_upserted' => 0,
        'status' => 'SKIPPED_NO_REGISTRY',
    ];
    if ($equationBootstrap['registry_present']) {
        $cols = tableColumns($pdo,'ilb_equation_registry');
        $equationBootstrap['detected_columns'] = $cols;
        $map = [
            'key' => firstColumn($cols,['equation_key','formula_key','equation_code','formula_code','code','registry_key']),
            'name' => firstColumn($cols,['equation_name','formula_name','name','title','label']),
            'class' => firstColumn($cols,['equation_class','formula_domain','domain','category','equation_type','formula_type']),
            'expression' => firstColumn($cols,['equation_expression','expression_text','equation_text','formula_expression','formula_text','formula','expression']),
            'evidence' => firstColumn($cols,['evidence_locator','source_citation','source_locator','evidence_source','citation','source']),
            'validation' => firstColumn($cols,['validation_status','formula_status','verification_status','status']),
            'input_units' => firstColumn($cols,['input_unit_contract','input_units','unit_contract_in']),
            'output_units' => firstColumn($cols,['output_unit_contract','output_units','unit_contract_out']),
        ];
        $equationBootstrap['mapped_columns'] = $map;
        if ($map['key'] && $map['expression']) {
            $selectCols = array_values(array_unique(array_filter($map)));
            $sql = 'SELECT '.implode(',',array_map('qi',$selectCols)).' FROM `ilb_equation_registry`';
            $rows = $pdo->query($sql)->fetchAll();
            $equationBootstrap['rows_seen'] = count($rows);
            $upsert = $pdo->prepare("INSERT INTO ilmb_formula_master
              (formula_key,formula_name,formula_domain,output_parameter_id,expression_text,expression_language,purpose,evidence_class,
               source_system,source_record_key,source_citation,formula_status,unit_checked,dimensional_analysis_text)
              VALUES (?,?,?,?,?,'EQUATION_TEXT',?,'PUBLISHED_MODEL','ilb_equation_registry',?,?,?,0,?)
              ON DUPLICATE KEY UPDATE formula_name=VALUES(formula_name),formula_domain=VALUES(formula_domain),
               expression_text=VALUES(expression_text),source_citation=VALUES(source_citation),formula_status=VALUES(formula_status),
               dimensional_analysis_text=VALUES(dimensional_analysis_text),updated_at=CURRENT_TIMESTAMP");
            foreach ($rows as $r) {
                $sourceKey = trim((string)$r[$map['key']]);
                $expr = trim((string)$r[$map['expression']]);
                if ($sourceKey==='' || $expr==='') continue;
                $name = $map['name'] ? trim((string)($r[$map['name']] ?? '')) : '';
                if ($name==='') $name=$sourceKey;
                $class = $map['class'] ? trim((string)($r[$map['class']] ?? '')) : 'OTHER';
                if ($class==='') $class='OTHER';
                $upper = strtoupper($class);
                $purpose = str_contains($upper,'PHYSIC') ? 'PHYSICS' : (str_contains($upper,'CHEM') ? 'CHEMISTRY' : (str_contains($upper,'PHYSIOL') ? 'PHYSIOLOGY' : 'OTHER'));
                $validation = $map['validation'] ? strtoupper(trim((string)($r[$map['validation']] ?? ''))) : '';
                $status = in_array($validation,['VERIFIED','APPROVED','PASS'],true) ? 'VERIFIED' : 'DRAFT';
                $evidence = $map['evidence'] ? (string)($r[$map['evidence']] ?? '') : null;
                $inUnits = $map['input_units'] ? (string)($r[$map['input_units']] ?? '') : '';
                $outUnits = $map['output_units'] ? (string)($r[$map['output_units']] ?? '') : '';
                $dim = 'legacy_input_unit_contract='.$inUnits.'; legacy_output_unit_contract='.$outUnits;
                $upsert->execute(['equation_registry:'.$sourceKey,$name,$class,null,$expr,$purpose,$sourceKey,$evidence,$status,$dim]);
                $equationBootstrap['rows_upserted']++;
            }
            $equationBootstrap['status']='IMPORTED_REFERENCE_ONLY';
        } else {
            $equationBootstrap['status']='BLOCKED_UNMAPPED_REGISTRY_COLUMNS';
        }
    }

    $requiredTables = ['ilmb_parameter_master','ilmb_parameter_identifier','ilmb_formula_master','ilmb_formula_input','ilmb_parameter_duplicate_candidate','ilmb_formula_duplicate_candidate','ilmb_body_need_run'];
    $requiredViews = ['vw_ilmb_common_parameter_master','vw_ilmb_subject_parameter_observation'];
    $check = $pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? AND table_type=?");
    $missing = [];
    foreach ($requiredTables as $name) { $check->execute([$name,'BASE TABLE']); if((int)$check->fetchColumn()!==1)$missing[]=$name; }
    foreach ($requiredViews as $name) { $check->execute([$name,'VIEW']); if((int)$check->fetchColumn()!==1)$missing[]=$name; }

    $counts=[];
    foreach ([
        'parameters'=>'SELECT COUNT(*) FROM ilmb_parameter_master',
        'identifiers'=>'SELECT COUNT(*) FROM ilmb_parameter_identifier',
        'formulas'=>'SELECT COUNT(*) FROM ilmb_formula_master',
        'formula_inputs'=>'SELECT COUNT(*) FROM ilmb_formula_input',
        'resolved_subject_observations'=>'SELECT COUNT(*) FROM vw_ilmb_subject_parameter_observation',
    ] as $key=>$sql) $counts[$key]=(int)$pdo->query($sql)->fetchColumn();

    $result=[
        'body_need_master_ready'=>count($missing)===0,
        'missing_objects'=>$missing,
        'applied_migrations'=>$applied,
        'equation_registry_bootstrap'=>$equationBootstrap,
        'counts'=>$counts,
        'patient_rows_modified'=>0,
    ];
    echo json_encode($result,JSON_UNESCAPED_SLASHES),PHP_EOL;
    exit(count($missing)===0?0:4);
} catch(Throwable $e) { echo 'BODY_NEED_MIGRATION_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }
