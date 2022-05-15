<?php
//ini_set('memory_limit', '1024M');

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "config/constants.php");

function get_combinations($arrays)
{
    $result = [[]];
    foreach ($arrays as $property => $property_values) {
        $tmp = [];
        foreach ($result as $result_item) {
            foreach ($property_values as $property_value) {
                $tmp[] = array_merge($result_item, [$property => $property_value]);
            }
        }
        $result = $tmp;
    }
    return $result;
}


echo "<pre>";
try {
    $db = new DatabaseBridge();

    $query_comp = "SELECT id_componente, 
        curativo_primario_componente, 
        tossico_primario_componente, 
        psicotropo_primario_componente 
    FROM componenti_crafting 
    WHERE tipo_crafting_componente = 'chimico' AND tipo_componente = 'sostanza'";

    $res_comp = $db->doQuery($query_comp, [], False);
    $id_comp = [];

    echo "comps := map[string]componente{";
    foreach($res_comp as $i => $elem)
    {
        //$id_comp[] = $elem['id_componente'];
        echo "
        \"".$elem['id_componente']."\": { 
            curativo: \"".$elem["curativo_primario_componente"]."\", 
            tossico: \"".$elem["tossico_primario_componente"]."\", 
            psicotropo: \"".$elem["psicotropo_primario_componente"]."\",
        },";
    }
    echo "\n}";

    // $effetti_query = "SELECT * FROM crafting_chimico ORDER BY min_chimico";
    // $res_effetti = $db->doQuery($effetti_query, [], False);
} catch (Exception $e) {
    echo $e->getMessage(); 
}


echo "</pre>";