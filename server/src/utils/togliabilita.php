<?php
//ini_set('memory_limit', '1024M');

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "config/constants.php");

echo "<pre>";
try {
    $db = new DatabaseBridge();

    $query_sel_abilita = "SELECT pg.id_personaggio, ab.id_abilita, ab.costo_abilita 
FROM personaggi pg 
JOIN personaggi_has_abilita pha ON pha.personaggi_id_personaggio = pg.id_personaggio 
JOIN abilita ab ON pha.abilita_id_abilita = ab.id_abilita 
WHERE ab.id_abilita IN (33, 36, 39, 41, 52, 53)";

    $res_sel_abilita = $db->doQuery($query_sel_abilita, [], False);

    foreach($res_sel_abilita as $i => $elem)
    {
        echo "restituisco $elem[costo_abilita] px al pg $elem[id_personaggio]\n";
        $query_ridai_px = "UPDATE personaggi SET px_personaggio = px_personaggio + :px WHERE id_personaggio = :idpg";
        //$db->doQuery($query_ridai_px, [":px" => $elem['costo_abilita'], ":idpg" => $elem['id_personaggio']], False);
        
        echo "elimino l'abilita $elem[id_abilita] dalla lista del pg $elem[id_personaggio]\n";
        $query_del_abilita = "DELETE FROM personaggi_has_abilita WHERE personaggi_id_personaggio = :idpg AND abilita_id_abilita = :idab";
        //$db->doQuery($query_del_abilita, [":idpg" => $elem['id_personaggio'], ":idab" => $elem['id_abilita']], False);
    }
} catch (Exception $e) {
    echo $e->getMessage(); 
}


echo "</pre>";