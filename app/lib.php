<?php
declare(strict_types=1);

function cfg(): array {
    static $config;
    if ($config === null) {
        $file = __DIR__ . '/config.php';
        if (!is_file($file)) {
            http_response_code(503);
            exit('App configuration is not installed.');
        }
        $config = require $file;
        date_default_timezone_set($config['app']['timezone'] ?? 'Asia/Kolkata');
    }
    return $config;
}

function db(): PDO {
    static $pdo;
    if ($pdo === null) {
        $c = cfg()['db'];
        $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s', $c['host'], $c['port'], $c['name'], $c['charset']);
        $pdo = new PDO($dsn, $c['user'], $c['pass'], [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }
    return $pdo;
}

function json_out(array $payload, int $status = 200): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit;
}

function request_data(): array {
    $raw = file_get_contents('php://input');
    $data = json_decode($raw ?: '{}', true);
    if (!is_array($data)) json_out(['ok' => false, 'error' => 'Invalid request.'], 400);
    return $data;
}

function start_private_session(): void {
    if (session_status() === PHP_SESSION_ACTIVE) return;
    $c=cfg();
    session_name($c['app']['cookie_name'] ?? 'ilb_app');
    session_set_cookie_params(['lifetime'=>0,'path'=>$c['app']['base_path']??'/app','secure'=>true,'httponly'=>true,'samesite'=>'Strict']);
    session_start();
}

function require_case(): array {
    start_private_session();
    $loginId=(string)($_SESSION['ilb_login_id']??'');
    if ($loginId==='') json_out(['ok'=>false,'error'=>'Please sign in.'],401);
    $stmt = db()->prepare(
        "SELECT a.login_id,a.public_case_key,a.subject_key,a.must_change_pin,f.frontend_label,f.allowed_age_display,
                f.allowed_sex_display
           FROM ilb_participant_login a
           JOIN ilb_subject_frontend_alias f ON f.public_case_key=a.public_case_key
          WHERE a.login_id=? AND a.status='active' AND f.status='active' LIMIT 1"
    );
    $stmt->execute([$loginId]);
    $case = $stmt->fetch();
    if (!$case) { session_destroy(); json_out(['ok'=>false,'error'=>'Please sign in again.'],401); }
    return $case;
}

function nullable_number(mixed $v): int|float|null {
    return ($v === '' || $v === null || !is_numeric($v)) ? null : $v + 0;
}

function bounded_score(mixed $v): ?int {
    $n = nullable_number($v);
    return $n === null ? null : max(0, min(10, (int)$n));
}

function text_or_null(mixed $v, int $max = 1000): ?string {
    $s = trim((string)($v ?? ''));
    return $s === '' ? null : mb_substr($s, 0, $max);
}

function safe_upload_dir(): string {
    $dir = cfg()['app']['upload_dir'];
    if (!is_dir($dir) && !mkdir($dir, 0700, true) && !is_dir($dir)) {
        throw new RuntimeException('Private upload directory is unavailable.');
    }
    return rtrim($dir, DIRECTORY_SEPARATOR);
}
