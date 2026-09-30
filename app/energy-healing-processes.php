<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__.'lib.php';
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
function pm_h(mixed $s):string{return htmlspecialchars((string)$s,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
function pm_source(?string $url,string $locator):void{
 echo '<small>'.pm_h($locator);
 if($url && preg_match('#^https://#',$url))echo ' · <a rel="noopener noreferrer" href="'.pm_h($url).'">Source</a>';
 echo '</small>';
}
try{
 $sql="SELECT m.*,p.practice_name FROM ilb_ehr_process_map m JOIN ilb_ehr_practice p ON p.practice_code=m.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE p.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED'";
 $outcomes=db()->query("SELECT DISTINCT m.outcome_label FROM ilb_ehr_process_map m JOIN ilb_ehr_practice p ON p.practice_code=m.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE p.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' ORDER BY m.outcome_label")->fetchAll(PDO::FETCH_COLUMN);
 $outcome=(string)($_GET['outcome']??($outcomes[0]??''));
 if(!in_array($outcome,$outcomes,true)){http_response_code(404);exit('Process comparison not available.');}
 $st=db()->prepare($sql." AND m.outcome_label=? ORDER BY p.practice_name");$st->execute([$outcome]);$maps=$st->fetchAll();
 $st=db()->prepare("SELECT * FROM ilb_ehr_process_connection WHERE map_code=? ORDER BY sequence_position IS NULL,sequence_position,connection_code");
 $connections=[];foreach($maps as $map){$st->execute([$map['map_code']]);$connections[$map['map_code']]=$st->fetchAll();}
}catch(Throwable $e){http_response_code(503);exit('Process research is being prepared. Please try again later.');}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?=pm_h($outcome)?> | Process comparison</title>
<style>body{margin:0;background:#102321;color:#edf5ef;font:17px/1.6 system-ui}main{max-width:1100px;margin:auto;padding:24px}a{color:#b8e6c4}nav{display:flex;gap:16px;flex-wrap:wrap}article,details{padding:18px;margin:16px 0;border:1px solid #52786b;border-radius:16px;background:#19342f}h1{line-height:1.2}small{color:#bcd0c6}summary{cursor:pointer;font-weight:600}dl{display:grid;grid-template-columns:minmax(130px,1fr) 3fr;gap:8px}dt{font-weight:600}dd{margin:0;overflow-wrap:anywhere}@media(max-width:600px){main{padding:16px}dl{display:block}dd{margin-bottom:12px}}</style></head><body><main>
<nav><a href="/app/energy-healing.php">Healing research</a><a href="/app/energy-healing-record.php">My private session log</a></nav>
<p>Energy Healing Research Department</p><h1>Process comparison</h1><h2><?=pm_h($outcome)?></h2>
<p>Compare documented actions, proposed targets and evidence for the same outcome. This is a research map, not a self-treatment sequence. Shared targets are leads for investigation; they do not establish a shared mechanism.</p>
<nav aria-label="Research outcomes"><?php foreach($outcomes as $o):?><a href="?outcome=<?=urlencode($o)?>"><?=pm_h($o)?></a><?php endforeach;?></nav>
<?php foreach($maps as $m):?><article><h2><a href="/app/energy-healing.php?practice=<?=urlencode($m['practice_code'])?>"><?=pm_h($m['practice_name'])?></a></h2>
<dl><dt>Sequence coverage</dt><dd><?=pm_h($m['sequence_status'])?></dd><dt>Self-practice for this outcome</dt><dd><?=pm_h($m['self_practice_status'])?></dd></dl>
<p><?=pm_h($m['notes_text'])?></p><?php pm_source($m['source_url'],$m['source_locator']);?>
<?php if(!$connections[$m['map_code']]):?><p>No process connections extracted yet.</p><?php endif;?>
<?php foreach($connections[$m['map_code']] as $c):?><details><summary><?=pm_h($c['proposed_effect'])?></summary><dl>
<dt>Step position</dt><dd><?=pm_h($c['sequence_position']??'Not established')?></dd>
<dt>Documented action</dt><dd><?=pm_h($c['action_text']??'Not available in the reviewed source')?></dd>
<dt>Tradition target</dt><dd><?=pm_h($c['tradition_target']??'Not specified')?></dd>
<dt>Biological target</dt><dd><?=pm_h($c['biological_target']??'Not established')?></dd>
<dt>Record type</dt><dd><?=pm_h($c['relationship_status'])?></dd>
<dt>Evidence that the modality causes this effect</dt><dd><?=pm_h($c['modality_causal_status'])?></dd>
</dl><p><?=pm_h($c['evidence_notes'])?></p><?php pm_source($c['source_url'],$c['source_locator']);?></details><?php endforeach;?></article><?php endforeach;?>
<footer><p>Weight, waist circumference and body fat are different observations. Clinical measurements use existing approved LOINC mappings where compatible. Personal records remain behind sign-in.</p></footer>
</main></body></html>
