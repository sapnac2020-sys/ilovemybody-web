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
$studies=[];$searches=[];$databaseSearch=null;$researchGate=null;$screenCounts=[];$notices=[];$extractions=[];$access=[];$registries=[];$expandedCounts=[];
if($tab==='evidence'){
 try{
  $st=db()->prepare("SELECT s.title,s.source_url,c.population_text,c.outcome_text,c.evidence_status,e.study_design,e.sample_size,e.comparator_text,e.masking_text,e.funding_text,e.findings_text,e.effect_estimate,e.uncertainty_text,e.limitations_text,COALESCE(x.material_reviewed,'NOT_RECORDED') AS material_reviewed,COALESCE(x.procedure_text,'Procedure extraction not recorded for this earlier review.') AS procedure_text,COALESCE(x.notice_status,'PENDING') AS notice_status,COALESCE(x.population_scope,'NOT_RECORDED') AS population_scope,COALESCE(x.next_steps,'Verify review material, complete procedure and notice checks.') AS next_steps FROM ilb_ehr_claim c JOIN ilb_ehr_evidence_review e ON e.claim_id=c.claim_id JOIN ilb_ehr_source s ON s.source_id=e.source_id LEFT JOIN ilb_ehr_study_scope x ON x.claim_key=c.claim_key WHERE c.practice_code=? AND c.publication_status='PUBLISHED' AND s.publication_status='PUBLISHED' ORDER BY c.claim_key");
  $st->execute([$code]);$studies=$st->fetchAll();
  $st=db()->prepare('SELECT query_text,searched_on,retrieval_status,search_limitations FROM ilb_ehr_search_audit WHERE practice_code=? ORDER BY searched_on DESC');
  $st->execute([$code]);$searches=$st->fetchAll();
  $st=db()->prepare('SELECT * FROM ilb_ehr_database_search WHERE practice_code=?');$st->execute([$code]);$databaseSearch=$st->fetch();
  $st=db()->prepare('SELECT * FROM ilb_ehr_research_gate WHERE practice_code=?');$st->execute([$code]);$researchGate=$st->fetch();
  $st=db()->prepare('SELECT screening_status,COUNT(*) AS record_count FROM ilb_ehr_candidate_screen WHERE practice_code=? GROUP BY screening_status ORDER BY screening_status');$st->execute([$code]);$screenCounts=$st->fetchAll();
  $st=db()->prepare('SELECT x.*,c.title,c.source_url,c.screening_status FROM ilb_ehr_candidate_extraction x JOIN ilb_ehr_candidate_screen c ON c.practice_code=x.practice_code AND c.pmid=x.pmid WHERE x.practice_code=? ORDER BY x.pmid');$st->execute([$code]);$extractions=$st->fetchAll();
  $st=db()->prepare('SELECT a.* FROM ilb_ehr_source_access a JOIN ilb_ehr_candidate_screen c ON c.pmid=a.pmid WHERE c.practice_code=? ORDER BY a.pmid');$st->execute([$code]);$access=$st->fetchAll();
  $st=db()->prepare('SELECT * FROM ilb_ehr_registry_review WHERE practice_code=? ORDER BY registry_id');$st->execute([$code]);$registries=$st->fetchAll();
  $st=db()->prepare('SELECT t.review_status,t.triage_hint,COUNT(*) AS record_count FROM ilb_ehr_expanded_triage t JOIN ilb_ehr_expanded_mapping m ON m.pmid=t.pmid WHERE m.practice_code=? GROUP BY t.review_status,t.triage_hint ORDER BY t.review_status,t.triage_hint');$st->execute([$code]);$expandedCounts=$st->fetchAll();
  $st=db()->prepare("SELECT n.* FROM ilb_ehr_notice_review n JOIN ilb_ehr_claim c ON c.claim_key=CONCAT('ABSTRACT_',n.original_pmid) WHERE c.practice_code=?");$st->execute([$code]);$notices=$st->fetchAll();
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
<?php if($researchGate):?><details><summary>Research completion · <?=$researchGate['research_complete']?'Complete within recorded scope':'Open'?></summary><p><?=method_h($researchGate['summary_text'])?></p><p><?=method_h($researchGate['next_actions'])?></p></details><?php endif;?>
<?php if($databaseSearch):?><details><summary>Primary PubMed query · <?=method_h($databaseSearch['retrieval_status'])?> · <?=method_h($databaseSearch['result_count'])?> returned records</summary><p>Publication cutoff: <?=method_h($databaseSearch['cutoff_on'])?>. Search date: <?=method_h($databaseSearch['searched_on'])?>.</p><p><?=method_h($databaseSearch['query_text'])?></p><p>Translated query: <?=method_h($databaseSearch['query_translation'])?></p><p><?=method_h($databaseSearch['warnings_text'])?></p><p>Raw hits can include unrelated meanings. Zero hits do not establish absence of research; publisher reports and aliases require separate checks.</p></details><?php endif;?>
<?php if($screenCounts):?><details><summary>Primary-record screening register</summary><p>These are practice–paper mappings. Title eligibility is not a completed evidence review; overlapping reports are not independent replications.</p><ul><?php foreach($screenCounts as $screen):?><li><?=method_h($screen['screening_status'])?>: <?=method_h($screen['record_count'])?></li><?php endforeach;?></ul></details><?php endif;?>
<?php foreach($notices as $notice):?><details><summary>Correction reviewed · PMID <?=method_h($notice['notice_pmid'])?></summary><p><?=method_h($notice['correction_scope'])?></p><p><?=method_h($notice['remaining_issue'])?></p><a href="<?=method_h($notice['notice_url'])?>" rel="noopener noreferrer">Correction record</a></details><?php endforeach;?>
<?php if($expandedCounts):?><details><summary>Expanded search records · review queue</summary><p>Automated metadata hints prioritize review; they do not decide eligibility or establish efficacy. PRIMARY_RECORD_REVIEWED means the available source was screened, with its individual status below. Shared papers are counted once per practice here.</p><ul><?php foreach($expandedCounts as $count):?><li><?=method_h($count['review_status'])?> · <?=method_h($count['triage_hint'])?>: <?=method_h($count['record_count'])?></li><?php endforeach;?></ul></details><?php endif;?>
<?php foreach($registries as $registry):?><details><summary>Trial registry · <?=method_h($registry['registry_id'])?> · <?=method_h($registry['correspondence_status'])?></summary><p><?=method_h($registry['findings_text'])?></p><p>Current record checked <?=method_h($registry['reviewed_on'])?>. Historical versions and complete prespecification checks remain separate.</p><a href="<?=method_h($registry['source_url'])?>" rel="noopener noreferrer">Primary registry record</a></details><?php endforeach;?>
<?php if($access):?><details><summary>Full-text access checks</summary><p>A retrieved body is not proof of review. NO_BODY_RETURNED records a gap in the attempted PMC route, rather than global unavailability.</p><ul><?php foreach($access as $sourceAccess):?><li><a href="<?=method_h($sourceAccess['source_url'])?>" rel="noopener noreferrer"><?=method_h($sourceAccess['pmc_id'])?></a> · <?=method_h($sourceAccess['access_status'])?> · <?=method_h($sourceAccess['review_status'])?></li><?php endforeach;?></ul></details><?php endif;?>
<?php if($extractions):?><h3>Additional primary-record extractions</h3><p>Single-reviewer source summaries. FULL_TEXT marks targeted Methods, Results and Discussion reading; it does not mark a completed bias appraisal. NO_ABSTRACT marks a source gap. Eligibility, independent bias assessment and clinical validation remain open. One paper can appear under more than one practice.</p><?php endif;?>
<?php foreach($extractions as $extraction):?><details><summary><?=method_h($extraction['title'])?> · <?=method_h($extraction['material_reviewed'])?></summary><p><?=method_h($extraction['screening_status'])?> · Reviewed <?=method_h($extraction['reviewed_on'])?></p><p><?=method_h($extraction['interpretation_text'])?></p><p>Remaining work: <?=method_h($extraction['remaining_work'])?></p><a href="<?=method_h($extraction['source_url'])?>" rel="noopener noreferrer">Primary record · PMID <?=method_h($extraction['pmid'])?></a></details><?php endforeach;?>
<?php if(!$studies):?><p>No primary-study appraisal has been completed in this register for this record. This is a review gap, not proof that evidence is absent.</p><?php endif;?>
<?php foreach($studies as $study):?><details><summary><?=method_h($study['title'])?> · <?=method_h($study['evidence_status'])?></summary>
<p><?=method_h($study['material_reviewed'])?> · <?=method_h($study['population_scope'])?> · <?=method_h($study['study_design'])?></p>
<p>Sample count: <?=$study['sample_size']===null?'Not extracted':method_h($study['sample_size'])?>. Comparator: <?=method_h($study['comparator_text'])?>.</p>
<p>Population: <?=method_h($study['population_text'])?>. Outcomes: <?=method_h($study['outcome_text'])?>.</p>
<p>Masking: <?=method_h($study['masking_text'])?>. Funding and disclosures: <?=method_h($study['funding_text'])?>.</p>
<p><?=method_h($study['findings_text'])?></p><p><?=method_h($study['effect_estimate'])?></p>
<p>Uncertainty: <?=method_h($study['uncertainty_text'])?></p>
<p>Described study procedure: <?=method_h($study['procedure_text'])?></p>
<p>Limitations: <?=method_h($study['limitations_text'])?></p>
<p>Notice check: <?=method_h($study['notice_status'])?>. <?=method_h($study['next_steps'])?></p>
<a href="<?=method_h($study['source_url'])?>" rel="noopener noreferrer">Primary study record</a></details><?php endforeach;?>
<?php foreach($searches as $search):?><details><summary>Discovery search · <?=method_h($search['searched_on'])?> · <?=method_h($search['retrieval_status'])?></summary><p><?=method_h($search['query_text'])?></p><p><?=method_h($search['search_limitations'])?></p></details><?php endforeach;?>
<?php else:?><p><?=method_h($selected['sequence_gap'])?></p><p>Clinical review of this teaching extraction: <?=method_h($selected['clinical_review_status'])?>. Focused study appraisals, where available, appear under Evidence; full review remains separate. Compare the same measured outcome with baseline, follow-up, comparator and other influences. Only verified exact clinical observations receive LOINC mappings.</p><?php endif;?>
</article>
<nav><?php if($index>0):?><a href="<?=method_h(method_url($rows[$index-1]['practice_code'],$tab))?>">Previous method</a><?php endif;?><?php if($index+1<count($rows)):?><a href="<?=method_h(method_url($rows[$index+1]['practice_code'],$tab))?>">Next method</a><?php endif;?></nav>
</main></body></html>
