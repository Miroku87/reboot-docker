<?php

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "config/constants.php");

try {
$db = new DatabaseBridge();

$query_conv = "SELECT 
CONCAT( 
    IF( 
        mittente_messaggio > destinatario_messaggio,
        CONCAT(
            mittente_messaggio,
            '_',
            destinatario_messaggio
        ),
        CONCAT(
            destinatario_messaggio,
            '_',
            mittente_messaggio
        )
    ),
    '_',
REPLACE
    (oggetto_messaggio, 'Re%3A%20', '')
) AS temp_id 
FROM 
messaggi_ingioco 
GROUP BY 
temp_id 
ORDER BY 
temp_id ASC, 
id_messaggio ASC";

$res_conv = $db->doQuery($query_conv, [], False);
$convos = [];

foreach($res_conv as $i => $elem)
{
    $convos[$elem['temp_id']] = $i;
}

$msgs_query = "SELECT 
id_messaggio, 
CONCAT( 
    IF( 
        mittente_messaggio > destinatario_messaggio,
        CONCAT(
            mittente_messaggio,
            '_',
            destinatario_messaggio
        ),
        CONCAT(
            destinatario_messaggio,
            '_',
            mittente_messaggio
        )
    ),
    '_',
REPLACE
    (oggetto_messaggio, 'Re%3A%20', '')
) AS temp_id 
FROM 
messaggi_ingioco 
ORDER BY 
temp_id ASC, 
id_messaggio ASC";

$res_msgs = $db->doQuery($msgs_query, [], False);

foreach($res_msgs as $i => $elem)
{
    echo "UPDATE messaggi_ingioco SET id_conversazione = ".$convos[$elem['temp_id']]." WHERE id_messaggio = ".$elem['id_messaggio']."; <br>";
}

} catch (Exception $e) {
    echo $e->getMessage(); 
}
