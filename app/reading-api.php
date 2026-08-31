<?php
declare(strict_types=1);

/**
 * Record a daily reading as a locked, falsifiable prediction.
 *
 * The disciplines are enforced HERE, server side, for the same reason the
 * safety screen is: a modified browser must not be able to skip them.
 *
 *   1. A prediction is locked the moment it is written. predicted_at and
 *      locked_at are both set by the server from its own clock. The client
 *      never supplies either, so a prediction cannot be dated to suit an
 *      outcome that is already known.
 *
 *   2. This endpoint never returns a measurement. Not one value, in any
 *      action. If the reader could see today's numbers the test would be
 *      dead before it started, so the numbers are simply not reachable
 *      from here.
 *
 *   3. Every reading is matched by a control. When a reader submits, the
 *      server draws a random chakra and a random direction and writes a
 *      second row. That control arm measures the real chance rate instead
 *      of anyone assuming it.
 *
 *   4. Only markers with a personal baseline may be predicted. Without a
 *      baseline there is no direction to be right or wrong about.
 *
 * Resolution is deliberately a separate action that copies the outcome out
 * of vw_ilb_paired_outcome_available. Nobody chooses it by hand.
 *
 * Upload alongside lib.php and config.php.
 */

require __DIR__ . '/lib.php';

$pdo     = db();
$action  = $_GET['action'] ?? 'setup';
$case    = require_case();
$subject = (string)$case['subject_key'];
$reader  = (string)$case['public_case_key'];

/* ------------------------------------------------------------------ */
/* GET setup -- the vocabulary the form needs. No measurements.        */
/* ------------------------------------------------------------------ */

if ($action === 'setup' && $_SERVER['REQUEST_METHOD'] === 'GET') {

    // Only markers this subject has a personal baseline for.
    $stmt = $pdo->prepare(
        "SELECT b.marker_key, b.unit_text, m.name
           FROM ilb_subject_marker_baseline b
           LEFT JOIN ilb_marker m ON m.marker_key = b.marker_key
          WHERE b.subject_key = ? AND b.status <> 'retired'
          ORDER BY b.marker_key"
    );
    $stmt->execute([$subject]);
    $markers = $stmt->fetchAll();

    // The 272 points, grouped for a picker. Position and keyword only.
    $rows = $pdo->query(
        "SELECT chakra_code, region_key, side, position_text, foundation_keyword
           FROM ilb_redikall_minor_chakra
          ORDER BY FIELD(region_key,'face','neck','scalp','chest','abdomen',
                         'hands_arms','palms','back','vertebral',
                         'front_legs','back_legs','feet'), ordinal"
    )->fetchAll();

    $points = [];
    foreach ($rows as $r) {
        $points[$r['region_key']][] = [
            'code'     => $r['chakra_code'],
            'side'     => $r['side'],
            'position' => $r['position_text'],
            'keyword'  => $r['foundation_keyword'],
        ];
    }

    // Has a reading already been locked for today?
    $today = date('Y-m-d');
    $stmt = $pdo->prepare(
        "SELECT COUNT(*) FROM ilb_paired_observation
          WHERE subject_key = ? AND observation_date = ?
            AND prediction_source <> 'control_random'"
    );
    $stmt->execute([$subject, $today]);
    $alreadyToday = (int)$stmt->fetchColumn();

    json_out([
        'ok'            => true,
        'markers'       => $markers,
        'points'        => $points,
        'today'         => $today,
        'already_today' => $alreadyToday,
    ]);
}

/* ------------------------------------------------------------------ */
/* POST predict -- write it, lock it, and match it with a control      */
/* ------------------------------------------------------------------ */

if ($action === 'predict' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $in = request_data();

    $source    = (string)($in['prediction_source'] ?? '');
    $chakra    = text_or_null($in['chakra_code'] ?? null, 12);
    $marker    = (string)($in['predicted_marker_key'] ?? '');
    $direction = (string)($in['predicted_direction'] ?? '');
    $saw       = (string)($in['reader_saw_measurement'] ?? '');
    $rationale = text_or_null($in['rationale'] ?? null, 400);
    $date      = (string)($in['observation_date'] ?? date('Y-m-d'));

    $allowedSource = ['redikall_reading', 'model_derived', 'participant_report'];
    if (!in_array($source, $allowedSource, true)) {
        json_out(['ok' => false, 'error' => 'Choose who or what is making this reading.'], 400);
    }
    if (!in_array($direction, ['up', 'down', 'no_change'], true)) {
        json_out(['ok' => false, 'error' => 'Say which way you expect it to move.'], 400);
    }
    if (!in_array($saw, ['no', 'yes'], true)) {
        json_out(['ok' => false, 'error' => 'Please answer whether you have already seen today’s numbers.'], 400);
    }
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $date)) {
        json_out(['ok' => false, 'error' => 'That date is not readable.'], 400);
    }
    // A reading may not be dated into the future, and may not be back-dated:
    // both would break the pre-registration the whole design rests on.
    $today = date('Y-m-d');
    if ($date !== $today) {
        json_out(['ok' => false, 'error' => 'A reading can only be recorded for today. Back-dating would undo the point of locking it.'], 400);
    }

    // The marker must have a personal baseline for this subject.
    $stmt = $pdo->prepare(
        "SELECT COUNT(*) FROM ilb_subject_marker_baseline
          WHERE subject_key = ? AND marker_key = ? AND status <> 'retired'"
    );
    $stmt->execute([$subject, $marker]);
    if (!(int)$stmt->fetchColumn()) {
        json_out(['ok' => false, 'error' => 'That measure has no personal baseline yet, so there is nothing to be right or wrong about.'], 400);
    }

    if ($source === 'redikall_reading') {
        if ($chakra === null) {
            json_out(['ok' => false, 'error' => 'Name the point you are reading.'], 400);
        }
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM ilb_redikall_minor_chakra WHERE chakra_code = ?");
        $stmt->execute([$chakra]);
        if (!(int)$stmt->fetchColumn()) {
            json_out(['ok' => false, 'error' => 'That point code is not on the map.'], 400);
        }
    } else {
        $chakra = null;
    }

    // One reading per subject per day per source. Otherwise the arm can be
    // fished by submitting until one lands.
    $stmt = $pdo->prepare(
        "SELECT COUNT(*) FROM ilb_paired_observation
          WHERE subject_key = ? AND observation_date = ? AND prediction_source = ?"
    );
    $stmt->execute([$subject, $date, $source]);
    if ((int)$stmt->fetchColumn()) {
        json_out(['ok' => false, 'error' => 'A reading of that kind is already locked for today.'], 409);
    }

    $now = date('Y-m-d H:i:s');   // server clock only

    try {
        $pdo->beginTransaction();

        $ins = $pdo->prepare(
            "INSERT INTO ilb_paired_observation
               (subject_key, observation_date, prediction_source, reader_ref, chakra_code,
                predicted_marker_key, predicted_direction, rationale,
                predicted_at, locked_at, reader_saw_measurement, note)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
        );
        $ins->execute([
            $subject, $date, $source,
            in_array($source, ['redikall_reading', 'participant_report'], true) ? $reader : null,
            $chakra, $marker, $direction, $rationale,
            $now, $now, $saw,
            'Locked at write time by reading-api.php. predicted_at and locked_at are the server clock.',
        ]);
        $id = (int)$pdo->lastInsertId();

        // Matched control: a random point and a random direction.
        $controlId = null;
        if ($source === 'redikall_reading') {
            $stmt = $pdo->prepare(
                "SELECT COUNT(*) FROM ilb_paired_observation
                  WHERE subject_key = ? AND observation_date = ? AND prediction_source = 'control_random'"
            );
            $stmt->execute([$subject, $date]);
            if (!(int)$stmt->fetchColumn()) {
                $rand = $pdo->query(
                    "SELECT chakra_code FROM ilb_redikall_minor_chakra ORDER BY RAND() LIMIT 1"
                )->fetchColumn();
                $randDir = random_int(0, 1) ? 'up' : 'down';

                $ins->execute([
                    $subject, $date, 'control_random', null,
                    $rand, $marker, $randDir,
                    'Randomly drawn point and direction. This arm measures the real chance rate.',
                    $now, $now, 'no',
                    'Generated by the server alongside the reading it controls for.',
                ]);
                $controlId = (int)$pdo->lastInsertId();
            }
        }

        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        json_out(['ok' => false, 'error' => 'That could not be recorded.'], 500);
    }

    json_out([
        'ok'         => true,
        'id'         => $id,
        'control_id' => $controlId,
        'locked_at'  => $now,
        'counts'     => $saw === 'no',
    ]);
}

/* ------------------------------------------------------------------ */
/* GET pending -- locked predictions still waiting on a measurement    */
/* Returns no values. Only whether an outcome is available yet.        */
/* ------------------------------------------------------------------ */

if ($action === 'pending' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        "SELECT p.observation_id, p.observation_date, p.prediction_source,
                p.chakra_code, p.predicted_marker_key, p.predicted_direction,
                p.reader_saw_measurement,
                (SELECT COUNT(*) FROM vw_ilb_paired_outcome_available v
                  WHERE v.observation_id = p.observation_id) AS outcome_ready
           FROM ilb_paired_observation p
          WHERE p.subject_key = ?
            AND p.locked_at IS NOT NULL
            AND p.outcome_recorded_at IS NULL
            AND p.void_reason IS NULL
          ORDER BY p.observation_date DESC, p.observation_id DESC
          LIMIT 60"
    );
    $stmt->execute([$subject]);
    json_out(['ok' => true, 'pending' => $stmt->fetchAll()]);
}

/* ------------------------------------------------------------------ */
/* POST resolve -- copy the outcome out of the view. No human choice.  */
/* ------------------------------------------------------------------ */

if ($action === 'resolve' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $stmt = $pdo->prepare(
        "SELECT v.observation_id, v.available_measurement_id, v.available_value,
                v.available_baseline, v.implied_outcome_direction
           FROM vw_ilb_paired_outcome_available v
           JOIN ilb_paired_observation p ON p.observation_id = v.observation_id
          WHERE p.subject_key = ? AND v.implied_outcome_direction IS NOT NULL"
    );
    $stmt->execute([$subject]);
    $ready = $stmt->fetchAll();

    if (!$ready) json_out(['ok' => true, 'resolved' => 0, 'note' => 'Nothing has a measurement waiting.']);

    $now = date('Y-m-d H:i:s');
    $upd = $pdo->prepare(
        "UPDATE ilb_paired_observation
            SET outcome_measurement_id = ?, outcome_value = ?, outcome_baseline = ?,
                outcome_direction = ?, outcome_recorded_at = ?,
                outcome_source = 'Resolved from vw_ilb_paired_outcome_available. Direction derived from the personal baseline, not chosen.'
          WHERE observation_id = ? AND subject_key = ?
            AND locked_at IS NOT NULL AND outcome_recorded_at IS NULL"
    );

    $n = 0;
    foreach ($ready as $r) {
        $upd->execute([
            $r['available_measurement_id'], $r['available_value'], $r['available_baseline'],
            $r['implied_outcome_direction'], $now, $r['observation_id'], $subject,
        ]);
        $n += $upd->rowCount();
    }
    json_out(['ok' => true, 'resolved' => $n]);
}

/* ------------------------------------------------------------------ */
/* GET progress -- counts only, never a measurement                    */
/* ------------------------------------------------------------------ */

if ($action === 'progress' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        "SELECT prediction_source, predicted_marker_key, valid_pairs, hits,
                hit_rate_pct, pairs_still_needed_for_medium_effect, power_status
           FROM vw_ilb_paired_progress
          WHERE subject_key = ?
          ORDER BY predicted_marker_key, prediction_source"
    );
    $stmt->execute([$subject]);
    json_out(['ok' => true, 'progress' => $stmt->fetchAll()]);
}

json_out(['ok' => false, 'error' => 'Unknown request.'], 404);
