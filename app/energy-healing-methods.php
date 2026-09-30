<?php
declare(strict_types=1);
require __DIR__.'/_guard.php';
require __DIR__.'/lib.php';
header('Content-Type: text/html; charset=utf-8');
header('Cache-Control: no-store');
function method_h(mixed $v):string{return htmlspecialchars((string)$v,ENT_QUOTES|ENT_SUBSTITUTE,'UTF-8');}
try {
 $rows=db()->query("SELECT r.*,p.practice_name,c.record_kind FROM ilb_ehr_process_review r JOIN ilb_ehr_practice p ON p.practice_code=r.practice_code JOIN ilb_ehr_catalogue c ON c.practice_code=r.practice_code JOIN ilb_ehr_department d ON d.department_code=p.department_code WHERE c.publication_status='PUBLISHED' AND d.publication_status='PUBLISHED' ORDER BY p.practice_name")->fetchAll();
} catch(Throwable $e){http_response_code(503);exit('Process reviews are being prepared. Please try again later.');}
$code=(string)($_GET['practice']??($rows[0]['practice_code']??''));
$selected=null;$index=0;foreach($rows as $i=>$row){if($row['practice_code']===$code){$selected=$row;$index=$i;break;}}
if(!$selected){http_response_code(404);exit('Process review not found.');}
$tab=(string)($_GET['tab']??'process');
if(!in_array($tab,['process','self','source','evidence','gaps'],true)){http_response_code(404);exit('Review tab not found.');}
$studies=[];$searches=[];
if($tab==='evidence'){
 try{
  $st=db()->prepare("SELECT s.title,s.source_url,c.evidence_status,e.study_design,e.sample_size,e.comparator_text,e.masking_text,e.findings_text,e.effect_estimate,e.limitations_text,x.material_reviewed,x.procedure_text,x.notice_status,x.population_scope,x.next_steps FROM ilb_ehr_claim c JOIN ilb_ehr_evidence_review e ON e.claim_id=c.claim_id JOIN ilb_ehr_source s ON s.source_id=e.source_id JOIN ilb_ehr_study_scope x ON x.claim_key=c.claim_key WHERE c.practice_code=? AND c.publication_status='PUBLISHED' AND s.publication_status='PUBLISHED' ORDER BY c.claim_key");
  $st->execute([$code]);$studies=$st->fetchAll();
  $st=db()->prepare('SELECT query_text,searched_on,retrieval_status,search_limitations FROM ilb_ehr_search_audit WHERE practice_code=? ORDER BY searched_on DESC');
  $st->execute([$code]);$searches=$st->fetchAll();
 }catch(Throwable $e){http_response_code(503);exit('Evidence reviews are being prepared. Please try again later.');}
}
function method_url(string $code,string $tab='process'):string{return '/app/energy-healing-methods.php?practice='.urlencode($code).'&tab='.urlencode($tab);}
?>
<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Process reviews | Energy Healing Research</title><style>body{margin:0;background:#102321;color:#edf5ef;font:16px/1.5 system-ui}main{max-width:900px;margin:auto;padding:20px}a{color:#b8e6c4}nav,.tabs{display:flex;gap:12px;flex-wrap:wrap}.tabs a,article{padding:14px;border:1px solid #52786b;border-radius:12px;background:#19342f}h1,h2{line-height:1.2}p{overflow-wrap:anywhere}.tabs [aria-current]{background:#31594b}article{margin:16px 0}</style></head><body><main>
<nav><a href="/app/energy-healing-catalogue.php">Catalogue</a><a href="/app/energy-healing-convergence.php">Convergence</a><a href="/app/energy-healing-processes.php">Outcome processes</a></nav>
<h1>Process reviews</h1><p><?=count($rows)?> catalogue records assessed · Public teaching descriptions. Clinical evidence review remains separate.</p>
<h2><?=method_h($selected['practice_name'])?></h2><p><?=method_h($selected['record_kind'])?> · <?=method_h($selected['source_status'])?> · <?=($index+1)?> of <?=count($rows)?></p>
<div class="tabs"><?php foreach(['process'=>'Process','self'=>'Self-practice','source'=>'Source','evidence'=>'Evidence','gaps'=>'Research gaps'] as $key=>$label):?><a href="<?=method_h(method_url($code,$key))?>" <?=$tab===$key?'aria-current="page"':''?>><?=$label?></a><?php endforeach;?></div>
<article>
<?php if($tab==='process'):?><p><?=method_h($selected['process_outline'])?></p><p>Tradition-specific energy and healing explanations are claims to investigate. This outline does not establish their biological mechanism or clinical effectiveness.</p>
<?php elseif($tab==='self'):?><p>Described delivery: <?=method_h($selected['delivery_scope'])?>.</p><p>SELF means the source describes self-use; it does not establish safety, effectiveness or a complete outcome-specific procedure. OTHER identifies recipient work. UNSPECIFIED means self-use has not been established from this source.</p>
<?php elseif($tab==='source'):?><p><a href="<?=method_h($selected['source_url'])?>" rel="noopener noreferrer">Read teaching source</a></p><p><?=method_h($selected['source_locator'])?> · Checked <?=method_h($selected['source_checked_on'])?>.</p><p>Family entries use named examples. Related branches and shared lineage are not independent confirmation.</p>
<?php elseif($tab==='evidence'):?>
<p>Focused literature appraisals. These records do not constitute a complete systematic review or a validated treatment procedure.</p>
<?php if(!$studies):?><p>No primary-study appraisal has been completed in this register for this record. This is a review gap, not proof that evidence is absent.</p><?php endif;?>
<?php foreach($studies as $study):?><details><summary><?=method_h($study['title'])?> · <?=method_h($study['evidence_status'])?></summary>
<p><?=method_h($study['material_reviewed'])?> · <?=method_h($study['population_scope'])?> · <?=method_h($study['study_design'])?></p>
<p>Sample count: <?=$study['sample_size']===null?'Not extracted':method_h($study['sample_size'])?>. Comparator: <?=method_h($study['comparator_text'])?>.</p>
<p><?=method_h($study['findings_text'])?></p><p><?=method_h($study['effect_estimate'])?></p>
<p>Described study procedure: <?=method_h($study['procedure_text'])?></p>
<p>Limitations: <?=method_h($study['limitations_text'])?></p>
<p>Notice check: <?=method_h($study['notice_status'])?>. <?=method_h($study['next_steps'])?></p>
<a href="<?=method_h($study['source_url'])?>" rel="noopener noreferrer">Primary study record</a></details><?php endforeach;?>
<?php foreach($searches as $search):?><details><summary>Discovery search · <?=method_h($search['searched_on'])?> · <?=method_h($search['retrieval_status'])?></summary><p><?=method_h($search['query_text'])?></p><p><?=method_h($search['search_limitations'])?></p></details><?php endforeach;?>
<?php else:?><p><?=method_h($selected['sequence_gap'])?></p><p>Clinical review of this teaching extraction: <?=method_h($selected['clinical_review_status'])?>. Focused study appraisals, where available, appear under Evidence; full review remains separate. Compare the same measured outcome with baseline, follow-up, comparator and other influences. Only verified exact clinical observations receive LOINC mappings.</p><?php endif;?>
</article>
<nav><?php if($index>0):?><a href="<?=method_h(method_url($rows[$index-1]['practice_code'],$tab))?>">Previous method</a><?php endif;?><?php if($index+1<count($rows)):?><a href="<?=method_h(method_url($rows[$index+1]['practice_code'],$tab))?>">Next method</a><?php endif;?></nav>
</main></body></html>
