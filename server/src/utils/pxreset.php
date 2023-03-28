<?php
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/DatabaseBridge.class.php");

function registraAzione($database, $pgid, $azione, $tabella, $campo, $vecchio_valore, $nuovo_valore)
{
    $vecchio = !isset($vecchio_valore) ? "NULL" : ":vecchio";
    $nuovo   = !isset($nuovo_valore) ? "NULL" : ":nuovo";

    $query_azione = "INSERT INTO storico_azioni ( id_personaggio_azione, giocatori_email_giocatore, tipo_azione, tabella_azione, campo_azione, valore_vecchio_azione, valore_nuovo_azione )
                        VALUES ( :idpg, :email, :azione, :tabella, :campo, $vecchio, $nuovo )";

    $params = [
        ":idpg"    => $pgid,
        ":email"   => "miroku_87@yahoo.it",
        ":azione"  => $azione,
        ":tabella" => $tabella,
        ":campo"   => $campo
    ];

    if (isset($vecchio_valore))
        $params[":vecchio"] = $vecchio_valore;

    if (isset($nuovo_valore))
        $params[":nuovo"] = $nuovo_valore;

    $database->doQuery($query_azione, $params, False);
}

echo "<html><head><meta charset='UTF-8' /></head><body>";

try {
    $db = new DatabaseBridge();

    $MAPPA_COSTO_CLASSI_CIVILI = array(0, 20, 40, 60, 80, 100, 120);

    $query = "SELECT
	t.id_personaggio,
	t.nome_personaggio,
    CONCAT(t.nome_giocatore,' ',t.cognome_giocatore) as nome_giocatore,
	t.px_personaggio,
	t.pc_personaggio,
    t.num_eventi_tot,
    t.num_live_online,
    t.num_giorni_live,
    t.px_base,
    t.px_base + ((t.num_eventi_tot - t.num_live_online) * 10) + (t.num_giorni_live * 20) as px_guadagnati,
    t.tot_costo_abilita_civili,
    t.num_classi_civili,
    t.pc_base,
    t.pc_base + t.num_eventi_tot - t.num_live_online as pc_guadagnati, 
    t.pc_spesi,
    t.pc_base + t.num_eventi_tot - t.num_live_online - t.pc_spesi as pc_rimasti
	FROM (
        SELECT 
            p.id_personaggio,
            p.nome_personaggio, 
            g.nome_giocatore,
            g.cognome_giocatore,
            p.px_personaggio, 
            p.pc_personaggio, 
            g.ruoli_nome_ruolo,
        	COUNT(ip.eventi_id_evento) as num_eventi_tot,
        	IF(p.data_creazione_personaggio > '2019-01-01 00:00:00', 220, 100) as px_base,
        	IF(p.data_creazione_personaggio > '2019-01-01 00:00:00', 6, 4) as pc_base,
        	SUM((e.data_fine_evento - e.data_inizio_evento) + 1) as num_giorni_live,
            SUM(IF(e.id_evento IN (10,11), 1, 0)) as num_live_online,
            (
                SELECT
                    SUM(a.costo_abilita) 
                FROM personaggi p2
                JOIN personaggi_has_abilita pha ON pha.personaggi_id_personaggio = p2.id_personaggio
                JOIN abilita a ON a.id_abilita = pha.abilita_id_abilita
                WHERE 
                    a.tipo_abilita = 'civile' AND
                    p2.id_personaggio = p.id_personaggio
                GROUP BY p2.id_personaggio
            ) as tot_costo_abilita_civili,
            (
                SELECT
                    COUNT(c.id_classe) 
                FROM personaggi p3
                JOIN personaggi_has_classi phc ON phc.personaggi_id_personaggio = p3.id_personaggio
                JOIN classi c ON c.id_classe = phc.classi_id_classe
                WHERE 
                    c.tipo_classe = 'civile' AND
                    p3.id_personaggio = p.id_personaggio
                GROUP BY p3.id_personaggio
            ) as num_classi_civili,
            (
                (SELECT 
                    COUNT(a2.id_abilita)
                FROM
                    personaggi p4
                        JOIN
                    personaggi_has_abilita pha2 ON pha2.personaggi_id_personaggio = p4.id_personaggio
                        JOIN
                    abilita a2 ON a2.id_abilita = pha2.abilita_id_abilita
                WHERE
                    a2.tipo_abilita = 'militare'
                    AND p4.id_personaggio = p.id_personaggio
                GROUP BY p4.id_personaggio) + (SELECT 
                    COUNT(c2.id_classe)
                FROM
                    personaggi p5
                        JOIN
                    personaggi_has_classi phc2 ON phc2.personaggi_id_personaggio = p5.id_personaggio
                        JOIN
                    classi c2 ON c2.id_classe = phc2.classi_id_classe
                WHERE
                    c2.tipo_classe = 'militare'
                    AND p5.id_personaggio = p.id_personaggio
                GROUP BY p5.id_personaggio)
            ) as pc_spesi
        FROM personaggi p
        JOIN iscrizione_personaggi ip ON ip.personaggi_id_personaggio = p.id_personaggio
        JOIN eventi e ON e.id_evento = ip.eventi_id_evento
        JOIN giocatori g ON g.email_giocatore = p.giocatori_email_giocatore
        WHERE 
            g.ruoli_nome_ruolo NOT IN ('staff','admin') AND
        	ip.ha_partecipato_iscrizione = 1
        GROUP BY p.id_personaggio
    ) as t
    ORDER BY pc_rimasti ASC
    LIMIT 10000";
    $risultati = $db->doQuery($query, [], False);

    echo "<table><thead><tr>
    <td>ID PG</td>
    <td>NOME PG</td>
    <td>NOME GIOCATORE</td>
    <td>PX GUADAGNATI</td>
    <td>PX RIMASTI</td>
    <td>PC GUADAGNATI</td>
    <td>PC RIMASTI</td>
    </tr></thead><tbody>";

    foreach ($risultati as $r) {
        $px_spesi = (int)$r["tot_costo_abilita_civili"];

        for ($i = 0; $i < (int)$r["num_classi_civili"]; $i++)
            $px_spesi += $MAPPA_COSTO_CLASSI_CIVILI[$i];

        $px_rimasti = (int)$r[px_guadagnati] - $px_spesi;
        
        echo "
        <td>$r[id_personaggio]</td>
        <td>$r[nome_personaggio]</td>
        <td>$r[nome_giocatore]</td>
        <td>$r[px_guadagnati]</td>
        <td>$px_rimasti</td>
        <td>$r[pc_guadagnati]</td>
        <td>$r[pc_rimasti]</td>
        </tr>";

    //     $query_mod = "UPDATE personaggi SET px_personaggio = :px, pc_personaggio = :pc WHERE id_personaggio = :id";
    //     $db->doQuery($query_mod, [":px" => $r["px_guadagnati"], ":pc" => $r["pc_guadagnati"], ":id" => $r["id_personaggio"]], False);

    //     registraAzione(
    //         $db,
    //         $r["id_personaggio"],
    //         "UPDATE",
    //         "personaggi",
    //         "px_personaggio",
    //         $r["px_personaggio"],
    //         $r["px_guadagnati"]
    //     );

    //     registraAzione(
    //         $db,
    //         $r["id_personaggio"],
    //         "UPDATE", 
    //         "personaggi",
    //         "pc_personaggio",
    //         $r["pc_personaggio"],
    //         $r["pc_guadagnati"]
    //     );

    //     if ($px_rimasti < 0) {
    //         echo "$r[nome_personaggio] ($r[id_personaggio]) => RESETTO ABILITA CIVILI\n";
    //         $query_ab = "
    //         SELECT 
    //             pha.abilita_id_abilita,
    //             a.nome_abilita
    //         FROM 
    //             personaggi_has_abilita pha
    //         JOIN 
    //             abilita a on a.id_abilita = pha.abilita_id_abilita
    //         WHERE
    //             pha.personaggi_id_personaggio = :id AND
    //             a.tipo_abilita = 'civile';";
    //         $ris_ab = $db->doQuery($query_ab, [":id" => $r["id_personaggio"]], False);

    //         $query_del_ab = "DELETE FROM personaggi_has_abilita 
    //             WHERE personaggi_id_personaggio = :id AND abilita_id_abilita IN (SELECT id_abilita FROM abilita WHERE tipo_abilita = 'civile')";
    //         $db->doQuery($query_del_ab, [":id" => $r["id_personaggio"]], False);

    //         foreach ($ris_ab as $ra) {
    //             registraAzione(
    //                 $db,
    //                 $r["id_personaggio"],
    //                 "DELETE",
    //                 "personaggi_has_abilita",
    //                 "",
    //                 $ra["nome_abilita"]." (".$ra["abilita_id_abilita"].")",
    //                 null
    //             );
    //         }

    //         $query_cl = "
    //         SELECT 
    //             phc.classi_id_classe,
    //             c.nome_classe
    //         FROM 
    //             personaggi_has_classi phc
    //         JOIN 
    //             classi c on c.id_classe = phc.classi_id_classe
    //         WHERE
    //             phc.personaggi_id_personaggio = :id AND
    //             c.tipo_classe = 'civile';";
    //         $ris_cl = $db->doQuery($query_cl, [":id" => $r["id_personaggio"]], False);

    //         $query_del_cl = "DELETE FROM personaggi_has_classi 
    //             WHERE personaggi_id_personaggio = :id AND classi_id_classe IN (SELECT id_classe FROM classi WHERE tipo_classe = 'civile')";
    //         $db->doQuery($query_del_cl, [":id" => $r["id_personaggio"]], False);

    //         foreach ($ris_cl as $rc) {
    //             registraAzione(
    //                 $db,
    //                 $r["id_personaggio"],
    //                 "DELETE",
    //                 "personaggi_has_classi",
    //                 "",
    //                 $rc["nome_classe"]." (".$rc["classi_id_classe"].")",
    //                 null
    //             );
    //         }

    //         $query_op = "
    //         SELECT 
    //             pho.abilita_id_abilita,
    //             a.nome_abilita,
    //             o.opzione 
    //         FROM 
    //             personaggi_has_opzioni_abilita pho
    //         JOIN 
    //             abilita a on a.id_abilita = pho.abilita_id_abilita
    //         JOIN
    //             opzioni_abilita o on o.opzione = pho.opzioni_abilita_opzione
    //         WHERE
    //             pho.personaggi_id_personaggio = :id AND
    //             a.tipo_abilita = 'civile';";
    //         $ris_op = $db->doQuery($query_op, [":id" => $r["id_personaggio"]], False);

    //         $query_del_op = "DELETE FROM personaggi_has_opzioni_abilita 
    //             WHERE personaggi_id_personaggio = :id AND abilita_id_abilita IN (SELECT id_abilita FROM abilita WHERE tipo_abilita = 'civile')";
    //         $db->doQuery($query_del_op, [":id" => $r["id_personaggio"]], False);

    //         foreach ($ris_op as $op) {
    //             registraAzione(
    //                 $db,
    //                 $r["id_personaggio"],
    //                 "DELETE",
    //                 "personaggi_has_opzioni_abilita",
    //                 "",
    //                 $op["nome_abilita"]." > ".$op["opzione"],
    //                 null
    //             );
    //         }
    //     }
    // }

    echo "</tbody></table>";
} catch (Exception $e) {
    echo $e->getMessage();
}

echo "</body></html>";