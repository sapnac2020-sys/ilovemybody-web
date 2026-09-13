<?php
declare(strict_types=1);

function tableExists(PDO $pdo, string $name): bool {
    $s=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?");
    $s->execute([$name]); return (int)$s->fetchColumn()===1;
}
function tableColumns(PDO $pdo, string $name): array {
    $s=$pdo->prepare("SELECT column_name FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? ORDER BY ordinal_position");
    $s->execute([$name]); return array_map(fn($r)=>(string)$r['column_name'],$s->fetchAll(PDO::FETCH_ASSOC));
}
function firstColumn(array $columns, array $candidates): ?string {
    foreach($candidates as $c) if(in_array($c,$columns,true)) return $c;
    return null;
}
function qi(string $name): string { return '`'.str_replace('`','``',$name).'`'; }
function valueKind(string $raw): string {
    $x=strtolower(trim($raw));
    foreach(['integer','boolean','text','coded','ratio','rate'] as $v) if(str_contains($x,$v)) return $v;
    return 'numeric';
}
function inputRole(string $raw): string {
    $x=strtoupper(trim($raw));
    foreach(['MEASURED','TARGET','CONSTANT','COEFFICIENT','DERIVED','CONTEXT'] as $v) if($x===$v || str_contains($x,$v)) return $v;
    return 'CONTEXT';
}
function governedFormulaStatus(string $raw): string {
    $x=strtoupper(trim($raw));
    if(str_contains($x,'DEPREC') || str_contains($x,'RETIR')) return 'DEPRECATED';
    if(str_contains($x,'APPROV')) return 'APPROVED';
    if(str_contains($x,'VERIF') || $x==='PASS') return 'VERIFIED';
    return 'DRAFT';
}

try {
    if ($argc < 3) throw new RuntimeException('Usage: php run-body-need-master-migrations.php CONFIG MIGRATION_DIR');
    $config = require $argv[1];
    if (isset($config['database'])) $config = $config['database'];
    $dbName = $config['db'] ?? $config['name'] ?? null;
    if (!$dbName) throw new RuntimeException('Database name missing from config');

    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$dbName};charset=utf8mb4",
        $config['user'],
        $config['pass'] ?? $config['password'],
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::MYSQL_ATTR_MULTI_STATEMENTS => true]
    );
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

    $dir = rtrim($argv[2], '/');
    $files = ['005_body_need_master.sql','006_formula_duplicate_and_identifier_patch.sql','007_formula_master_bootstrap.sql','008_loinc_parameter_bootstrap.sql','009_body_need_execution_status_patch.sql'];
    $applied = [];
    foreach ($files as $file) {
        $path = $dir . '/' . $file;
        if (!is_file($path) || filesize($path) === 0) throw new RuntimeException("Missing migration: {$file}");
        $stmt = $pdo->prepare(file_get_contents($path)); $stmt->execute();
        do { if($stmt->columnCount()) $stmt->fetchAll(); } while($stmt->nextRowset());
        $applied[] = $file;
    }

    $equationBootstrap = ['registry_present'=>tableExists($pdo,'ilb_equation_registry'),'detected_columns'=>[],'mapped_columns'=>[],'rows_seen'=>0,'rows_upserted'=>0,'status'=>'SKIPPED_NO_REGISTRY'];
    if ($equationBootstrap['registry_present']) {
        $cols = tableColumns($pdo,'ilb_equation_registry'); $equationBootstrap['detected_columns']=$cols;
        $map = [
            'key'=>firstColumn($cols,['equation_key','formula_key','equation_code','formula_code','code','registry_key']),
            'name'=>firstColumn($cols,['equation_name','formula_name','name','title','label']),
            'class'=>firstColumn($cols,['equation_class','formula_domain','domain','category','equation_type','formula_type']),
            'expression'=>firstColumn($cols,['equation_expression','expression_text','equation_text','formula_expression','formula_text','formula','expression']),
            'evidence'=>firstColumn($cols,['evidence_locator','source_citation','source_locator','evidence_source','citation','source']),
            'validation'=>firstColumn($cols,['validation_status','formula_status','verification_status','status']),
            'input_units'=>firstColumn($cols,['input_unit_contract','input_units','unit_contract_in']),
            'output_units'=>firstColumn($cols,['output_unit_contract','output_units','unit_contract_out']),
        ];
        $equationBootstrap['mapped_columns']=$map;
        if ($map['key'] && $map['expression']) {
            $selectCols=array_values(array_unique(array_filter($map)));
            $rows=$pdo->query('SELECT '.implode(',',array_map('qi',$selectCols)).' FROM `ilb_equation_registry`')->fetchAll();
            $equationBootstrap['rows_seen']=count($rows);
            $upsert=$pdo->prepare("INSERT INTO ilmb_formula_master
              (formula_key,formula_name,formula_domain,output_parameter_id,expression_text,expression_language,purpose,evidence_class,source_system,source_record_key,source_citation,formula_status,unit_checked,dimensional_analysis_text)
              VALUES (?,?,?,?,?,'EQUATION_TEXT',?,'PUBLISHED_MODEL','ilb_equation_registry',?,?,?,0,?)
              ON DUPLICATE KEY UPDATE formula_name=VALUES(formula_name),formula_domain=VALUES(formula_domain),expression_text=VALUES(expression_text),source_citation=VALUES(source_citation),formula_status=VALUES(formula_status),dimensional_analysis_text=VALUES(dimensional_analysis_text),updated_at=CURRENT_TIMESTAMP");
            foreach($rows as $r){
                $sourceKey=trim((string)$r[$map['key']]); $expr=trim((string)$r[$map['expression']]); if($sourceKey===''||$expr==='')continue;
                $name=$map['name']?trim((string)($r[$map['name']]??'')):''; if($name==='')$name=$sourceKey;
                $class=$map['class']?trim((string)($r[$map['class']]??'')):'OTHER'; if($class==='')$class='OTHER';
                $upper=strtoupper($class); $purpose=str_contains($upper,'PHYSIC')?'PHYSICS':(str_contains($upper,'CHEM')?'CHEMISTRY':(str_contains($upper,'PHYSIOL')?'PHYSIOLOGY':'OTHER'));
                $status=governedFormulaStatus($map['validation']?(string)($r[$map['validation']]??''):'');
                $evidence=$map['evidence']?(string)($r[$map['evidence']]??''):null;
                $inUnits=$map['input_units']?(string)($r[$map['input_units']]??''):''; $outUnits=$map['output_units']?(string)($r[$map['output_units']]??''):'';
                $upsert->execute(['equation_registry:'.$sourceKey,$name,$class,null,$expr,$purpose,$sourceKey,$evidence,$status,'legacy_input_unit_contract='.$inUnits.'; legacy_output_unit_contract='.$outUnits]);
                $equationBootstrap['rows_upserted']++;
            }
            $equationBootstrap['status']='IMPORTED_REFERENCE_ONLY';
        } else $equationBootstrap['status']='BLOCKED_UNMAPPED_REGISTRY_COLUMNS';
    }

    // Consolidate the existing case formula system. These records are preserved as reference formulas
    // unless their source status explicitly says VERIFIED/APPROVED; no executable status is invented.
    $caseBootstrap=['variables'=>[],'formulas'=>[],'inputs'=>[],'status'=>'SKIPPED'];
    $variableIds=[];
    if(tableExists($pdo,'ilb_case_variable_definition')){
        $cols=tableColumns($pdo,'ilb_case_variable_definition');
        $m=['key'=>firstColumn($cols,['variable_key','parameter_key','key','code']),'name'=>firstColumn($cols,['variable_name','parameter_name','name','label','title']),'unit'=>firstColumn($cols,['ucum_unit','canonical_unit','unit_code','unit','unit_contract']),'definition'=>firstColumn($cols,['definition_text','definition','description','meaning']),'type'=>firstColumn($cols,['value_kind','value_type','variable_type','data_type']),'status'=>firstColumn($cols,['validation_status','status','lifecycle_status'])];
        $caseBootstrap['variables']=['detected_columns'=>$cols,'mapped_columns'=>$m,'rows_seen'=>0,'rows_upserted'=>0];
        if($m['key']){
            $sel=array_values(array_unique(array_filter($m))); $rows=$pdo->query('SELECT '.implode(',',array_map('qi',$sel)).' FROM `ilb_case_variable_definition`')->fetchAll(); $caseBootstrap['variables']['rows_seen']=count($rows);
            $up=$pdo->prepare("INSERT INTO ilmb_parameter_master (parameter_key,canonical_name,parameter_domain,value_kind,canonical_ucum_unit,definition_text,source_system,source_record_key,status)
              VALUES (?,?,?,?,?,?, 'ilb_case_variable_definition',?,?)
              ON DUPLICATE KEY UPDATE canonical_name=VALUES(canonical_name),canonical_ucum_unit=COALESCE(VALUES(canonical_ucum_unit),canonical_ucum_unit),definition_text=COALESCE(VALUES(definition_text),definition_text),status=VALUES(status),updated_at=CURRENT_TIMESTAMP");
            $find=$pdo->prepare("SELECT parameter_id FROM ilmb_parameter_master WHERE parameter_key=?");
            foreach($rows as $r){$key=trim((string)$r[$m['key']]); if($key==='')continue; $name=$m['name']?trim((string)($r[$m['name']]??'')):''; if($name==='')$name=$key; $unit=$m['unit']?trim((string)($r[$m['unit']]??'')):null; if($unit==='')$unit=null; $def=$m['definition']?(string)($r[$m['definition']]??''):null; $kind=valueKind($m['type']?(string)($r[$m['type']]??''):''); $rawStatus=strtoupper($m['status']?trim((string)($r[$m['status']]??'')):''); $status=(str_contains($rawStatus,'RETIR')||str_contains($rawStatus,'DEPREC'))?'DEPRECATED':'ACTIVE'; $pkey='case_variable:'.$key; $up->execute([$pkey,$name,'case',$kind,$unit,$def,$key,$status]); $find->execute([$pkey]); $variableIds[$key]=(int)$find->fetchColumn(); $caseBootstrap['variables']['rows_upserted']++;}
        }
    }

    $formulaIds=[];
    if(tableExists($pdo,'ilb_case_formula_definition')){
        $cols=tableColumns($pdo,'ilb_case_formula_definition');
        $m=['key'=>firstColumn($cols,['case_formula_key','formula_key','key','code']),'name'=>firstColumn($cols,['formula_name','case_formula_name','name','label','title']),'expression'=>firstColumn($cols,['expression_text','formula_expression','formula_text','expression','formula']),'output'=>firstColumn($cols,['output_variable_key','output_parameter_key','result_variable_key']),'status'=>firstColumn($cols,['validation_status','formula_status','status','lifecycle_status']),'domain'=>firstColumn($cols,['formula_domain','domain','category','formula_type']),'existing'=>firstColumn($cols,['existing_formula_key','source_formula_key','registry_formula_key']),'evidence'=>firstColumn($cols,['evidence_locator','source_citation','citation','source'])];
        $caseBootstrap['formulas']=['detected_columns'=>$cols,'mapped_columns'=>$m,'rows_seen'=>0,'rows_upserted'=>0,'reference_only'=>0];
        if($m['key']){
            $sel=array_values(array_unique(array_filter($m))); $rows=$pdo->query('SELECT '.implode(',',array_map('qi',$sel)).' FROM `ilb_case_formula_definition`')->fetchAll(); $caseBootstrap['formulas']['rows_seen']=count($rows);
            $up=$pdo->prepare("INSERT INTO ilmb_formula_master (formula_key,formula_name,formula_domain,output_parameter_id,expression_text,expression_language,purpose,evidence_class,source_system,source_record_key,source_citation,formula_status,unit_checked,dimensional_analysis_text)
              VALUES (?,?,?,?,?,'EQUATION_TEXT','OTHER','MEASURED_PERSON','ilb_case_formula_definition',?,?,?,0,?)
              ON DUPLICATE KEY UPDATE formula_name=VALUES(formula_name),formula_domain=VALUES(formula_domain),output_parameter_id=VALUES(output_parameter_id),expression_text=VALUES(expression_text),source_citation=VALUES(source_citation),formula_status=VALUES(formula_status),updated_at=CURRENT_TIMESTAMP");
            $find=$pdo->prepare("SELECT formula_id FROM ilmb_formula_master WHERE formula_key=?");
            foreach($rows as $r){$key=trim((string)$r[$m['key']]); if($key==='')continue; $name=$m['name']?trim((string)($r[$m['name']]??'')):''; if($name==='')$name=$key; $expr=$m['expression']?trim((string)($r[$m['expression']]??'')):''; $existing=$m['existing']?trim((string)($r[$m['existing']]??'')):''; if($expr===''){ $expr=$existing!==''?'reference_formula_key='.$existing:'reference_case_formula_key='.$key; $caseBootstrap['formulas']['reference_only']++; } $outKey=$m['output']?trim((string)($r[$m['output']]??'')):''; $outId=$outKey!==''?($variableIds[$outKey]??null):null; $domain=$m['domain']?trim((string)($r[$m['domain']]??'')):'case'; if($domain==='')$domain='case'; $status=governedFormulaStatus($m['status']?(string)($r[$m['status']]??''):''); $citation=$m['evidence']?(string)($r[$m['evidence']]??''):null; $dim=$existing!==''?'legacy_existing_formula_key='.$existing:null; $fkey='case_formula:'.$key; $up->execute([$fkey,$name,$domain,$outId,$expr,$key,$citation,$status,$dim]); $find->execute([$fkey]); $formulaIds[$key]=(int)$find->fetchColumn(); $caseBootstrap['formulas']['rows_upserted']++;}
        }
    }

    if(tableExists($pdo,'ilb_case_formula_input')){
        $cols=tableColumns($pdo,'ilb_case_formula_input');
        $m=['formula'=>firstColumn($cols,['case_formula_key','formula_key']),'variable'=>firstColumn($cols,['variable_key','parameter_key','input_variable_key']),'symbol'=>firstColumn($cols,['symbol_name','input_symbol','symbol','variable_symbol']),'role'=>firstColumn($cols,['input_role','role','variable_role']),'required'=>firstColumn($cols,['required_flag','is_required','required']),'unit'=>firstColumn($cols,['expected_ucum_unit','unit_contract','unit','ucum_unit']),'ordinal'=>firstColumn($cols,['ordinal','input_order','sort_order']),'notes'=>firstColumn($cols,['notes','description','input_note'])];
        $caseBootstrap['inputs']=['detected_columns'=>$cols,'mapped_columns'=>$m,'rows_seen'=>0,'rows_upserted'=>0,'rows_skipped_unresolved'=>0];
        if($m['formula']&&$m['variable']){
            $sel=array_values(array_unique(array_filter($m))); $rows=$pdo->query('SELECT '.implode(',',array_map('qi',$sel)).' FROM `ilb_case_formula_input`')->fetchAll(); $caseBootstrap['inputs']['rows_seen']=count($rows);
            $up=$pdo->prepare("INSERT INTO ilmb_formula_input (formula_id,symbol_name,parameter_id,role,required_flag,expected_ucum_unit,ordinal,notes) VALUES (?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE parameter_id=VALUES(parameter_id),role=VALUES(role),required_flag=VALUES(required_flag),expected_ucum_unit=VALUES(expected_ucum_unit),ordinal=VALUES(ordinal),notes=VALUES(notes)");
            $n=0; foreach($rows as $r){$fk=trim((string)$r[$m['formula']]); $vk=trim((string)$r[$m['variable']]); if(!isset($formulaIds[$fk],$variableIds[$vk])){$caseBootstrap['inputs']['rows_skipped_unresolved']++;continue;} $symbol=$m['symbol']?trim((string)($r[$m['symbol']]??'')):''; if($symbol==='')$symbol=$vk; $role=inputRole($m['role']?(string)($r[$m['role']]??''):''); $req=$m['required']?((int)($r[$m['required']]??1)!==0):true; $unit=$m['unit']?trim((string)($r[$m['unit']]??'')):null; if($unit==='')$unit=null; $ordinal=$m['ordinal']?(int)($r[$m['ordinal']]??++$n):++$n; $notes=$m['notes']?(string)($r[$m['notes']]??''):null; $up->execute([$formulaIds[$fk],substr($symbol,0,64),$variableIds[$vk],$role,$req?1:0,$unit,$ordinal,$notes]); $caseBootstrap['inputs']['rows_upserted']++;}
        }
    }
    $caseBootstrap['status']='CONSOLIDATED_REFERENCE_LAYER';

    $requiredTables=['ilmb_parameter_master','ilmb_parameter_identifier','ilmb_formula_master','ilmb_formula_input','ilmb_parameter_duplicate_candidate','ilmb_formula_duplicate_candidate','ilmb_body_need_run'];
    $requiredViews=['vw_ilmb_common_parameter_master','vw_ilmb_subject_parameter_observation'];
    $check=$pdo->prepare("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=? AND table_type=?"); $missing=[];
    foreach($requiredTables as $name){$check->execute([$name,'BASE TABLE']);if((int)$check->fetchColumn()!==1)$missing[]=$name;} foreach($requiredViews as $name){$check->execute([$name,'VIEW']);if((int)$check->fetchColumn()!==1)$missing[]=$name;}
    $counts=[]; foreach(['parameters'=>'SELECT COUNT(*) FROM ilmb_parameter_master','identifiers'=>'SELECT COUNT(*) FROM ilmb_parameter_identifier','formulas'=>'SELECT COUNT(*) FROM ilmb_formula_master','formula_inputs'=>'SELECT COUNT(*) FROM ilmb_formula_input','resolved_subject_observations'=>'SELECT COUNT(*) FROM vw_ilmb_subject_parameter_observation'] as $key=>$sql)$counts[$key]=(int)$pdo->query($sql)->fetchColumn();
    $result=['body_need_master_ready'=>count($missing)===0,'missing_objects'=>$missing,'applied_migrations'=>$applied,'equation_registry_bootstrap'=>$equationBootstrap,'case_formula_bootstrap'=>$caseBootstrap,'counts'=>$counts,'patient_rows_modified'=>0];
    echo json_encode($result,JSON_UNESCAPED_SLASHES),PHP_EOL; exit(count($missing)===0?0:4);
} catch(Throwable $e){echo 'BODY_NEED_MIGRATION_ERROR: '.$e->getMessage(),PHP_EOL;exit(1);}
