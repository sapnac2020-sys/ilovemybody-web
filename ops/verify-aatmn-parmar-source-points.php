<?php
declare(strict_types=1);
try {
  $c=require $argv[1]; if(isset($c['database'])) $c=$c['database'];
  $p=new PDO("mysql:host={$c['host']};dbname=".($c['db']??$c['name']).";charset=utf8mb4",
    $c['user'],$c['pass']??$c['password'],
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
  /* Reapply the immutable source transcription, then audit the live state. */
  $s=$p->prepare(file_get_contents($argv[2])); $s->execute();
  do { if($s->columnCount()) $s->fetchAll(); } while($s->nextRowset());
  $r=$p->query("SELECT COUNT(*) n,COUNT(DISTINCT point_code) distinct_n,
    COALESCE(SUM(medical_mapping_status='EXACT_MAPPED'),0) medical_mappings,
    COALESCE(SUM(source_status<>'SOURCE_RECORDED'),0) source_flags
    FROM ilb_aatmn_parmar_point_source")->fetch();
  $formulaCount=(int)$p->query("SELECT COUNT(*) FROM ilb_equation_registry")->fetchColumn();
  $ok=((int)$r['n']===271 && (int)$r['distinct_n']===271 &&
       (int)$r['medical_mappings']===0 && (int)$r['source_flags']===0 && $formulaCount===0);
  echo json_encode(['source_rows'=>(int)$r['n'],'unique_codes'=>(int)$r['distinct_n'],
    'medical_mappings'=>(int)$r['medical_mappings'],'source_flags'=>(int)$r['source_flags'],
    'formulas_in_engine'=>$formulaCount,'verified_source_transcription'=>$ok]),PHP_EOL;
  exit($ok?0:4);
} catch(Throwable $e) { echo 'AATMN_VERIFY_ERROR: '.$e->getMessage(),PHP_EOL; exit(1); }