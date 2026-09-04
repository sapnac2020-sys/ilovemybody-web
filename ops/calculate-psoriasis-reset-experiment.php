<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') exit(2);
$path=$argv[1]??''; if(!is_file($path))throw new RuntimeException('Input JSON missing');
$d=json_decode(file_get_contents($path),true,512,JSON_THROW_ON_ERROR);
foreach(['arm','stage','measurements'] as $k)if(!array_key_exists($k,$d))throw new RuntimeException("Missing $k");
$out=[];
foreach($d['measurements'] as $state=>$v){
 foreach(['X','H','P'] as $k)if(!isset($v[$k])||!is_numeric($v[$k]))throw new RuntimeException("$state.$k missing");
 $den=(float)$v['P']-(float)$v['H']; if($den==0.0)throw new RuntimeException("$state control denominator is zero");
 $out[$state]=['X'=>(float)$v['X'],'H'=>(float)$v['H'],'P'=>(float)$v['P'],'N'=>((float)$v['X']-(float)$v['H'])/$den];
}
echo json_encode(['experiment'=>'EXP_PSO_RESET_001','arm'=>$d['arm'],'stage'=>$d['stage'],'normalised_states'=>$out,'interpretation'=>['N=0'=>'matched healthy control','N=1'=>'matched psoriatic control'],'cure_decision_emitted'=>false],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES),PHP_EOL;
