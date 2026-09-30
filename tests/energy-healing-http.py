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
 assert 'Magnified Healing' not in body, 'Draft practice exposed'
 assert req('/app/energy-healing.php?practice=MAGNIFIED_HEALING')[0]==404
 assert req('/app/energy-healing-record.php')[0]==302
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
 print('HTTP publication, authentication, CSRF, subject isolation and session-save checks passed')
finally:
 server.terminate();server.wait()
 auth.unlink(missing_ok=True);(root/'app/config.php').unlink(missing_ok=True)
