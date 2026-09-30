import os, pathlib, re, subprocess, time, urllib.request, urllib.parse, urllib.error
root=pathlib.Path(__file__).resolve().parents[1]
config="""<?php return ['db'=>['host'=>'127.0.0.1','port'=>3306,'name'=>'ehr_test','charset'=>'utf8mb4','user'=>'root','pass'=>'ci-only-password'],'app'=>['timezone'=>'Asia/Kolkata','base_path'=>'/app','cookie_name'=>'ilb_app']];"""
(root/'app/config.php').write_text(config)
auth=root/'app/ehr-test-auth.php'
auth.write_text("<?php require __DIR__.'/lib.php'; start_private_session(); $_SESSION['ilb_login_id']='test-login'; echo session_id();")
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,*args): return None
opener=urllib.request.build_opener(NoRedirect())
def req(path, data=None, cookie=None):
 headers={'Host':'ilovemybody.in'}
 if cookie: headers['Cookie']=cookie
 body=None if data is None else urllib.parse.urlencode(data).encode()
 try:
  with opener.open(urllib.request.Request('http://127.0.0.1:8099'+path,data=body,headers=headers)) as r:return r.status,r.read().decode(),r.headers
 except urllib.error.HTTPError as r:return r.code,r.read().decode(),r.headers
server=subprocess.Popen(['php','-S','127.0.0.1:8099','-t',str(root)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
try:
 for _ in range(30):
  try:
   status,body,_=req('/app/energy-healing.php');break
  except urllib.error.URLError:time.sleep(.1)
 assert status==200 and 'What has research found?' in body
 assert 'Magnified Healing' in body
 status,mh,_=req('/app/energy-healing.php?practice=MAGNIFIED_HEALING')
 assert status==200 and 'What is Magnified Healing?' in mh and 'DNA/RNA' in mh
 assert 'Reiki' not in body, 'Draft practice exposed'
 assert req('/app/energy-healing.php?practice=REIKI')[0]==404
 status,catalogue,_=req('/app/energy-healing-catalogue.php')
 assert status==200 and '50 records shown' in catalogue and 'Jikiden Reiki' in catalogue and 'Domancic' in catalogue
 assert 'Detailed research entry pending' in catalogue and 'NOT_REVIEWED' in catalogue
 status,filtered,_=req('/app/energy-healing-catalogue.php?q=Jikiden')
 assert status==200 and '1 records shown' in filtered and 'Magnified Healing' not in filtered
 assert req('/app/energy-healing-catalogue.php?q=NoSuchSyntheticModality')[1].find('No matching catalogue entries')>=0
 assert '&lt;script&gt;' in req('/app/energy-healing-catalogue.php?q=%3Cscript%3E')[1]
 assert req('/app/energy-healing-record.php')[0]==302
 status,processes,_=req('/app/energy-healing-processes.php')
 assert status==200 and 'Process comparison' in processes and 'Regulate appetite and cravings' in processes
 assert 'Magnified Healing' in processes and 'SOURCE_GAP' in processes and 'Synthetic hidden outcome' not in processes
 assert req('/app/energy-healing-processes.php?outcome=Synthetic%20hidden%20outcome')[0]==404
 assert req('/app/energy-healing-processes.php?outcome=unknown')[0]==404
 status,convergence,_=req('/app/energy-healing-convergence.php')
 assert status==200 and '9 candidate themes' in convergence and 'catalogue records with documented components' in convergence
 assert 'OPTIONAL' in convergence and 'TEACHING_SIMILARITY' in convergence
 assert 'CLINICALLY_VALIDATED' not in convergence and 'Synthetic hidden outcome' not in convergence
 assert 'not an absence finding' in convergence
 status,methods,_=req('/app/energy-healing-methods.php?practice=CORE_SHAMANISM&tab=self')
 assert status==200 and '50 catalogue records assessed' in methods and 'Described delivery: OTHER' in methods
 assert req('/app/energy-healing-methods.php?practice=unknown')[0]==404
 assert req('/app/energy-healing-methods.php?practice=REIKI&tab=unknown')[0]==404
 status,gaps,_=req('/app/energy-healing-methods.php?practice=JIKIDEN_REIKI&tab=gaps')
 assert status==200 and 'IDENTITY_ONLY' in gaps and 'NOT_REVIEWED' in gaps
 status,evidence,_=req('/app/energy-healing-methods.php?practice=REIKI&tab=evidence')
 assert 'NCT06526949' in evidence and 'NON_RANDOMIZED' in evidence and 'Expanded search records' in evidence
 assert status==200 and 'fibromyalgia' in evidence and 'ABSTRACT' in evidence and 'No benefit for pain' in evidence
 assert 'Additional primary-record extractions' in evidence and 'p=.053 remains nonsignificant' in evidence and 'FULL_REVIEW_PENDING' in evidence
 status,animal,_=req('/app/energy-healing-methods.php?practice=BENGSTON_METHOD&tab=evidence')
 assert status==200 and 'ANIMAL' in animal and 'no human cancer efficacy' in animal
 status,notice,_=req('/app/energy-healing-methods.php?practice=JIN_SHIN_JYUTSU&tab=evidence')
 assert status==200 and 'CHECKED' in notice and '36398997' in notice
 status,gap,_=req('/app/energy-healing-methods.php?practice=MAGNIFIED_HEALING&tab=evidence')
 assert status==200 and 'review gap, not proof' in gap and 'NO_INDEXED_RESULTS_RETURNED' in gap
 status,rh,_=req('/app/energy-healing-methods.php?practice=RECONNECTIVE_HEALING&tab=evidence')
 assert status==200 and 'Nonrandomized' in rh and 'FULL_TEXT' in rh
 status,access,_=req('/app/energy-healing-methods.php?practice=ACCESS_BARS&tab=evidence')
 assert status==200 and 'Pilot Study' in access and 'uncontrolled' in access
 status,psoriasis,_=req('/app/energy-healing-methods.php?practice=HEARTFULNESS&tab=evidence')
 assert status==200 and '0.548' in psoriasis and 'not statistically significant' in psoriasis
 status,jsj,_=req('/app/energy-healing-methods.php?practice=JIN_SHIN_JYUTSU&tab=evidence')
 assert status==200 and 'NO_ABSTRACT' in jsj and 'SOURCE_GAP_NO_ABSTRACT' in jsj
 status,mantra,_=req('/app/energy-healing-methods.php?practice=MANTRA_PRACTICES&tab=evidence')
 assert status==200 and 'p=.13 nonsignificant' in mantra and 'overlapping PMID34600308' in mantra
 status,core,_=req('/app/energy-healing-methods.php?practice=CORE_SHAMANISM&tab=evidence')
 assert status==200 and 'Foundation for Shamanic Studies' in core and 'Randomization was to practitioners' in core
 status,qi,_=req('/app/energy-healing-methods.php?practice=EXTERNAL_QIGONG&tab=evidence')
 assert status==200 and 'BODY_RETRIEVED' in qi and 'FULL_TEXT_EXTRACTED_BIAS_PENDING' in qi
 _,sid,_=req('/app/ehr-test-auth.php');cookie='ilb_app='+sid
 status,body,_=req('/app/energy-healing-record.php',cookie=cookie)
 assert status==200 and 'Synthetic other observation' not in body
 token=re.search(r'name="csrf" value="([^"]+)"',body).group(1)
 data={'csrf':token,'practice':'PRANIC_HEALING','started_at':'2026-01-02T12:00','duration':'60','mode':'PROXIMITY','result_id':'2','timing':'BASELINE'}
 assert req('/app/energy-healing-record.php',{**data,'csrf':'wrong'},cookie)[0]==403
 status,body,_=req('/app/energy-healing-record.php',data,cookie)
 assert status==200 and 'not available in your records' in body
 assert req('/app/energy-healing-record.php',{**data,'result_id':'1'},cookie)[0]==303
 status,body,_=req('/app/energy-healing-record.php',cookie=cookie)
 assert status==200 and '2026-01-02 12:00:00' in body
 assert req('/app/energy-healing-record.php',{**data,'practice':'MAGNIFIED_HEALING','result_id':'1'},cookie)[0]==303
 status,body,_=req('/app/energy-healing-record.php',cookie=cookie)
 assert status==200 and 'Magnified Healing' in body
 print('HTTP publication, authentication, CSRF, subject isolation and session-save checks passed')
finally:
 server.terminate();server.wait()
 auth.unlink(missing_ok=True);(root/'app/config.php').unlink(missing_ok=True)
