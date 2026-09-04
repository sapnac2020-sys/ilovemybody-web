<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';

if (PHP_SAPI !== 'cli') exit(2);
$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$database = $config['db'] ?? ($config['name'] ?? null);
if ($database !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');

$pdo = new PDO(
    'mysql:host='.$config['host'].';port='.($config['port'] ?? 3306).';dbname='.$database.';charset=utf8mb4',
    $config['user'],
    $config['pass'] ?? $config['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]
);

function tableExists(PDO $pdo, string $table): bool {
    $q=$pdo->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?');
    $q->execute([$table]);
    return (int)$q->fetchColumn() === 1;
}
function rows(PDO $pdo, string $sql): array { return $pdo->query($sql)->fetchAll(); }
function scalar(PDO $pdo, string $sql): int { return (int)$pdo->query($sql)->fetchColumn(); }

$out = [
    'database'=>$database,
    'mode'=>'read_only_non_patient_formula_audit',
    'patient_tables_queried'=>false,
    'patient_rows_read'=>0,
    'patient_rows_modified'=>0,
];

$out['matching_tables'] = rows($pdo, "SELECT table_name,table_rows FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' AND LOWER(table_name) REGEXP 'chebi|rxnorm|drug|medicine|pharma|target|pathway|protein|cytokine|interleukin|psoriasis|kinetic|parameter|dose|formulation|ingredient|interaction|adverse' ORDER BY table_name");
$out['matching_columns'] = rows($pdo, "SELECT table_name,column_name,data_type,column_type FROM information_schema.columns WHERE table_schema=DATABASE() AND LOWER(table_name) REGEXP 'chebi|rxnorm|drug|medicine|pharma|target|pathway|protein|cytokine|interleukin|psoriasis|kinetic|parameter|dose|formulation|ingredient|interaction|adverse' ORDER BY table_name,ordinal_position");

if (tableExists($pdo,'ilmb_canonical_record')) {
    $out['canonical_groups'] = rows($pdo, "SELECT system_id,sheet_name,COUNT(*) row_count FROM ilmb_canonical_record WHERE active=1 AND LOWER(sheet_name) REGEXP 'chebi|rxnorm|drug|medicine|pharma|target|pathway|protein|cytokine|interleukin|kinetic|parameter|dose|formulation|ingredient|interaction|adverse' GROUP BY system_id,sheet_name ORDER BY row_count DESC,system_id,sheet_name");
    $terms=['ixekizumab','secukinumab','brodalumab','bimekizumab','guselkumab','risankizumab','tildrakizumab','ustekinumab','adalimumab','infliximab','etanercept','interleukin-17','interleukin-23','il-17','il-23','tnf'];
    $q=$pdo->prepare("SELECT COUNT(*) FROM ilmb_canonical_record WHERE active=1 AND (LOWER(source_key) LIKE ? OR LOWER(payload_json) LIKE ?)");
    foreach($terms as $term){$like='%'.$term.'%';$q->execute([$like,$like]);$out['canonical_term_hits'][$term]=(int)$q->fetchColumn();}
}

foreach (['ilb_drug','ilb_drug_identifier','ilb_medicine_mechanism','ilb_pharma_medicine'] as $table) {
    if (tableExists($pdo,$table)) {
        $out['live_table_counts'][$table]=scalar($pdo,"SELECT COUNT(*) FROM `{$table}`");
        $out['live_table_samples'][$table]=rows($pdo,"SELECT * FROM `{$table}` LIMIT 25");
    }
}

if (tableExists($pdo,'ilmb_entity_crosswalk')) {
    $out['medicine_crosswalks']=rows($pdo,"SELECT source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible,COUNT(*) row_count FROM ilmb_entity_crosswalk WHERE source_entity_type IN ('MEDICINE','DRUG','INGREDIENT','TARGET','PROTEIN') OR target_entity_type IN ('MEDICINE','DRUG','INGREDIENT','TARGET','PROTEIN') OR source_system IN ('RXNORM','NLEM','CHEBI') OR target_system IN ('RXNORM','NLEM','CHEBI') GROUP BY source_system,source_entity_type,predicate,target_system,target_entity_type,match_type,status,computation_eligible ORDER BY row_count DESC");
}

if (tableExists($pdo,'ilb_psoriasis_sbml_species')) {
    $out['psoriasis_species']=rows($pdo,"SELECT sbml_id,symbol,state_role,measurement_gate,initial_value,initial_value_kind FROM ilb_psoriasis_sbml_species WHERE model_key='SHMAROV_2022_FULL' ORDER BY symbol");
}
if (tableExists($pdo,'ilb_psoriasis_sbml_parameter')) {
    $out['psoriasis_parameters']=rows($pdo,"SELECT parameter_scope,sbml_id,symbol,parameter_value,declared_units,provenance_class,execution_gate FROM ilb_psoriasis_sbml_parameter WHERE model_key='SHMAROV_2022_FULL' ORDER BY symbol");
    $out['psoriasis_parameter_readiness']=rows($pdo,"SELECT provenance_class,execution_gate,COUNT(*) row_count FROM ilb_psoriasis_sbml_parameter WHERE model_key='SHMAROV_2022_FULL' GROUP BY provenance_class,execution_gate ORDER BY provenance_class,execution_gate");
}
if (tableExists($pdo,'ilb_psoriasis_model_gate')) {
    $out['psoriasis_gates']=rows($pdo,"SELECT gate_code,gate_order,gate_name,status,evidence_note FROM ilb_psoriasis_model_gate WHERE model_key='SHMAROV_2022_FULL' ORDER BY gate_order");
}

$out['audit_complete']=true;
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE),PHP_EOL;
