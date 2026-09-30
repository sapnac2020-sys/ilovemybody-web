<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__.'/lib.php';
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
function conv_h(mixed $v):string{return htmlspecialchars((string)$v,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
try{
 $rows=db()->query("SELECT f.*,o.*,p.practice_name FROM ilb_ehr_convergence_feature f JOIN ilb_ehr_convergence_observation o ON o.feature_code=f.feature_code JOIN ilb_ehr_practice p ON p.practice_code=o.practice_code JOIN ilb_ehr_catalogue c ON c.practice_code=p.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' ORDER BY f.feature_name,p.practice_name")->fetchAll();
 $total=(int)db()->query("SELECT COUNT(*) FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED'")->fetchColumn();
}catch(Throwable $e){http_response_code(503);exit('The convergence comparison is being prepared. Please try again later.');}
$groups=[];$practices=[];foreach($rows as $r){$groups[$r['feature_code']][]=$r;$practices[$r['practice_code']]=true;}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Convergence comparison | Energy Healing Research</title><style>body{margin:0;background:#102321;color:#edf5ef;font:17px/1.6 system-ui}main{max-width:1000px;margin:auto;padding:24px}a{color:#b8e6c4}nav{display:flex;gap:18px;flex-wrap:wrap}article{padding:20px;margin:18px 0;border:1px solid #52786b;border-radius:16px;background:#19342f}h1,h2,h3{line-height:1.25}p{overflow-wrap:anywhere}small{color:#bcd0c6}</style></head><body><main>
<nav><a href="/app/energy-healing-catalogue.php">All modalities</a><a href="/app/energy-healing-processes.php">Outcome processes</a><a href="/app/energy-healing.php">Research entries</a></nav>
<h1>Convergence comparison</h1>
<p><?=count($groups)?> candidate themes · <?=count($practices)?> modalities with documented components · <?=$total?> catalogue records.</p>
<p>This first extraction compares public teaching descriptions. It is not a complete assessment of the catalogue. An unlisted modality or component is not an absence finding. Counts describe source coverage, not efficacy, independence of traditions or strength of evidence.</p>
<p>Recurring actions can generate hypotheses. They do not establish a shared energy field, biological mechanism, weight-loss effect or treatment. Practitioner instructions require a separate review before any self-practice adaptation.</p>
<?php foreach($groups as $items):$first=$items[0];?>
<section><h2><?=conv_h($first['feature_name'])?> · <?=count($items)?> documented modalities</h2><p><?=conv_h($first['interpretation_limit'])?></p>
<?php foreach($items as $r):?><article><h3><?=conv_h($r['practice_name'])?></h3><p><?=conv_h($r['action_text'])?></p>
<p>Delivery scope: <?=conv_h($r['delivery_scope'])?> · Component: <?=conv_h($r['component_status'])?> · Finding: <?=conv_h($r['finding_status'])?></p>
<p><?=conv_h($r['limitation_text'])?></p>
<p><a href="<?=conv_h($r['source_url'])?>" rel="noopener noreferrer">Read source</a> · <?=conv_h($r['source_locator'])?> · Checked <?=conv_h($r['source_checked_on'])?></p></article><?php endforeach;?></section><?php endforeach;?>
<h2>How we test a connection</h2>
<p>Next, extract an outcome-specific procedure and separate its actions, duration, self-practice suitability and tradition claims. Compare the same measured outcome, baseline, follow-up, comparator and other influences across methods. Similar improvement alone cannot identify the cause.</p>
<p>Use verified LOINC mappings for relevant clinical observations where available; breathing, intention and proposed subtle energy are not assigned invented LOINC codes. No clinical validation is claimed by this comparison.</p>
</main></body></html>
