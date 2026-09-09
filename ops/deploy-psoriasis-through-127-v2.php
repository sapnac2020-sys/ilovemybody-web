<?php
header('Content-Type: application/json');
$out=['ok'=>false,'stage'=>'init'];
try {
    $pdo=null;
    $dbPhp=__DIR__.'/../backend/db.php';
    if (is_file($dbPhp)) require $dbPhp;
    if (!($pdo instanceof PDO)) {
        $home=getenv('HOME') ?: '';
        $root=$home.'/domains/ilovemybody.in';
        $candidates=[];
        $it=new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root, FilesystemIterator::SKIP_DOTS));
        foreach ($it as $f) {
            if ($f->getFilename()==='ilmb-config.php') { $candidates[]=$f->getPathname(); break; }
        }
        if (!$candidates) throw new RuntimeException('No ilmb-config.php found');
        $c=require $candidates[0];
        foreach(['host','db','user','pass'] as $k) if (empty($c[$k])) throw new RuntimeException('Missing DB config key: '.$k);
        $port=(int)($c['port'] ?? 3306);
        $dsn='mysql:host='.$c['host'].';port='.$port.';dbname='.$c['db'].';charset=utf8mb4';
        $pdo=new PDO($dsn,$c['user'],$c['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    }

    $table='ilb_psoriasis_treatment_class';
    $exists=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
    $exists->execute([$table]);
    if((int)$exists->fetchColumn()===1){
        $canonical=[
          'class_id'=>'VARCHAR(32) NULL','class_name'=>'VARCHAR(255) NULL','route_or_type'=>'VARCHAR(160) NULL',
          'mechanism_summary'=>'TEXT NULL','typical_role'=>'TEXT NULL','major_safety_theme'=>'TEXT NULL',
          'governance_text'=>'TEXT NULL','source_url'=>'TEXT NULL'
        ];
        $cols=$pdo->query("SELECT column_name FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name='ilb_psoriasis_treatment_class'")->fetchAll(PDO::FETCH_COLUMN);
        foreach($canonical as $name=>$ddl) if(!in_array($name,$cols,true)) $pdo->exec("ALTER TABLE ilb_psoriasis_treatment_class ADD COLUMN `$name` $ddl");
    }

    $files=glob(__DIR__.'/../backend/phase_*psoriasis*.sql');
    if (!$files) throw new RuntimeException('No psoriasis phase SQL files found');
    $selected=[];
    foreach($files as $file){
        $base=basename($file);
        if(!preg_match('/^phase_(\d+)([a-z]?)(\d*)_/i',$base,$m)) continue;
        $phase=(int)$m[1];
        if($phase<106 || $phase>127) continue;
        $letter=strtolower($m[2] ?? '');
        $subnum=($m[3] ?? '')==='' ? 0 : (int)$m[3];
        $letterRank=$letter==='' ? 0 : (ord($letter)-ord('a')+1);
        $selected[]=['file'=>$file,'phase'=>$phase,'letterRank'=>$letterRank,'subnum'=>$subnum,'base'=>$base];
    }
    usort($selected,static fn($a,$b)=>[$a['phase'],$a['letterRank'],$a['subnum'],$a['base']] <=> [$b['phase'],$b['letterRank'],$b['subnum'],$b['base']]);
    if(!$selected) throw new RuntimeException('No psoriasis SQL selected for phases 106-127');

    $pdo->exec("CREATE TABLE IF NOT EXISTS ilb_psoriasis_deployment_ledger (
      deployment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
      phase_file VARCHAR(255) NOT NULL,
      deployed_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
      statement_count INT UNSIGNED NOT NULL,
      deployment_status VARCHAR(32) NOT NULL,
      UNIQUE KEY uq_psoriasis_phase_file(phase_file)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $applied=[]; $total=0;
    foreach($selected as $entry){
        $file=$entry['file'];
        $sql=file_get_contents($file);
        if($sql===false) throw new RuntimeException('Cannot read '.basename($file));

        if(basename($file)==='phase_107_psoriasis_genetic_modifiable_pathway.sql'){
            $replacements=[
              "'INDIRECT','PRELIMINARY','Do not claim a specific acupuncture point" => "'INDIRECT','PRELIMINARY','RESEARCH_ONLY','Do not claim a specific acupuncture point",
              "'INDIRECT','SUPPORTED','Nutrition is not a universal psoriasis cure" => "'INDIRECT','SUPPORTED','CONDITIONAL','Nutrition is not a universal psoriasis cure",
              "'INDIRECT','SUPPORTED','Sleep optimization may modify" => "'INDIRECT','SUPPORTED','CONDITIONAL','Sleep optimization may modify",
              "'INDIRECT','SUPPORTED','Exercise may improve" => "'INDIRECT','SUPPORTED','CONDITIONAL','Exercise may improve",
              "'DIRECT','ESTABLISHED','UV phototherapy is a conventional" => "'DIRECT','ESTABLISHED','ROUTINE','UV phototherapy is a conventional",
              "'DIRECT','ESTABLISHED','Barrier care supports" => "'DIRECT','ESTABLISHED','ROUTINE','Barrier care supports",
              "'UNSPECIFIED','HYPOTHESIS','RESEARCH_ONLY'" => "'UNSPECIFIED','INDIRECT','HYPOTHESIS','RESEARCH_ONLY'"
            ];
            $sql=str_replace(array_keys($replacements),array_values($replacements),$sql);
        }

        $parts=array_values(array_filter(array_map('trim',preg_split('/;\s*(?:\r?\n|$)/',$sql))));
        $n=0;
        foreach($parts as $stmt){
            $n++;
            try{$pdo->exec($stmt);}catch(Throwable $e){
                throw new RuntimeException(basename($file).' statement '.$n.' failed: '.$e->getMessage().' | SQL: '.substr(preg_replace('/\s+/',' ',$stmt),0,300));
            }
        }
        $total+=$n;
        $q=$pdo->prepare("INSERT INTO ilb_psoriasis_deployment_ledger(phase_file,statement_count,deployment_status) VALUES(?,?,'APPLIED') ON DUPLICATE KEY UPDATE deployed_at=CURRENT_TIMESTAMP(6),statement_count=VALUES(statement_count),deployment_status='APPLIED'");
        $q->execute([basename($file),$n]);
        $applied[]=['file'=>basename($file),'statements'=>$n];
    }

    $critical=['ilb_psoriasis_phenotype','ilb_psoriasis_treatment_class','ilb_psoriasis_keratinocyte_compartment','ilb_psoriasis_control_branch','ilb_psoriasis_candidate_stack'];
    $verified=[];
    foreach($critical as $t){
        $q=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
        $q->execute([$t]);
        if((int)$q->fetchColumn()!==1) throw new RuntimeException('Critical table missing: '.$t);
        $verified[$t]=true;
    }
    $stack=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_candidate_stack WHERE stack_name='ILMB_INTERSECTION_STACK_V1'")->fetchColumn();
    if($stack<4) throw new RuntimeException('Phase 127 candidate stack incomplete');
    $ledger=(int)$pdo->query("SELECT COUNT(*) FROM ilb_psoriasis_deployment_ledger WHERE deployment_status='APPLIED'")->fetchColumn();
    $out=['ok'=>true,'stage'=>'complete','database'=>$pdo->query('SELECT DATABASE()')->fetchColumn(),'phase_range'=>'106-127','files_applied'=>count($applied),'statements_applied'=>$total,'deployment_ledger_rows'=>$ledger,'critical_tables'=>$verified,'phase127_stack_rows'=>$stack,'applied'=>$applied];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
}catch(Throwable $e){
    $out=['ok'=>false,'stage'=>'fatal','exception'=>$e->getMessage(),'file'=>$e->getFile(),'line'=>$e->getLine()];
    echo json_encode($out,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
    exit(1);
}
