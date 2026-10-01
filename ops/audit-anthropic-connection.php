<?php
declare(strict_types=1);
// Credential-presence audit: never emit values, credentials, or personal rows.
$out=['checked_at'=>gmdate('c'),'app'=>['checked'=>false,'anthropic_present'=>false],'shared'=>['checked'=>false,'matches'=>[],'provider_records'=>[]]];
$home=getenv('HOME')?:dirname(__DIR__,2);
$roots=[$home.'/domains/100days.magic24x7.com/private_data',$home.'/domains/100days.magic24x7.com/public_html/private_data',$home.'/domains/100days.magic24x7.com/private'];
foreach($roots as $root){$f=$root.'/journey.sqlite';if(!is_file($f))continue;try{$db=new PDO('sqlite:'.$f,null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);$q=$db->prepare("SELECT COUNT(*) FROM settings WHERE k IN ('anthropic_key','ANTHROPIC_API_KEY','anthropic_api_key') AND v LIKE 'sk-ant-%'");$q->execute();$out['app']=['checked'=>true,'anthropic_present'=>(int)$q->fetchColumn()>0];break;}catch(Throwable $e){$out['app']['error']='Could not inspect app settings';}}
$configPath=$argv[1]??'';
$sharedFactory=$home.'/domains/ilovemybody.in/private/config/db.php';
if(is_file($sharedFactory))$configPath=$sharedFactory;
$phase='config';
try{
 if(!$configPath||!is_file($configPath))throw new RuntimeException('no_config');
 ob_start();try{$config=require $configPath;}finally{ob_end_clean();}
 $phase='connect';
 if(function_exists('ilb_db')){$db=ilb_db();}else{$cfg=is_array($config)&&isset($config['db'])?$config['db']:$config;if(!is_array($cfg))throw new RuntimeException('invalid_config');$dsn=sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$cfg['host']??'127.0.0.1',(int)($cfg['port']??3306),$cfg['name']??$cfg['db']??'',$cfg['charset']??'utf8mb4');$db=new PDO($dsn,$cfg['user']??'',$cfg['pass']??'',[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);}
 $phase='metadata';
 $schema=(string)$db->query('SELECT DATABASE()')->fetchColumn();
 $q=$db->prepare('SELECT TABLE_NAME,COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=?');$q->execute([$schema]);$tables=[];
 foreach($q->fetchAll(PDO::FETCH_ASSOC) as $r){$t=$r['TABLE_NAME'];if(!preg_match('/setting|config|credential|vault|provider|api_key/i',$t))continue;$tables[$t][]=$r['COLUMN_NAME'];}
 $quote=static function(string $s):string{return '`'.str_replace('`','``',$s).'`';};
 foreach($tables as $table=>$columns){foreach($columns as $col){if(!preg_match('/secret|api.?key|token|credential|encrypted|^value$|^v$|setting_value|config_value/i',$col))continue;try{$sql='SELECT COUNT(*) FROM '.$quote($table).' WHERE CAST('.$quote($col)." AS CHAR) LIKE 'sk-ant-%'";$n=(int)$db->query($sql)->fetchColumn();if($n>0)$out['shared']['matches'][]=['table'=>$table,'column'=>$col,'plaintext_anthropic_count'=>$n];}catch(Throwable $e){/* Never include server exception details. */}}}
 foreach($tables as $table=>$columns){foreach($columns as $col){if(!preg_match('/^k$|^key$|^name$|provider|service|setting_key|config_key/i',$col))continue;try{$sql='SELECT COUNT(*) FROM '.$quote($table).' WHERE LOWER(CAST('.$quote($col)." AS CHAR)) LIKE '%anthropic%'";$n=(int)$db->query($sql)->fetchColumn();if($n>0)$out['shared']['provider_records'][]=['table'=>$table,'identifier_column'=>$col,'record_count'=>$n,'credential_columns'=>array_values(array_filter($columns,static fn($c)=>preg_match('/secret|api.?key|credential|encrypted|^value$|^v$|setting_value|config_value/i',$c)))];}catch(Throwable $e){}}}
 $out['shared']['checked']=true;$out['shared']['candidate_tables_checked']=count($tables);
}catch(Throwable $e){$out['shared']['error']='Shared database could not be inspected';$out['shared']['failure_phase']=$phase;$out['shared']['error_type']=get_class($e);if($e instanceof PDOException)$out['shared']['sql_error_code']=(int)($e->errorInfo[1]??0);}
echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
