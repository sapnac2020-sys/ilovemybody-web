<?php
declare(strict_types=1);
const EXPECTED_DATABASE = 'u756742628_ilovemybody';
if (PHP_SAPI !== 'cli') { exit(2); }
$config = require ($argv[1] ?? '');
$db = is_array($config['db'] ?? null) ? $config['db'] : ['host'=>$config['host']??null,'port'=>$config['port']??3306,'name'=>$config['db']??null,'user'=>$config['user']??null,'pass'=>$config['pass']??null,'charset'=>$config['charset']??'utf8mb4'];
if (($db['name'] ?? '') !== EXPECTED_DATABASE) { throw new RuntimeException('Refusing non-ILMB database.'); }
$pdo = new PDO(sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',$db['host'],$db['port']??3306,EXPECTED_DATABASE,$db['charset']??'utf8mb4'),(string)$db['user'],(string)$db['pass'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::MYSQL_ATTR_MULTI_STATEMENTS=>true]);
$sql=file_get_contents($argv[2]??''); if (!$sql) throw new RuntimeException('Migration is empty.');
$stmt=$pdo->prepare($sql); $stmt->execute(); do { if($stmt->columnCount()) $stmt->fetchAll(); } while($stmt->nextRowset()); $stmt->closeCursor();
$r=$pdo->query('SELECT * FROM v_ilb_psoriasis_solver_readiness')->fetch(PDO::FETCH_ASSOC);
if ((int)$r['lifestyle_variables']!==26 || (int)$r['transfer_slots']!==182 || (int)$r['missing_coefficients']!==182 || (int)$r['equations']!==15) throw new RuntimeException('Psoriasis structural counts failed.');
if ($r['readiness_status']!=='BLOCKED_INPUTS_AND_COEFFICIENTS') throw new RuntimeException('Unsafe release state.');
echo json_encode(['database'=>EXPECTED_DATABASE,'psoriasis_solver'=>$r,'safety'=>'No equivalence or patient treatment recommendation released.'],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES)."\n";
