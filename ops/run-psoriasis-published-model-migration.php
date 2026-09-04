<?php
declare(strict_types=1);

const EXPECTED_DATABASE = 'u756742628_ilovemybody';
const MODEL_KEY = 'SHMAROV_2022_FULL';
const EXPECTED_SHA256 = '99db820fca593cde4d4e8c0519ef63f946be24d1a4d5329c48c78cf3203ef1c9';
const EXPECTED_SPECIES = 25;
const EXPECTED_PARAMETERS = 62;
const EXPECTED_REACTIONS = 35;
const EXPECTED_PARTICIPANTS = 72;

if (PHP_SAPI !== 'cli') exit(2);
$config = require($argv[1] ?? '');
if (isset($config['database']) && is_array($config['database'])) $config = $config['database'];
$database = $config['db'] ?? ($config['name'] ?? null);
if ($database !== EXPECTED_DATABASE) throw new RuntimeException('Unexpected database');
$sqlPath = $argv[2] ?? '';
$sbmlPath = $argv[3] ?? '';
if (!is_file($sqlPath) || !is_file($sbmlPath)) throw new RuntimeException('Migration SQL or SBML artifact missing');
if (!class_exists(DOMDocument::class)) throw new RuntimeException('PHP DOM extension is required');
$sha256 = hash_file('sha256', $sbmlPath);
if (!hash_equals(EXPECTED_SHA256, $sha256)) throw new RuntimeException('SBML SHA-256 mismatch');

$pdo = new PDO(
    'mysql:host='.$config['host'].';port='.($config['port'] ?? 3306).';dbname='.$database.';charset=utf8mb4',
    $config['user'],
    $config['pass'] ?? $config['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]
);
$migration = $pdo->prepare(file_get_contents($sqlPath));
$migration->execute();
do { if ($migration->columnCount()) $migration->fetchAll(); } while ($migration->nextRowset());
$migration->closeCursor();

$doc = new DOMDocument();
$doc->preserveWhiteSpace = false;
if (!$doc->load($sbmlPath, LIBXML_NONET)) throw new RuntimeException('Invalid SBML XML');
$xpath = new DOMXPath($doc);
$xpath->registerNamespace('s', 'http://www.sbml.org/sbml/level2/version4');

function boolAttr(DOMElement $node, string $name): int {
    return strtolower($node->getAttribute($name)) === 'true' ? 1 : 0;
}
function decimalAttr(DOMElement $node, string $name): ?string {
    $value = $node->getAttribute($name);
    return $value !== '' && is_numeric($value) ? $value : null;
}
function speciesRole(string $symbol): array {
    if (in_array($symbol, ['SC','TA','D','T','DC','A','IL17','IL23','TNF','GF'], true)) {
        return ['BIOLOGICAL_STATE','DIRECT_MEASUREMENT_REQUIRED'];
    }
    if ($symbol === 'PASI') return ['CLINICAL_OUTPUT','OBSERVATION_MODEL_REQUIRED'];
    if (in_array($symbol, ['UV','Bio','AdaT','AdaSQ','UstT','UstSQ'], true)) {
        return ['THERAPY_INPUT','INPUT_REQUIRED'];
    }
    if (in_array($symbol, ['totC','totD','A_per_1000','turnover','R','inflamm','thickness','desquam'], true)) {
        return ['DERIVED_OUTPUT','DERIVED'];
    }
    return ['OTHER','NOT_APPLICABLE'];
}
function parameterGovernance(string $symbol): array {
    if ($symbol === 'uv_eff' || str_starts_with($symbol, 'dc_stim_')) {
        return ['PATIENT_FITTED','PATIENT_VALUE_REQUIRED'];
    }
    if (in_array($symbol, ['uv_dose','dc_stim'], true)) {
        return ['PATIENT_FITTED','PATIENT_VALUE_REQUIRED'];
    }
    return ['UNCLASSIFIED','SOURCE_REVIEW_REQUIRED'];
}

$pdo->beginTransaction();
try {
    foreach (['ilb_psoriasis_sbml_reaction_species','ilb_psoriasis_sbml_reaction','ilb_psoriasis_sbml_parameter','ilb_psoriasis_sbml_species'] as $table) {
        $pdo->prepare("DELETE FROM {$table} WHERE model_key=?")->execute([MODEL_KEY]);
    }
    $insertSpecies = $pdo->prepare(
        'INSERT INTO ilb_psoriasis_sbml_species VALUES (?,?,?,?,?,?,?,?,?,?)'
    );
    foreach ($xpath->query('/s:sbml/s:model/s:listOfSpecies/s:species') as $node) {
        $symbol = $node->getAttribute('name') ?: $node->getAttribute('id');
        [$role,$gate] = speciesRole($symbol);
        $kind = 'UNSPECIFIED';
        $initial = null;
        if ($node->hasAttribute('initialAmount')) { $kind='AMOUNT'; $initial=decimalAttr($node,'initialAmount'); }
        elseif ($node->hasAttribute('initialConcentration')) { $kind='CONCENTRATION'; $initial=decimalAttr($node,'initialConcentration'); }
        $insertSpecies->execute([
            MODEL_KEY,$node->getAttribute('id'),$symbol,$node->getAttribute('compartment'),
            $initial,$kind,boolAttr($node,'boundaryCondition'),boolAttr($node,'constant'),$role,$gate
        ]);
    }

    $insertParameter = $pdo->prepare(
        'INSERT INTO ilb_psoriasis_sbml_parameter VALUES (?,?,?,?,?,?,?,?,?)'
    );
    foreach ($xpath->query('/s:sbml/s:model/s:listOfParameters/s:parameter') as $node) {
        $symbol = $node->getAttribute('name') ?: $node->getAttribute('id');
        [$provenance,$gate] = parameterGovernance($symbol);
        $insertParameter->execute([
            MODEL_KEY,'GLOBAL',$node->getAttribute('id'),$symbol,decimalAttr($node,'value'),
            $node->getAttribute('units') ?: null,boolAttr($node,'constant'),$provenance,$gate
        ]);
    }

    $insertReaction = $pdo->prepare('INSERT INTO ilb_psoriasis_sbml_reaction VALUES (?,?,?,?,?,?)');
    $insertParticipant = $pdo->prepare('INSERT INTO ilb_psoriasis_sbml_reaction_species VALUES (?,?,?,?,?)');
    foreach ($xpath->query('/s:sbml/s:model/s:listOfReactions/s:reaction') as $reaction) {
        $math = $xpath->query('./s:kineticLaw/*[local-name()="math"]', $reaction)->item(0);
        $mathml = $math ? $doc->saveXML($math) : '';
        if ($mathml === '') throw new RuntimeException('Reaction without kinetic MathML: '.$reaction->getAttribute('id'));
        $reactionId = $reaction->getAttribute('id');
        $insertReaction->execute([
            MODEL_KEY,$reactionId,$reaction->getAttribute('name') ?: $reactionId,
            boolAttr($reaction,'reversible'),$mathml,'BLOCKED_PARAMETER_PROVENANCE'
        ]);
        foreach ([['s:listOfReactants/s:speciesReference','REACTANT'],['s:listOfProducts/s:speciesReference','PRODUCT'],['s:listOfModifiers/s:modifierSpeciesReference','MODIFIER']] as [$path,$kind]) {
            foreach ($xpath->query('./'.$path, $reaction) as $participant) {
                $insertParticipant->execute([
                    MODEL_KEY,$reactionId,$participant->getAttribute('species'),$kind,
                    decimalAttr($participant,'stoichiometry')
                ]);
            }
        }
    }
    $counts = [
        'species'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_species WHERE model_key='".MODEL_KEY."'")->fetchColumn(),
        'parameters'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_parameter WHERE model_key='".MODEL_KEY."'")->fetchColumn(),
        'reactions'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_reaction WHERE model_key='".MODEL_KEY."'")->fetchColumn(),
        'participants'=>(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_reaction_species WHERE model_key='".MODEL_KEY."'")->fetchColumn(),
    ];
    $structureExact = $counts === ['species'=>EXPECTED_SPECIES,'parameters'=>EXPECTED_PARAMETERS,'reactions'=>EXPECTED_REACTIONS,'participants'=>EXPECTED_PARTICIPANTS];
    if (!$structureExact) throw new RuntimeException('Unexpected SBML structural counts: '.json_encode($counts));
    $pdo->prepare("UPDATE ilb_psoriasis_model_source SET artifact_sha256=?,imported_at=UTC_TIMESTAMP() WHERE model_key=?")
        ->execute([$sha256,MODEL_KEY]);
    $pdo->prepare("UPDATE ilb_psoriasis_model_gate SET status='PASSED',evidence_note=? WHERE model_key=? AND gate_code='G2_STRUCTURAL_IMPORT'")
        ->execute(['Exact production import: 25 species, 62 parameters, 35 reactions and 72 reaction participants.',MODEL_KEY]);
    $pdo->commit();
} catch (Throwable $e) {
    if ($pdo->inTransaction()) $pdo->rollBack();
    throw $e;
}

$readiness = $pdo->query("SELECT * FROM v_ilmb_psoriasis_published_model_readiness WHERE model_key='".MODEL_KEY."'")->fetch(PDO::FETCH_ASSOC);
$unclassified = (int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_sbml_parameter WHERE model_key='".MODEL_KEY."' AND provenance_class='UNCLASSIFIED'")->fetchColumn();
$output = [
    'database'=>$database,
    'model_key'=>MODEL_KEY,
    'artifact_sha256'=>$sha256,
    'source_artifact_exact'=>true,
    'species'=>(int)$readiness['species_count'],
    'parameters'=>(int)$readiness['parameter_count'],
    'reactions'=>(int)$readiness['reaction_count'],
    'reaction_participants'=>EXPECTED_PARTICIPANTS,
    'passed_gates'=>(int)$readiness['passed_gates'],
    'open_gates'=>(int)$readiness['open_gates'],
    'unclassified_parameters'=>$unclassified,
    'patient_execution_enabled'=>(int)$readiness['patient_execution_enabled'],
    'patient_rows_read'=>0,
    'patient_rows_modified'=>0,
    'ready_for_research_reproduction'=>true,
    'ready_for_patient_use'=>false
];
echo json_encode($output, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES), PHP_EOL;
if ($output['patient_execution_enabled'] !== 0 || $output['ready_for_patient_use'] !== false) exit(4);
