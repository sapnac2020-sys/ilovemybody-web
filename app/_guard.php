<?php
declare(strict_types=1);
/**
 * Environment gate.
 *
 * Production patient access on ilovemybody.in is public at the HTTP layer and
 * protected by the app's own authentication/session checks. Non-production
 * hosts remain behind the staging token gate.
 */
$host = strtolower(preg_replace('/:\d+$/', '', (string)($_SERVER['HTTP_HOST'] ?? '')));
if (in_array($host, ['ilovemybody.in', 'www.ilovemybody.in'], true)) {
    header('X-Robots-Tag: noindex, nofollow, noarchive');
    return;
}

$tokenFile = '/home/u756742628/domains/ilovemybody.in/private/stage_token.txt';
$token = is_readable($tokenFile) ? trim((string)file_get_contents($tokenFile)) : '';
if ($token === '') { http_response_code(500); exit('Staging token missing.'); }

$expect = hash('sha256', 'ilb-stage|' . $token);
$cookie = (string)($_COOKIE['ilb_stage_pass'] ?? '');

if (isset($_GET['unlock']) && hash_equals($token, (string)$_GET['unlock'])) {
    setcookie('ilb_stage_pass', $expect, [
        'expires'  => time() + 60*60*24*30,
        'path'     => '/',
        'secure'   => true,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    $clean = strtok((string)($_SERVER['REQUEST_URI'] ?? '/'), '?');
    header('Location: ' . $clean, true, 302);
    exit;
}

if (!hash_equals($expect, $cookie)) {
    http_response_code(404);
    header('Content-Type: text/html; charset=utf-8');
    header('X-Robots-Tag: noindex, nofollow, noarchive');
    exit('<!doctype html><title>404</title><h1>404</h1><p>Not found.</p>');
}
header('X-Robots-Tag: noindex, nofollow, noarchive');
