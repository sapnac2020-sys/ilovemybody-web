<?php
declare(strict_types=1);

/**
 * Download the approved Saral Pavan master from Google Drive into private intake.
 * CLI only. It never publishes the workbook and never writes under public_html.
 *
 * php scripts/sync_master_from_drive.php --private-root=/absolute/path/to/saralpavan_private
 */
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }

function base64url(string $value): string {
    return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
}
function loadConfig(string $privateRoot): array {
    $path = $privateRoot . '/config.php';
    if (!is_file($path)) { throw new RuntimeException("Missing private config: {$path}"); }
    $config = require $path;
    if (!isset($config['db'], $config['drive']['master_file_id'], $config['drive']['service_account_key'])) {
        throw new RuntimeException('Private config is incomplete.');
    }
    return $config;
}
function accessToken(array $key): string {
    $now = time();
    $header = base64url(json_encode(['alg' => 'RS256', 'typ' => 'JWT'], JSON_THROW_ON_ERROR));
    $claims = base64url(json_encode([
        'iss' => $key['client_email'],
        'scope' => 'https://www.googleapis.com/auth/drive.readonly',
        'aud' => $key['token_uri'] ?? 'https://oauth2.googleapis.com/token',
        'iat' => $now,
        'exp' => $now + 3600,
    ], JSON_THROW_ON_ERROR));
    $input = $header . '.' . $claims;
    if (!openssl_sign($input, $signature, $key['private_key'], OPENSSL_ALGO_SHA256)) {
        throw new RuntimeException('Could not sign service-account token.');
    }
    $assertion = $input . '.' . base64url($signature);
    $curl = curl_init($key['token_uri'] ?? 'https://oauth2.googleapis.com/token');
    curl_setopt_array($curl, [
        CURLOPT_POST => true, CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POSTFIELDS => http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $assertion,
        ]),
        CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
    ]);
    $body = curl_exec($curl); $code = (int)curl_getinfo($curl, CURLINFO_RESPONSE_CODE); curl_close($curl);
    $data = json_decode((string)$body, true);
    if ($code !== 200 || empty($data['access_token'])) throw new RuntimeException('Google token request failed.');
    return $data['access_token'];
}
$options = getopt('', ['private-root:','download-only']);
$privateRoot = rtrim((string)($options['private-root'] ?? dirname(__DIR__, 2) . '/saralpavan_private'), '/');
$config = loadConfig($privateRoot);
$keyPath = $config['drive']['service_account_key'];
if ($keyPath[0] !== '/') $keyPath = dirname($privateRoot) . '/' . ltrim($keyPath, '/');
if (!is_readable($keyPath)) throw new RuntimeException("Service account key is not readable: {$keyPath}");
$key = json_decode((string)file_get_contents($keyPath), true, 512, JSON_THROW_ON_ERROR);
$token = accessToken($key);
$incoming = $privateRoot . '/incoming';
if (!is_dir($incoming) || !is_writable($incoming)) throw new RuntimeException("Private intake is not writable: {$incoming}");
$fileId = $config['drive']['master_file_id'];
$fileName = 'Saral_Pavan_Excel_Production_Master_v1.0.xlsx';
$temp = tempnam($incoming, 'drive-');
$curl = curl_init('https://www.googleapis.com/drive/v3/files/' . rawurlencode($fileId) . '?alt=media');
$fh = fopen($temp, 'wb');
curl_setopt_array($curl, [CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $token], CURLOPT_FILE => $fh, CURLOPT_FOLLOWLOCATION => true]);
$ok = curl_exec($curl); $code = (int)curl_getinfo($curl, CURLINFO_RESPONSE_CODE); curl_close($curl); fclose($fh);
if (!$ok || $code !== 200 || filesize($temp) < 1024) { @unlink($temp); throw new RuntimeException('Google Drive workbook download failed.'); }
$hash = hash_file('sha256', $temp);
$target = $incoming . '/' . $fileName;
rename($temp, $target);
$db=$config['db'];
$pdo=new PDO(sprintf('mysql:host=%s;dbname=%s;charset=%s',$db['host'],$db['name'],$db['charset']),$db['user'],$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$syncId = bin2hex(random_bytes(16));
$statement=$pdo->prepare('INSERT INTO cg_workbook_sync (sync_id,direction,drive_file_id,workbook_name,workbook_sha256,status,rows_written,completed_at) VALUES (?,?,?,?,?,?,?,UTC_TIMESTAMP())');
$statement->execute([$syncId,'DRIVE_TO_INTAKE',$fileId,$fileName,$hash,'DOWNLOADED',0]);
if (array_key_exists('download-only', $options)) {
    echo "DOWNLOADED {$target}\nSHA256 {$hash}\nSYNC {$syncId}\n";
    exit(0);
}
$bridge = dirname(__DIR__) . '/scripts/cosmos_master_import.php';
if (!is_file($bridge)) throw new RuntimeException('Excel bridge is missing from deployed repository.');
$command = escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg($bridge)
    . ' --workbook=' . escapeshellarg($target)
    . ' --private-root=' . escapeshellarg($privateRoot) . ' 2>&1';
exec($command, $bridgeOutput, $bridgeCode);
if ($bridgeCode !== 0) {
    $pdo->prepare('UPDATE cg_workbook_sync SET status="REJECTED", error_summary=?, completed_at=UTC_TIMESTAMP() WHERE sync_id=?')
        ->execute([implode("\n", $bridgeOutput), $syncId]);
    throw new RuntimeException('Workbook download succeeded but the source-first cosmos import was rejected.');
}
echo "DOWNLOADED + COSMOS IMPORTED {$target}\nSHA256 {$hash}\nSYNC {$syncId}\n" . implode("\n", $bridgeOutput) . "\n";
