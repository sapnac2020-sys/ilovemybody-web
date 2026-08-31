<?php
declare(strict_types=1);

require __DIR__ . '/_guard.php';
/**
 * Record a body signal event.
 *
 * The safety screen is enforced HERE, not in the browser. A modified client
 * must not be able to skip it: the server looks up requires_safety_screen
 * itself and refuses to write until an acknowledgement comes back. This
 * mirrors the rule already applied to chat moderation elsewhere in the estate.
 *
 * Nothing in this file interprets a signal. ilb_feedback_safety_policy
 * blocks diagnosis, prescription and cure claims; recording is not analysis,
 * and the two must not be run together.
 *
 * Upload alongside lib.php and config.php.
 */

require __DIR__ . '/lib.php';

$pdo    = db();
$action = $_GET['action'] ?? 'types';
$case   = require_case();                 // 401s if not signed in
$subject = (string)$case['subject_key'];

/* ------------------------------------------------------------------ */
/* GET types -- the vocabulary, straight from the table                */
/* ------------------------------------------------------------------ */

if ($action === 'types' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $rows = $pdo->query(
        "SELECT signal_type_key, signal_group, display_name,
                plain_language_prompt, requires_safety_screen
           FROM ilb_body_signal_type
          WHERE status = 'active'
          ORDER BY signal_group, display_name"
    )->fetchAll();

    $grouped = [];
    foreach ($rows as $r) {
        $grouped[$r['signal_group']][] = [
            'key'    => $r['signal_type_key'],
            'name'   => $r['display_name'],
            'prompt' => $r['plain_language_prompt'],
            'screen' => (bool)(int)$r['requires_safety_screen'],
        ];
    }
    json_out(['ok' => true, 'groups' => $grouped]);
}

/* ------------------------------------------------------------------ */
/* GET recent -- this subject's own entries only                      */
/* ------------------------------------------------------------------ */

if ($action === 'recent' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $stmt = $pdo->prepare(
        "SELECT e.body_signal_id, e.signal_type_key, t.display_name, t.signal_group,
                e.signal_text, e.body_location_text, e.observed_at, e.intensity_score,
                e.familiarity, e.participant_concern
           FROM ilb_body_signal_event e
           JOIN ilb_body_signal_type t ON t.signal_type_key = e.signal_type_key
          WHERE e.subject_key = ?
          ORDER BY e.observed_at DESC
          LIMIT 25"
    );
    $stmt->execute([$subject]);
    json_out(['ok' => true, 'events' => $stmt->fetchAll()]);
}

/* ------------------------------------------------------------------ */
/* Safety resources -- read from the table, never hardcoded            */
/* ------------------------------------------------------------------ */

function safety_resources(PDO $pdo): array {
    return $pdo->query(
        "SELECT resource_name, operator_name, phone_primary, phone_alternate,
                contact_url, hours_text, languages_text, cost_text
           FROM ilb_safety_resource
          WHERE status = 'active'
          ORDER BY display_order, resource_name"
    )->fetchAll();
}

/* ------------------------------------------------------------------ */
/* POST save                                                           */
/* ------------------------------------------------------------------ */

if ($action === 'save' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $d = request_data();

    /* --- the signal type must exist and be active --- */
    $typeKey = trim((string)($d['signal_type_key'] ?? ''));
    $stmt = $pdo->prepare(
        "SELECT signal_type_key, display_name, requires_safety_screen
           FROM ilb_body_signal_type
          WHERE signal_type_key = ? AND status = 'active' LIMIT 1"
    );
    $stmt->execute([$typeKey]);
    $type = $stmt->fetch();
    if (!$type) {
        json_out(['ok' => false, 'error' => 'Choose what you noticed from the list.'], 422);
    }

    /* --- what was noticed --- */
    $text = trim((string)($d['signal_text'] ?? ''));
    if ($text === '') {
        json_out(['ok' => false, 'error' => 'Describe what you noticed, in your own words.'], 422);
    }
    if (mb_strlen($text) > 500) {
        json_out(['ok' => false, 'error' => 'Please keep this under 500 characters.'], 422);
    }

    $location = trim((string)($d['body_location_text'] ?? ''));
    $location = ($location === '') ? null : mb_substr($location, 0, 255);

    /* --- when. Never in the future; the DB also checks ended >= observed --- */
    $observed = strtotime((string)($d['observed_at'] ?? ''));
    if ($observed === false) {
        json_out(['ok' => false, 'error' => 'When did you notice this?'], 422);
    }
    if ($observed > time() + 300) {
        json_out(['ok' => false, 'error' => 'That time is in the future.'], 422);
    }

    $endedRaw = trim((string)($d['ended_at'] ?? ''));
    $ended = null;
    if ($endedRaw !== '') {
        $ended = strtotime($endedRaw);
        if ($ended === false) {
            json_out(['ok' => false, 'error' => 'That end time could not be read.'], 422);
        }
        if ($ended < $observed) {
            json_out(['ok' => false, 'error' => 'It cannot have ended before it began.'], 422);
        }
    }

    /* --- intensity is optional; 0 is a real answer, so check for '' not falsy --- */
    $intensityRaw = $d['intensity_score'] ?? '';
    $intensity = null;
    if ($intensityRaw !== '' && $intensityRaw !== null) {
        if (!is_numeric($intensityRaw)) {
            json_out(['ok' => false, 'error' => 'Strength should be a number from 0 to 10.'], 422);
        }
        $intensity = (int)$intensityRaw;
        if ($intensity < 0 || $intensity > 10) {
            json_out(['ok' => false, 'error' => 'Strength should be between 0 and 10.'], 422);
        }
    }

    $frequency = trim((string)($d['frequency_pattern'] ?? ''));
    $frequency = ($frequency === '') ? null : mb_substr($frequency, 0, 255);

    $context = trim((string)($d['preceding_context_text'] ?? ''));
    $context = ($context === '') ? null : $context;

    $familiarity = (string)($d['familiarity'] ?? 'unsure');
    if (!in_array($familiarity, ['new', 'familiar', 'changed', 'unsure'], true)) {
        $familiarity = 'unsure';
    }

    $concern = (string)($d['participant_concern'] ?? 'none');
    if (!in_array($concern, ['none', 'low', 'moderate', 'high', 'urgent'], true)) {
        $concern = 'none';
    }

    /* ---------------------------------------------------------------- */
    /* The safety gate.                                                 */
    /*                                                                  */
    /* Fires when the signal type is flagged, OR when the person has    */
    /* told us they are worried. The second half matters: someone       */
    /* saying "urgent" about an unflagged signal is asking for help,    */
    /* and ilb_safety_trigger.participant_asks_help is explicit that a  */
    /* request is not detection and must always be honoured.            */
    /* ---------------------------------------------------------------- */

    $needsScreen = ((int)$type['requires_safety_screen'] === 1)
                || in_array($concern, ['high', 'urgent'], true);

    $acknowledged = !empty($d['safety_acknowledged']);

    if ($needsScreen && !$acknowledged) {
        json_out([
            'ok'          => false,
            'safety'      => true,
            'signal_name' => $type['display_name'],
            'urgency'     => ($concern === 'urgent') ? 'urgent_prompt' : 'prompt_review',
            'resources'   => safety_resources($pdo),
        ], 200);
    }

    /* --- write the event and, if raised, the safety record together --- */
    $channel = preg_match('/Mobi|Android|iPhone|iPad/i', (string)($_SERVER['HTTP_USER_AGENT'] ?? ''))
        ? 'self_mobile' : 'self_web';

    $pdo->beginTransaction();
    try {
        $ins = $pdo->prepare(
            "INSERT INTO ilb_body_signal_event
                (subject_key, signal_type_key, signal_text, body_location_text,
                 observed_at, ended_at, intensity_score, frequency_pattern,
                 preceding_context_text, familiarity, participant_concern,
                 capture_channel, verification_status)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,'self_reported')"
        );
        $ins->execute([
            $subject, $typeKey, $text, $location,
            date('Y-m-d H:i:s', $observed),
            $ended === null ? null : date('Y-m-d H:i:s', $ended),
            $intensity, $frequency, $context, $familiarity, $concern, $channel,
        ]);
        $signalId = (int)$pdo->lastInsertId();

        $raised = false;
        if ($needsScreen) {
            $trigger = ($concern === 'urgent' || $concern === 'high')
                ? 'participant_asks_help'
                : 'pre10_safety_item';
            $urgency = ($concern === 'urgent') ? 'urgent_prompt' : 'prompt_review';

            $pdo->prepare(
                "INSERT INTO ilb_safety_event
                    (subject_key, trigger_key, source_kind, source_ref, occurred_at,
                     urgency, raised_by, pathway_shown_at, resolution_status)
                 VALUES (?,?, 'body_signal', ?, NOW(), ?, ?, NOW(), 'open')"
            )->execute([
                $subject,
                $trigger,
                'ilb_body_signal_event:' . $signalId,
                $urgency,
                ($concern === 'urgent' || $concern === 'high') ? 'participant' : 'system',
            ]);
            $raised = true;
        }

        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        error_log('signal save failed: ' . $e->getMessage());
        json_out(['ok' => false, 'error' => 'That could not be saved. Please try again.'], 500);
    }

    json_out([
        'ok'            => true,
        'body_signal_id'=> $signalId,
        'safety_raised' => $raised,
        'resources'     => $raised ? safety_resources($pdo) : [],
    ]);
}

json_out(['ok' => false, 'error' => 'Unknown action.'], 404);
