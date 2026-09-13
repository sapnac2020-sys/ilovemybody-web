<?php
declare(strict_types=1);
try {
 if($argc<2) throw new RuntimeException('config required');
 $c=require $argv[1]; if(isset($c['database']))$c=$c['database'];
 $db=$c['db']??$c['name']??null;
 $pdo=new PDO("mysql:host={$c['host']};dbname={$db};charset=utf8mb4",$c['user'],$c['pass']??$c['password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
 $needle='ilb_gita_formula_test';
 $s=$pdo->prepare("SELECT table_name, view_definition FROM information_schema.views WHERE table_schema=DATABASE() AND LOWER(view_definition) LIKE ? ORDER BY table_name");
 $s->execute(['%'.$needle.'%']);
 $views=$s->fetchAll(PDO::FETCH_ASSOC);
 $out=[];
 foreach($views as $v){
   $name=$v['table_name'];
   $s2=$pdo->prepare("SELECT table_name FROM information_schema.views WHERE table_schema=DATABASE() AND table_name<>? AND LOWER(view_definition) LIKE ? ORDER BY table_name");
   $s2->execute([$name,'%'.strtolower($name).'%']);
   $out[]=['view'=>$name,'downstream_views'=>$s2->fetchAll(PDO::FETCH_COLUMN),'definition'=>$v['view_definition']];
 }
 echo json_encode(['table'=>$needle,'views'=>$out],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
} catch(Throwable $e){fwrite(STDERR,$e->getMessage().PHP_EOL);exit(1);}