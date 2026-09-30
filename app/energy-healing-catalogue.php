<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__.'/lib.php';
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
function cat_h(mixed $v):string{return htmlspecialchars((string)$v,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
$search=trim((string)($_GET['q']??''));
try{
 $st=db()->prepare("SELECT c.*,p.practice_name,p.review_status,p.publication_status AS entry_status,parent.practice_name AS parent_name FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code LEFT JOIN ilb_ehr_practice parent ON parent.practice_code=c.parent_practice_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED'".($search!==''?" AND (p.practice_name LIKE ? OR c.aliases_text LIKE ? OR c.category_name LIKE ?)":"")." ORDER BY c.category_name,p.practice_name");
 $term='%'.$search.'%';$st->execute($search!==''?[$term,$term,$term]:[]);$rows=$st->fetchAll();
 $counts=db()->query("SELECT c.record_kind,COUNT(*) AS total FROM ilb_ehr_catalogue c JOIN ilb_ehr_practice p ON p.practice_code=c.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' GROUP BY c.record_kind")->fetchAll();
}catch(Throwable $e){http_response_code(503);exit('The modality catalogue is being prepared. Please try again later.');}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Modality catalogue | Energy Healing Research</title><style>body{margin:0;background:#102321;color:#edf5ef;font:17px/1.6 system-ui}main{max-width:1000px;margin:auto;padding:24px}a{color:#b8e6c4}nav{display:flex;gap:18px;flex-wrap:wrap}article{padding:20px;margin:18px 0;border:1px solid #52786b;border-radius:16px;background:#19342f}h1,h2,h3{line-height:1.25}small{color:#bcd0c6}input,button{font:inherit;padding:10px;border-radius:8px;border:1px solid #52786b;background:#19342f;color:#edf5ef;max-width:100%;box-sizing:border-box}form{display:flex;gap:12px;flex-wrap:wrap}input{flex:1;min-width:0}p{overflow-wrap:anywhere}</style></head><body><main>
<nav><a href="/hospital.html">I Love My Body</a><a href="/app/energy-healing.php">Research entries</a><a href="/app/energy-healing-processes.php">Compare processes</a><a href="/app/energy-healing-convergence.php">Convergence comparison</a></nav>
<h1>Energy healing modality catalogue</h1>
<p>Explore named methods, branches and broader practice families. Related spiritual, sound and bodywork approaches are labelled separately. Catalogue inclusion records an identity and source; clinical findings and self-practice procedures require their own review.</p>
<p><?php foreach($counts as $c):?><span><?=cat_h($c['total'])?> <?=cat_h(strtolower(str_replace('_',' ',$c['record_kind'])))?> records. </span><?php endforeach;?></p>
<p>Coverage is open: new regional traditions, lineages and names can be added with sources. Search names aid discovery and do not imply that different lineages are identical. Acupuncture and general acupressure are outside this catalogue's scope.</p>
<form method="get"><label for="q">Find a method</label><input id="q" name="q" value="<?=cat_h($search)?>" placeholder="Name, search name or category"><button>Search</button><a href="energy-healing-catalogue.php">Show all</a></form>
<p><?=count($rows)?> records shown.</p>
<?php $category=null;foreach($rows as $r):if($category!==$r['category_name']):$category=$r['category_name'];?><h2><?=cat_h($category)?></h2><?php endif;?>
<article id="<?=cat_h($r['practice_code'])?>"><h3><?=cat_h($r['practice_name'])?></h3>
<p><?=cat_h($r['overview_text'])?></p>
<p><?=cat_h(strtolower(str_replace('_',' ',$r['record_kind'])))?> · <?=$r['scope_status']==='CORE'?'Energy-healing scope':'Related practice'?> · Research review: <?=cat_h($r['review_status'])?></p>
<?php if($r['parent_name']):?><p>Related parent: <?=cat_h($r['parent_name'])?></p><?php endif;?>
<small>Search names: <?=cat_h($r['aliases_text'])?></small>
<p><?php if(preg_match('#^https://#',$r['source_url'])):?><a href="<?=cat_h($r['source_url'])?>" rel="noopener noreferrer"><?=cat_h($r['source_name'])?></a><?php endif;?> · Source checked <?=cat_h($r['source_checked_on'])?></p>
<?php if($r['entry_status']==='PUBLISHED'):?><a href="/app/energy-healing.php?practice=<?=urlencode($r['practice_code'])?>">Read research entry</a><?php else:?><p>Detailed research entry pending.</p><?php endif;?>
</article><?php endforeach;?>
<?php if(!$rows):?><p>No matching catalogue entries.</p><?php endif;?>
</main></body></html>
