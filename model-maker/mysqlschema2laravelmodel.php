<?php
/**
 * dev 
 */

// $DB_NAME = 'employees';

$file = file_get_contents('schema.sql');
preg_match('/(?<=USE).(\x60.*\x60)/', $file, $matches);
$DB_NAME = str_replace(['`', ' '], '', $matches[0]);
var_dump($DB_NAME, $matches[0]);

$tables_schema = extract_tables_schema($DB_NAME, $file);
var_dump($tables_schema); //return 3 ary

$i = 0;

foreach($tables_schema[0] as $table_schema){
    
    if(false){
        return;
    }

    // var_dump($table_schema); //ok

    $extracted_table_name = extract_table_name($DB_NAME, $table_schema); //one shecma each iteration
    
    // var_dump($extracted_table_name);//ok

    $extracted_colums_line = extract_columns_line($table_schema);

    // var_dump($extracted_colums_line);

    $cols = array();

    foreach($extracted_colums_line[0] as $ecl){
        // var_dump($ecl);
        $column_ary = extract_column_data($ecl);//return 1D data
        // var_dump($column_ary); //array
        array_push($cols, $column_ary); //push to 2D array
    }

    $cols_str = "";

    // var_dump($cols);//2D ary

    
    foreach( $cols as $col){
        // var_dump($col[0]);
        if( empty($cols_str) ){
            $cols_str = " '$col[0]' ";
        }else{
            $cols_str = "$cols_str,  '$col[0]' ";
        }

    }

    // var_dump($cols_str);
    // var_dump($extracted_table_name);

    write_model($extracted_table_name, $cols_str);

    $i=$i+1;
};



// foreach($tables_name as $table_name){
//     write_model($table_name);
// }

/*
* spit into individual tables schemas
*/

function extract_tables_schema($DB_NAME, $file): array
{

    preg_match_all(
        "/(CREATE TABLE IF NOT EXISTS `$DB_NAME`)[.\x20\x28\x0A\w\x60\x2C\x29\x27\x3D\x0D]*;/",
        $file,
        $result,
        PREG_PATTERN_ORDER,
        0
    );

    return $result;
}

/**
 * extract table name
 */
function extract_table_name($DB_NAME, $table_schema):string{
    
    preg_match_all("/(?<=`$DB_NAME`.).*.\x20/", $table_schema, $matches);

    // var_dump($matches) . "\n";
 
    $m = $matches[0][0];
    $replaced_m = str_replace(['`', ' '], '', $m);
    $result = ucwords($replaced_m);

    return $result;
}


function extract_columns_line($table_schema):array{
    /**
     * return type is not compulsary but i do as habit and practise
     */
    preg_match_all(
        // '/(\x60.*\x60).*(,|\x29)/',
        // '/((CONSTRAINT)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0A|\x2C\x0A)|(\x20\x20\x60.*\x60).*(\x2C\x0A)/',
        // '/((CONSTRAINT)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0D|\x2C\x0D)/',
        // '/(\x20\x20\x60.*\x60).*(\x2C\x0D)/',
        // '/((CONSTRAINT)|(UNIQUE INDEX)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0D|\x2C\x0D)|(\x20\x20\x60.*\x60).*(\x2C\x0D)/',
        // '/((CONSTRAINT)|(UNIQUE INDEX)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0D|\x2C\x0D)|(\x20\x20\x60.*\x60).*(\x2C\x0D)/',
        // ((CONSTRAINT)|(UNIQUE INDEX)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0D|\x2C\x0A)
        '/((CONSTRAINT)|(UNIQUE INDEX)|(INDEX)|(PRIMARY))[\w\x20\x0A\x0D\x28\x29\x60\x2E]*(\x29\x0D|\x2C\x0D)|(\x60.*\x60).*(\x2C\x0D)/',
     $table_schema, $matches, PREG_PATTERN_ORDER, 0);

    return $matches;
}

function extract_column_data($cols_line):array{

    $cols_line = str_replace([",","`"],"",$cols_line);
    
    $col = explode(" ", $cols_line);
    
    // var_dump($cols_line, $col);

    return $col;

}

function write_model($model, $col_str)
{
    $first_line = "<?php\n\n";
    $im1 = "namespace App\Models;\n\n";
    $im2 = "use Illuminate\Database\Eloquent\Model;\n\n";
    $second_line = "class $model extends Model\n";
    $third_line = "{\n";
    $fouth_line = "\tprotected \$table = '$model';\n";
    //need tto put columns name here
    $fifth_line = "\tprotected \$fillable = [$col_str];\n";
    $last_line = "}\n";

    $my_model = fopen("./Models/$model.php", "w");
    fwrite($my_model, $first_line);
    fwrite($my_model, $im1);
    fwrite($my_model, $im2);
    fwrite($my_model, $second_line);
    fwrite($my_model, $third_line);
    fwrite($my_model, $fouth_line);
    fwrite($my_model, $fifth_line);
    fwrite($my_model, $last_line);
    fclose($my_model);
}
