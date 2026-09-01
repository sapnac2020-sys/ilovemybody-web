<?php
declare(strict_types=1);
if ($argc !== 3) { fwrite(STDERR, "Usage: php $argv[0] <config> <sql>\n"); exit(64); }
$config=require $argv[1]; $sql=file_get_contents($argv[2]);
$pdo=new PDO($config['dsn'],$config['username'],$config['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
$pdo->exec($sql);
$out=$pdo->query("SELECT
 (SELECT COUNT(*) FROM ilb_acupuncture_point_standard) acupuncture_points,
 (SELECT COUNT(*) FROM ilb_aatmn_acupuncture_crosswalk) crosswalks,
 (SELECT COUNT(*) FROM ilb_aatmn_formula_hypothesis) formula_hypotheses")->fetch(PDO::FETCH_ASSOC);
echo json_encode($out, JSON_PRETTY_PRINT), PHP_EOL;
