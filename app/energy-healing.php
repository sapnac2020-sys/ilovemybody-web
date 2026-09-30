<?php
declare(strict_types=1);
require __DIR__ . '/_guard.php';
require __DIR__ . '/lib.php';
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
function ehr_h(mixed $s): string { return htmlspecialchars((string)$s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
try {
 $p=db()->query("SELECT p.practice_code,p.practice_name,p.description_text FROM ilb_ehr_practice p JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE p.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' ORDER BY p.practice_name")->fetchAll();
 $code=(string)($_GET['practice']??'PRANIC_HEALING');
 $practice=null; foreach($p as $x) if($x['practice_code']===$code) $practice=$x;
 if(!$practice){http_response_code(404);exit('Research entry not published.');}
 $st=db()->prepare("SELECT a.*,s.title AS source_title,s.source_url FROM ilb_ehr_section a LEFT JOIN ilb_ehr_source s ON s.source_key=a.source_key AND s.publication_status='PUBLISHED' WHERE a.practice_code=? AND a.publication_status='PUBLISHED' ORDER BY a.position_no");
 $st->execute([$code]);$sections=$st->fetchAll();
 $st=db()->prepare("SELECT claim_text,claim_kind,evidence_status,conclusion_text FROM ilb_ehr_claim WHERE practice_code=? AND publication_status='PUBLISHED' ORDER BY claim_id");
 $st->execute([$code]);$claims=$st->fetchAll();
} catch(Throwable $e){http_response_code(503);exit('Research content is being prepared. Please try again later.');}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title><?=ehr_h($practice['practice_name'])?> | Energy Healing Research</title>
<style>body{margin:0;background:#102321;color:#edf5ef;font:17px/1.6 system-ui}main{max-width:900px;margin:auto;padding:24px}a{color:#b8e6c4}nav{display:flex;gap:18px;flex-wrap:wrap}article,details{padding:20px;margin:18px 0;border:1px solid #52786b;border-radius:16px;background:#19342f}h1{line-height:1.2}small{color:#bcd0c6}summary{cursor:pointer}footer{padding:20px 0}</style></head><body><main>
<nav><a href="/hospital.html">I Love My Body</a><a href="/app/energy-healing-catalogue.php">All modalities</a><a href="/app/energy-healing-processes.php">Compare processes</a><a href="/app/energy-healing-record.php">My private session log</a></nav>
<p>Energy Healing Research Department</p><h1><?=ehr_h($practice['practice_name'])?></h1><p><?=ehr_h($practice['description_text'])?></p>
<nav aria-label="Published practices"><?php foreach($p as $x):?><a href="?practice=<?=urlencode($x['practice_code'])?>"><?=ehr_h($x['practice_name'])?></a><?php endforeach;?></nav>
<?php foreach($sections as $s):?><article id="<?=ehr_h($s['section_key'])?>"><h2><?=ehr_h($s['title'])?></h2><p><?=ehr_h($s['body_text'])?></p>
<?php if(preg_match('#^https://#',(string)$s['source_url'])):?><small>Source: <a rel="noopener noreferrer" href="<?=ehr_h($s['source_url'])?>"><?=ehr_h($s['source_title'])?></a></small><?php endif;?></article><?php endforeach;?>
<h2>Claims and evidence</h2><?php foreach($claims as $c):?><details><summary><?=ehr_h($c['claim_text'])?></summary><p><?=ehr_h($c['claim_kind'])?> · <?=ehr_h($c['evidence_status'])?></p><p><?=ehr_h($c['conclusion_text'])?></p></details><?php endforeach;?>
<footer>Research information. Personal records are available only after sign-in.</footer></main></body></html>
