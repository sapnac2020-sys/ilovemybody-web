<?php
// Phase 119 verifier: conclusion and modality verdict registry.
require_once __DIR__ . '/../config/database.php';
header('Content-Type: application/json');
$out=['ok'=>false,'stage'=>'start'];
try {
  $pdo=getDBConnection();
  $out['database']=$pdo->query('SELECT DATABASE()')->fetchColumn();
  $sql=file_get_contents(__DIR__.'/../backend/phase_119_psoriasis_conclusion_modality_verdict.sql');
  $parts=preg_split('/;\s*(?:\r?\n|$)/',$sql);
  $n=0;
  foreach($parts as $stmt){$stmt=trim($stmt); if($stmt===''||str_starts_with($stmt,'--')) continue; $n++; $pdo->exec($stmt);} 
  $out['migration_statements']=$n;
  $count=(int)$pdo->query('SELECT COUNT(*) FROM ilb_psoriasis_modality_verdict')->fetchColumn();
  $ctx=(int)$pdo->query('SELECT COUNT(*) FROM ilb_psoriasis_context_primitive')->fetchColumn();
  $direct=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_modality_verdict WHERE verdict_class='REFERENCE_DIRECT_PATH'")->fetchColumn();
  $bad=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_modality_verdict WHERE modality_code IN ('HOMEOPATHY','BACH','LOUISE_HAY','REDIKALL') AND formula_bridge_status<>'NO_BRIDGE'")->fetchColumn();
  $cure=(string)$pdo->query('SELECT cure_claim_status FROM v_ilb_psoriasis_project_conclusion')->fetchColumn();
  $out['verdict_count']=$count; $out['context_primitive_count']=$ctx; $out['reference_direct_paths']=$direct; $out['unsafe_verification_bridges']=$bad; $out['cure_claim_status']=$cure;
  if($count<10) throw new Exception('Expected >=10 modality verdicts');
  if($ctx<5) throw new Exception('Expected >=5 context primitives');
  if($direct<1) throw new Exception('Missing reference direct non-drug path');
  if($bad!==0) throw new Exception('Verification-only frameworks promoted to biological bridge');
  if($cure!=='NO_UNIVERSAL_ALTERNATE_CURE_ESTABLISHED') throw new Exception('Unsafe cure conclusion');
  $out['ok']=true; $out['stage']='complete';
} catch(Throwable $e){$out['error']=$e->getMessage();$out['file']=$e->getFile();$out['line']=$e->getLine();}
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),"\n";
