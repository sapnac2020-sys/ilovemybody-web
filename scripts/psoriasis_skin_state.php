<?php
declare(strict_types=1);

/*
 * Source-exact two-state psoriasis model ported from:
 * https://github.com/pzuliani/psoriasis/blob/main/matlab/simple_model.m
 *
 * K: proliferative keratinocytes per mm^2
 * T: activated immune cells per mm^2
 * Rates: cells per mm^2 per day
 */

const A_KT = 3.1746031746e-5;
const B_K2 = 1.5873015873e-6;
const V_T  = 1026.6666667;
const H_K2 = 7.02e9;
const T_IN = 100.0;
const D_T  = 0.1444444444;

function derivatives(float $K, float $T): array
{
    if (!is_finite($K) || !is_finite($T) || $K < 0.0 || $T < 0.0) {
        throw new InvalidArgumentException('K and T must be finite non-negative densities.');
    }

    $k2 = $K * $K;
    $dKdt = A_KT * $T * $K - B_K2 * $k2;
    $dTdt = V_T * $k2 / (H_K2 + $k2) + T_IN - D_T * $T;

    return [
        'K_cells_per_mm2' => $K,
        'T_cells_per_mm2' => $T,
        'dK_dt_cells_per_mm2_per_day' => $dKdt,
        'dT_dt_cells_per_mm2_per_day' => $dTdt,
        'skin_direction' => $dKdt < 0.0 ? 'TOWARD_LOWER_K' : ($dKdt > 0.0 ? 'TOWARD_HIGHER_K' : 'KERATINOCYTE_EQUILIBRIUM'),
        'immune_direction' => $dTdt < 0.0 ? 'TOWARD_LOWER_T' : ($dTdt > 0.0 ? 'TOWARD_HIGHER_T' : 'IMMUNE_EQUILIBRIUM'),
    ];
}

function selfTest(): array
{
    $states = [
        'healthy' => [30000.0, 1500.0],
        'transition' => [36000.0, 1800.0],
        'psoriatic' => [90000.0, 4500.0],
    ];
    $tolerance = 1.0e-5;
    $results = [];
    $passed = true;

    foreach ($states as $name => [$K, $T]) {
        $result = derivatives($K, $T);
        $residual = max(abs($result['dK_dt_cells_per_mm2_per_day']), abs($result['dT_dt_cells_per_mm2_per_day']));
        $ok = $residual <= $tolerance;
        $passed = $passed && $ok;
        $results[$name] = ['residual_max' => $residual, 'passed' => $ok] + $result;
    }

    return [
        'calculator' => 'psoriasis_skin_state',
        'source_model' => 'pzuliani/psoriasis matlab/simple_model.m',
        'tolerance' => $tolerance,
        'passed' => $passed,
        'states' => $results,
        'patient_rows_read' => 0,
        'patient_rows_modified' => 0,
    ];
}

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

try {
    if (($argv[1] ?? '') === '--self-test') {
        $output = selfTest();
        echo json_encode($output, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), PHP_EOL;
        exit($output['passed'] ? 0 : 4);
    }
    if (count($argv) !== 3 || !is_numeric($argv[1]) || !is_numeric($argv[2])) {
        fwrite(STDERR, "Usage: php scripts/psoriasis_skin_state.php --self-test\n");
        fwrite(STDERR, "   or: php scripts/psoriasis_skin_state.php K_cells_per_mm2 T_cells_per_mm2\n");
        exit(2);
    }
    $result = derivatives((float)$argv[1], (float)$argv[2]);\n    $result['governance'] = [\n        'provenance_status' => 'ASSUMPTION_BASED_REDUCED_MODEL',\n        'patient_execution_allowed' => false,\n        'interpretation' => 'Research reproduction only; values are not patient targets.',\n    ];\n    echo json_encode($result, JSON_PRETTY_PRINT), PHP_EOL;
} catch (Throwable $e) {
    fwrite(STDERR, $e->getMessage() . PHP_EOL);
    exit(3);
}
