<?php

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class CraftingManager
{
    protected $idev_in_corso;
    protected $session;
    protected $db;

    public function __construct($idev_in_corso = NULL)
    {
        $this->idev_in_corso = $idev_in_corso;
        $this->db = new DatabaseBridge();
        $this->session = SessionManager::getInstance();
    }

    public function __destruct()
    {
    }

    public function inserisciRicettaNetrunner($pgid, $programmi)
    {
        global $GRANT_VISUALIZZA_CRAFT_PROGRAM;

        UsersManager::operazionePossibile($this->session, $GRANT_VISUALIZZA_CRAFT_PROGRAM);

        $nome_programma = $programmi[0]["nome_programma"];
        $risultati = [];
        unset($programmi[0]["nome_programma"]);

        foreach ($programmi as $p) {
            $sql_x = "SELECT effetto_valore_crafting AS effetto, parametro_collegato_crafting AS pcc FROM crafting_programmazione WHERE parametro_crafting = 'X1' AND valore_parametro_crafting = :x_val";
            $res_x = $this->db->doQuery($sql_x, [":x_val" => $p["x_val"]], False);

            $sql_y = "SELECT effetto_valore_crafting AS effetto, parametro_collegato_crafting AS pcc FROM crafting_programmazione WHERE parametro_crafting = :pcc AND valore_parametro_crafting = :y_val";
            $res_y = $this->db->doQuery($sql_y, [":pcc" => $res_x[0]["pcc"], ":y_val" => $p["y_val"]], False);

            $sql_z = "SELECT effetto_valore_crafting AS effetto FROM crafting_programmazione WHERE parametro_crafting = :pcc AND valore_parametro_crafting = :z_val";
            $res_z = $this->db->doQuery($sql_z, [":pcc" => $res_y[0]["pcc"], ":z_val" => $p["z_val"]], False);

            $risultati[] = $res_x[0]["effetto"] . " - " . $res_y[0]["effetto"] . " - " . $res_z[0]["effetto"];
        }

        $risultato_crafting = implode(";", $risultati);

        $sql_progr = "SELECT id_unico_risultato_ricetta FROM ricette WHERE risultato_ricetta = :risultato";
        $progr_id = $this->db->doQuery($sql_progr, [":risultato" => $risultato_crafting], False);

        if (!isset($progr_id) || count($progr_id) === 0) {
            $sql_id_res = "SELECT IFNULL( MAX( COALESCE(id_unico_risultato_ricetta, 0) ), 0) AS id_unico_risultato_ricetta FROM ricette WHERE tipo_ricetta = :tipo";
            $progr_id = $this->db->doQuery($sql_id_res, [":tipo" => "Programmazione"], False);
            $progr_id[0]["id_unico_risultato_ricetta"] = (int) $progr_id[0]["id_unico_risultato_ricetta"] + 1;
        }

        $params = [
            ":idpg" => $pgid,
            ":tipo" => "Programmazione",
            ":tipo_ogg" => "Programma",
            ":nome" => $nome_programma,
            ":res" => $risultato_crafting,
            ":id_res" => (int) $progr_id[0]["id_unico_risultato_ricetta"]
        ];

        $sql_ricetta = "INSERT INTO ricette (id_ricetta, personaggi_id_personaggio, data_inserimento_ricetta, tipo_ricetta, tipo_oggetto, nome_ricetta, risultato_ricetta, approvata_ricetta, id_unico_risultato_ricetta)
                          VALUES (NULL, :idpg, NOW(), :tipo, :tipo_ogg, :nome, :res, 0, :id_res )";
        $id_nuova = $this->db->doQuery($sql_ricetta, $params, False);

        foreach ($programmi as $k => $p) {
            $inserts[] = [":idcomp" => "X=" . $p["x_val"], ":idric" => $id_nuova, ":ord" => $k];
            $inserts[] = [":idcomp" => "Y=" . $p["y_val"], ":idric" => $id_nuova, ":ord" => $k];
            $inserts[] = [":idcomp" => "Z=" . $p["z_val"], ":idric" => $id_nuova, ":ord" => $k];
        }

        $sql_componenti = "INSERT INTO componenti_ricetta (componenti_crafting_id_componente, ricette_id_ricetta, ordine_crafting) VALUES (:idcomp,:idric,:ord)";
        $this->db->doMultipleManipulations($sql_componenti, $inserts, False);

        $output = ["status" => "ok", "result" => true];

        return json_encode($output);
    }

    public function inserisciRicettaTecnico($pgid, $nome, $tipo, $batterie, $strutture, $applicativi)
    {
        global $GRANT_VISUALIZZA_CRAFT_TECNICO;

        UsersManager::operazionePossibile($this->session, $GRANT_VISUALIZZA_CRAFT_TECNICO);

        $tutti_id = array_merge($batterie, $strutture, $applicativi);
        $sotto_query = [];

        for ($i = 0; $i < count($tutti_id); $i++)
            $sotto_query[] = "SELECT effetto_sicuro_componente,
                                     IF( POSITION( 'deve dichiarare' IN  LOWER( effetto_sicuro_componente ) )  > 0,TRUE,FALSE) AS deve,
                                     tipo_applicativo_componente,
                                     volume_componente,
                                     energia_componente FROM componenti_crafting WHERE id_componente = ?";

        $union = implode(" UNION ALL ", $sotto_query);
        $sql_check = "SELECT effetto_sicuro_componente, tipo_applicativo_componente, volume_componente, energia_componente, deve FROM ( $union ) AS u";
        $check_res = $this->db->doQuery($sql_check, $tutti_id, False);

        if (!isset($check_res) || count($check_res) === 0)
            throw new APIException("Il crafting non &egrave; andato a buon fine. Riprovare.");

        $deve = array_sum(array_values(Utils::mappaArrayDiArrayAssoc($check_res, "deve")));

        if ($deve > 1)
            throw new APIException("Impossibile completare l'operazione. Non &egrave; possibile combinare pi&ugrave; applicazioni che DEVONO dichiarare qualcosa.");

        $volume = array_sum(array_values(Utils::mappaArrayDiArrayAssoc($check_res, "volume_componente")));
        $energia = array_sum(array_values(Utils::mappaArrayDiArrayAssoc($check_res, "energia_componente")));
        $tipi_applicativi = Utils::mappaArrayDiArrayAssoc($check_res, "tipo_applicativo_componente");
        $effetti_componenti = Utils::mappaArrayDiArrayAssoc($check_res, "effetto_sicuro_componente");
        $risultato_crafting = implode(";", $effetti_componenti);
        $risultato_crafting = preg_replace("/^;+/", "$1", $risultato_crafting);

        if ($volume < 0 || $energia < 0)
            throw new APIException("Il crafting non &egrave; andato a buon fine. Riprovare.");

        $params = [
            ":idpg" => $pgid,
            ":tipo" => "Tecnico",
            ":tipo_ogg" => $tipo,
            ":nome" => $nome,
            ":res" => $risultato_crafting
        ];

        $sql_ricetta = "INSERT INTO ricette (id_ricetta, personaggi_id_personaggio, data_inserimento_ricetta, tipo_ricetta, tipo_oggetto, nome_ricetta, risultato_ricetta)
                          VALUES (NULL, :idpg, NOW(), :tipo, :tipo_ogg, :nome, :res )";
        $id_nuova = $this->db->doQuery($sql_ricetta, $params, False);

        foreach ($tutti_id as $id)
            $inserts[] = [":idcomp" => $id, ":idric" => $id_nuova];

        $sql_componenti = "INSERT INTO componenti_ricetta (componenti_crafting_id_componente, ricette_id_ricetta) VALUES (:idcomp,:idric)";
        $this->db->doMultipleManipulations($sql_componenti, $inserts, False);

        $output = ["status" => "ok", "result" => true];

        return json_encode($output);
    }

    public function inserisciRicettaMedico($pgid, $nome, $supporto, $principio_attivo, $sostanza_1, $sostanza_2, $sostanza_3)
    {
        global $GRANT_VISUALIZZA_CRAFT_CHIMICO;

        UsersManager::operazionePossibile($this->session, $GRANT_VISUALIZZA_CRAFT_CHIMICO);

        $sql_info = "SELECT id_componente,
                            tipo_componente,
                            curativo_primario_componente,
                            tossico_primario_componente,
                            psicotropo_primario_componente,
                            REPLACE(possibilita_dipendeza_componente,',','.') AS possibilita_dipendeza_componente,
                            effetto_sicuro_componente,
                            descrizione_componente
                     FROM componenti_crafting
                     WHERE id_componente IN (?,?,?,?,?)";
        $info = $this->db->doQuery($sql_info, [$supporto, $principio_attivo, $sostanza_1, $sostanza_2, $sostanza_3], False);

        $info_supporto = array_values(Utils::filtraArrayDiArrayAssoc($info, "id_componente", [$supporto]))[0];
        $info_principio = array_values(Utils::filtraArrayDiArrayAssoc($info, "id_componente", [$principio_attivo]))[0];
        $info_sostanza1 = array_values(Utils::filtraArrayDiArrayAssoc($info, "id_componente", [$sostanza_1]))[0];
        $info_sostanza2 = array_values(Utils::filtraArrayDiArrayAssoc($info, "id_componente", [$sostanza_2]))[0];
        $info_sostanza3 = array_values(Utils::filtraArrayDiArrayAssoc($info, "id_componente", [$sostanza_3]))[0];

        $curativo = (int) $info_principio["curativo_primario_componente"] +
            (int) $info_sostanza1["curativo_primario_componente"] +
            (int) $info_sostanza2["curativo_primario_componente"] +
            (int) $info_sostanza3["curativo_primario_componente"];

        $calcoli = "CURA " . ((int) $info_principio["curativo_primario_componente"]) . " + " . ((int) $info_sostanza1["curativo_primario_componente"]) . " + " . ((int) $info_sostanza2["curativo_primario_componente"]) . " + " . ((int) $info_sostanza3["curativo_primario_componente"]) . " = " . $curativo . "\n";

        $tossico = (int) $info_principio["tossico_primario_componente"] +
            (int) $info_sostanza1["tossico_primario_componente"] +
            (int) $info_sostanza2["tossico_primario_componente"] +
            (int) $info_sostanza3["tossico_primario_componente"];

        $calcoli .= "TOSSICO " . ((int) $info_principio["tossico_primario_componente"]) . " + " . ((int) $info_sostanza1["tossico_primario_componente"]) . " + " . ((int) $info_sostanza2["tossico_primario_componente"]) . " + " . ((int) $info_sostanza3["tossico_primario_componente"]) . " = " . $tossico . "\n";

        $id_psicotropo = (int) $info_principio["psicotropo_primario_componente"] +
            (int) $info_sostanza1["psicotropo_primario_componente"] +
            (int) $info_sostanza2["psicotropo_primario_componente"] +
            (int) $info_sostanza3["psicotropo_primario_componente"];

        $calcoli .= "PSICO " . ((int) $info_principio["psicotropo_primario_componente"]) . " + " . ((int) $info_sostanza1["psicotropo_primario_componente"]) . " + " . ((int) $info_sostanza2["psicotropo_primario_componente"]) . " + " . ((int) $info_sostanza3["psicotropo_primario_componente"]) . " = " . $id_psicotropo . "\n";

        $dipendenza = (int) $info_principio["possibilita_dipendeza_componente"] +
            (int) $info_sostanza1["possibilita_dipendeza_componente"] +
            (int) $info_sostanza2["possibilita_dipendeza_componente"] +
            (int) $info_sostanza3["possibilita_dipendeza_componente"];

        $subquery = "";
        $params = [":id_psico" => $id_psicotropo];

        if ($curativo > $tossico) {
            $subquery = "( SELECT curativo_crafting_chimico FROM crafting_chimico WHERE :id_effetto BETWEEN min_chimico AND max_chimico ) AS effetto,";
            $params[":id_effetto"] = ceil($curativo - $tossico);
        } else if ($curativo < $tossico) {
            $subquery = "( SELECT tossico_crafting_chimico FROM crafting_chimico WHERE :id_effetto BETWEEN min_chimico AND max_chimico ) AS effetto,";
            $params[":id_effetto"] = ceil($tossico - $curativo);
        }

        $sql_risultato = "SELECT $subquery
                                ( SELECT psicotropo_crafting_chimico FROM crafting_chimico WHERE :id_psico BETWEEN min_chimico AND max_chimico ) AS psicotropo";
        $risultato = $this->db->doQuery($sql_risultato, $params, False);
        $arr_risult = [];

        if (isset($risultato[0]["effetto"]))
            $arr_risult[] = $risultato[0]["effetto"];

        if (isset($risultato[0]["psicotropo"]))
            $arr_risult[] = $risultato[0]["psicotropo"];

        if (isset($info_supporto["effetto_sicuro_componente"]))
            $arr_risult[] = $info_supporto["effetto_sicuro_componente"];

        // $arr_risult[] = "Dipendenza: $dipendenza";

        $risultato_crafting = preg_replace("/^;+/", "$1", implode(";", $arr_risult));

        if (!isset($risultato[0]["effetto"]) && empty($risultato[0]["psicotropo"]))
            $risultato_crafting = "Nessun effetto";

        $params = [
            ":idpg" => $pgid,
            ":tipo" => "Chimico",
            ":tipo_ogg" => "Sostanza",
            ":nome" => $nome,
            ":risult" => $risultato_crafting
        ];

        $sql_ricetta = "INSERT INTO ricette (id_ricetta, personaggi_id_personaggio, data_inserimento_ricetta, tipo_ricetta, tipo_oggetto, nome_ricetta, risultato_ricetta)
                          VALUES (NULL, :idpg, NOW(), :tipo, :tipo_ogg, :nome, :risult )";
        $id_nuova = $this->db->doQuery($sql_ricetta, $params, False);

        $inserts[] = [":idcomp" => $supporto, ":idric" => $id_nuova, ":ruolo" => "Base"];
        $inserts[] = [":idcomp" => $principio_attivo, ":idric" => $id_nuova, ":ruolo" => "Sostanza Satellite"];
        $inserts[] = [":idcomp" => $sostanza_1, ":idric" => $id_nuova, ":ruolo" => "Sostanza Satellite"];
        $inserts[] = [":idcomp" => $sostanza_2, ":idric" => $id_nuova, ":ruolo" => "Sostanza Satellite"];
        $inserts[] = [":idcomp" => $sostanza_3, ":idric" => $id_nuova, ":ruolo" => "Sostanza Satellite"];

        $sql_componenti = "INSERT INTO componenti_ricetta (componenti_crafting_id_componente, ricette_id_ricetta, ruolo_componente_ricetta) VALUES (:idcomp,:idric,:ruolo)";
        $this->db->doMultipleManipulations($sql_componenti, $inserts, False);

        $output = ["status" => "ok", "result" => true, "calcoli" => $calcoli];

        return json_encode($output);
    }

    public function modificaRicetta($id_r, $modifiche)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        if (isset($modifiche["old_costo_attuale_ricetta"]) && $modifiche["old_costo_attuale_ricetta"] !== $modifiche["costo_attuale_ricetta"]) {
            $modifiche["costo_vecchio_ricetta"] = $modifiche["old_costo_attuale_ricetta"];
            unset($modifiche["old_costo_attuale_ricetta"]);
        }

        $to_update = implode(" = ?, ", array_keys($modifiche)) . " = ?";
        $valori = array_values($modifiche);
        $valori[] = $id_r;

        $query = "UPDATE ricette SET $to_update WHERE id_ricetta = ?";

        $this->db->doQuery($query, $valori, False);

        return "{\"status\": \"ok\",\"result\": \"true\"}";
    }

    public function recuperaRicette($draw, $columns, $order, $start, $length, $search, $filtro = NULL, $pgid = -1, $check_grants = True, $where = [])
    {
        if ($check_grants)
            UsersManager::operazionePossibile($this->session, __FUNCTION__, $pgid);

        $filter = False;
        $order_str = "";
        $params = [];
        $campi_prvt = ["ri.risultato_ricetta", "ri.id_unico_risultato_ricetta", "ri.note_ricetta", "ri.extra_cartellino_ricetta"];
        $campi_str = (int) $pgid === -1 ? ", " . implode(", ", $campi_prvt) : "";

        if (isset($search) && isset($search["value"]) && $search["value"] != "") {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where[] = " (
						r.nome_giocatore LIKE :search OR
						r.personaggi_id_personaggio LIKE :search OR
						r.nome_personaggio LIKE :search OR
						r.tipo_ricetta LIKE :search OR
						r.componenti_ricetta LIKE :search OR
						r.risultato_ricetta LIKE :search OR
						r.note_ricetta LIKE :search OR
						r.note_pg_ricetta LIKE :search OR
						r.extra_cartellino_ricetta LIKE :search OR
						r.data_inserimento_it LIKE :search
					  )";
        }

        if (isset($order) && !empty($order) && count($order) > 0) {
            $sorting = array();
            foreach ($order as $elem) {
                $colonna = $columns[$elem["column"]]["data"];
                $colonna = $colonna === "data_inserimento_it" ? "data_inserimento_ricetta" : $colonna;
                $sorting[] = "r." . $colonna . " " . $elem["dir"];
            }
            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        if ((int) $pgid > 0) {
            $where[] = "r.personaggi_id_personaggio = :pgid";
            $params[":pgid"] = $pgid;
        }

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_ric = "SELECT * FROM
                      (
                        SELECT  ri.id_ricetta,
                                ri.personaggi_id_personaggio,
                                DATE_FORMAT( ri.data_inserimento_ricetta, '%d/%m/%Y %H:%i:%s' ) as data_inserimento_it,
                                ri.data_inserimento_ricetta,
                                ri.tipo_ricetta,
                                ri.tipo_oggetto,
                                ri.risultato_ricetta,
                                ri.extra_cartellino_ricetta,
                                ri.id_unico_risultato_ricetta,
                                ri.note_ricetta,
                                ri.nome_ricetta,
                                ri.gia_stampata,
                                IF( cr.ruolo_componente_ricetta IS NOT NULL,
                                    GROUP_CONCAT( CONCAT(cc.nome_componente,' (',cr.ruolo_componente_ricetta,')') ORDER BY cr.ordine_crafting ASC, cc.nome_componente ASC SEPARATOR '; '),
                                    GROUP_CONCAT( cc.nome_componente ORDER BY cr.ordine_crafting ASC, cc.nome_componente ASC SEPARATOR '; ')
                                ) as componenti_ricetta,
                                IF( ri.in_ravshop_ricetta = 1,
                                    ri.disponibilita_ravshop_ricetta,
                                    'Non Venduto'
                                ) as disponibilita_ravshop_ricetta,
                                ri.costo_attuale_ricetta,
                                ri.in_ravshop_ricetta,
                                ri.approvata_ricetta,
                                ri.note_pg_ricetta,
                                CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_giocatore,
                                pg.nome_personaggio,
                                SUM( cc.fcc_componente ) AS fcc_componente,
                                gi.email_giocatore,
                                IF(gi.ruoli_nome_ruolo = 'admin' OR gi.ruoli_nome_ruolo = 'admin' OR gi.ruoli_nome_ruolo = 'staff' OR gi.ruoli_nome_ruolo = 'staff',1,0) AS is_png
                        FROM ricette AS ri
                            JOIN personaggi AS pg ON pg.id_personaggio = ri.personaggi_id_personaggio
                            JOIN giocatori AS gi ON gi.email_giocatore = pg.giocatori_email_giocatore
                            JOIN componenti_ricetta AS cr ON ri.id_ricetta = cr.ricette_id_ricetta
                            JOIN componenti_crafting AS cc ON cr.componenti_crafting_id_componente = cc.id_componente
                        GROUP BY ri.id_ricetta
                      ) AS r $where $order_str";

        $risultati = $this->db->doQuery($query_ric, $params, False);
        $totale = count($risultati);
        $totFiltrati = $totale;

        if (count($risultati) > 0 && !empty($filtro) && $filtro !== "filtro_tutti") {
            $risultati = array_filter($risultati, function ($el) use ($filtro) {
                if ($filtro === "filtro_png")
                    return (int) $el["is_png"] === 1;
                else if ($filtro === "filtro_miei_png")
                    return (int) $el["is_png"] === 1 && in_array($el["personaggi_id_personaggio"], $this->session->pg_propri);

                return False;
            });
            $totFiltrati = count($risultati);
        }

        if (count($risultati) > 0)
            $risultati = array_splice($risultati, $start, $length);
        else
            $risultati = array();

        $output = array(
            "status" => "ok",
            "draw" => $draw,
            "columns" => $columns,
            "order" => $order,
            "start" => $start,
            "length" => $length,
            "search" => $search,
            "recordsTotal" => $totale,
            "recordsFiltered" => $totFiltrati,
            "data" => $risultati
        );

        return json_encode($output);
    }

    public function recuperaRicettePerRavshop($draw, $columns, $order, $start, $length, $search, $filtro = NULL, $pgid = -1)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $where = ["in_ravshop_ricetta = 1"];

        return $this->recuperaRicette($draw, $columns, $order, $start, $length, $search, $filtro, $pgid = -1, False, $where);
    }

    public function recupeRaricetteConId($ids)
    {
        UsersManager::operazionePossibile($this->session, "recuperaRicette", -1);

        $marcatori = str_repeat("?, ", count($ids) - 1) . "?";
        $query_ric = "SELECT
                        ri.*,
                        SUM(cc.fcc_componente) AS fcc_componente,
                        cc.tipo_componente AS biostruttura_sostanza
                      FROM ricette AS ri
                            LEFT JOIN componenti_ricetta AS cr ON ri.id_ricetta = cr.ricette_id_ricetta AND cr.ruolo_componente_ricetta = 'Base'
                            LEFT JOIN componenti_crafting AS cc ON cr.componenti_crafting_id_componente = cc.id_componente
                      WHERE id_ricetta IN ($marcatori)
                      GROUP BY ri.id_ricetta";
        $risultati = $this->db->doQuery($query_ric, $ids, False);

        $output = [
            "status" => "ok",
            "result" => $risultati
        ];

        return json_encode($output);
    }

    public function segnaRicetteComeStampate($ids)
    {
        UsersManager::operazionePossibile($this->session, "recuperaRicette_altri");

        $marcatori = str_repeat("?, ", count($ids) - 1) . "?";
        $query_ric = "UPDATE ricette SET gia_stampata = 1
                      WHERE id_ricetta IN ($marcatori)";
        $risultati = $this->db->doQuery($query_ric, $ids, False);

        $output = [
            "status" => "ok",
            "result" => $risultati
        ];

        return json_encode($output);
    }

    private function recuperaComponenti($draw, $columns, $order, $start, $length, $search, $where = [])
    {
        $filter = False;
        $order_str = "";
        $params = [];
        $campi = Utils::mappaArrayDiArrayAssoc($columns, "data");
        $campi[] = "IF( POSITION( 'deve dichiarare' IN LOWER( effetto_sicuro_componente ) ) > 0, TRUE, FALSE ) AS deve";
        $campi_str = implode(",", $campi);

        if (isset($search) && isset($search["value"]) && $search["value"] != "") {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where[] = " (
						id_componente LIKE :search OR
                        nome_componente LIKE :search OR
                        tipo_componente LIKE :search OR
                        costo_attuale_componente LIKE :search OR
                        costo_vecchio_componente LIKE :search OR
                        valore_param_componente LIKE :search OR
                        volume_componente LIKE :search OR
                        energia_componente LIKE :search OR
                        fattore_legame_componente LIKE :search OR
                        curativo_primario_componente LIKE :search OR
                        psicotropo_primario_componente LIKE :search OR
                        tossico_primario_componente LIKE :search OR
                        curativo_secondario_componente LIKE :search OR
                        psicotropo_secondario_componente LIKE :search OR
                        tossico_secondario_componente LIKE :search OR
                        possibilita_dipendeza_componente LIKE :search OR
                        descrizione_componente LIKE :search
					  )";
        }

        if (isset($order) && !empty($order) && count($order) > 0) {
            $sorting = array();
            foreach ($order as $elem)
                $sorting[] = $columns[$elem["column"]]["data"] . " " . $elem["dir"];

            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_ric = "SELECT $campi_str FROM componenti_crafting $where $order_str";

        $risultati = $this->db->doQuery($query_ric, $params, False);
        $totale = count($risultati);

        if (count($risultati) > 0)
            $risultati = array_splice($risultati, $start, $length);
        else
            $risultati = array();

        $output = array(
            "status" => "ok",
            "draw" => $draw,
            "columns" => $columns,
            "order" => $order,
            "start" => $start,
            "length" => $length,
            "search" => $search,
            "recordsTotal" => $totale,
            "recordsFiltered" => $filter ? count($risultati) : $totale,
            "data" => $risultati
        );

        return json_encode($output);
    }

    public function recuperaComponentiAvanzato($draw, $columns, $order, $start, $length, $search, $tipo_crafting)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $columns[] = ["data" => "costo_vecchio_componente"];
        $columns[] = ["data" => "volume_componente"];
        $columns[] = ["data" => "energia_componente"];
        $columns[] = ["data" => "tipo_componente"];
        $columns[] = ["data" => "id_componente"];
        $columns[] = ["data" => "nome_componente"];
        $columns[] = ["data" => "descrizione_componente"];
        $columns[] = ["data" => "tipo_applicativo_componente"];
        $columns[] = ["data" => "visibile_ravshop_componente"];

        return $this->recuperaComponenti($draw, $columns, $order, $start, $length, $search, ["tipo_crafting_componente = '$tipo_crafting'"]);
    }

    public function recuperaComponentiBase($draw, $columns, $order, $start, $length, $search, $tipo_crafting)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        if (is_array($order) && count($order) > 0)
            $order_field = $columns[$order[0]["column"]]["data"];

        $columns[] = ["data" => "costo_vecchio_componente"];
        $columns[] = ["data" => "volume_componente"];
        $columns[] = ["data" => "energia_componente"];
        $columns[] = ["data" => "tipo_componente"];
        $columns[] = ["data" => "id_componente"];
        $columns[] = ["data" => "nome_componente"];
        $columns[] = ["data" => "descrizione_componente"];
        $columns[] = ["data" => "tipo_applicativo_componente"];
        $columns[] = ["data" => "effetto_sicuro_componente"];

        $campi_permessi = [
            "id_componente",
            "tipo_componente",
            "descrizione_componente",
            "costo_attuale_componente",
            "nome_componente",
            "costo_vecchio_componente",
            "valore_param_componente",
            "volume_componente",
            "energia_componente",
            "curativo_primario_componente",
            "tossico_primario_componente",
            "psicotropo_primario_componente",
            "curativo_secondario_componente",
            "psicotropo_secondario_componente",
            "tossico_secondario_componente",
            "possibilita_dipendeza_componente",
            "effetto_sicuro_componente",
            "tipo_applicativo_componente"
        ];
        $campi = Utils::filtraArrayDiArrayAssoc($columns, "data", $campi_permessi);

        if (isset($order_field))
            $order[0]["column"] = array_search($order_field, array_column($campi, 'data'));

        return $this->recuperaComponenti($draw, $campi, $order, $start, $length, $search, ["tipo_crafting_componente = '$tipo_crafting'", "visibile_ravshop_componente = '1'"]);
    }

    public function recuperaComponentiConId($ids)
    {
        UsersManager::operazionePossibile($this->session, "recuperaComponentiBase");

        $marcatori = str_repeat("?, ", count($ids) - 1) . "?";
        $sql = "SELECT   id_componente
                        ,nome_componente
                        ,tipo_crafting_componente
                        ,tipo_componente
                        ,volume_componente
                        ,energia_componente
                        ,curativo_primario_componente
                        ,psicotropo_primario_componente
                        ,tossico_primario_componente
                        ,curativo_secondario_componente
                        ,psicotropo_secondario_componente
                        ,tossico_secondario_componente
                        ,possibilita_dipendeza_componente
                        ,descrizione_componente
                 FROM componenti_crafting WHERE id_componente IN ($marcatori)";
        $risultati = $this->db->doQuery($sql, $ids, False);

        $output = [
            "status" => "ok",
            "result" => $risultati
        ];

        return json_encode($output);
    }

    private function controllaErroriCartellino($form_obj)
    {
        $errori = [];

        if (!isset($form_obj["id_componente"]) || $form_obj["id_componente"] === "")
            $errori[] = "L'ID del componente non pu&ograve; essere vuoto.";
        if (!isset($form_obj["nome_componente"]) || $form_obj["nome_componente"] === "")
            $errori[] = "Il nome del componente non pu&ograve; essere vuota.";

        if (count($errori) > 0)
            throw new APIException("Sono stati trovati errori durante l'invio dei dati del componente:<br><ul><li>" . implode("</li><li>", $errori) . "</li></ul>");
    }

    public function inserisciComponente($params)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaErroriCartellino($params);

        unset($params["old_costo_attuale_componente"]);

        $campi  = implode(", ", array_keys($params));
        $marchi = str_repeat("?,", count(array_keys($params)) - 1) . "?";
        $valori = array_values($params);

        $query_insert  = "INSERT INTO componenti_crafting ($campi) VALUES ($marchi)";
        $id_cartellino = $this->db->doQuery($query_insert, $valori, False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function modificaGruppoComponenti($idNames, $modifiche)
    {
        $SEPARATOR = "££";
        $errors = [];

        foreach ($idNames as $idName) {
            $split = explode($SEPARATOR, $idName);
            $ret = $this->modificaComponente($split[0], $modifiche, TRUE);
            $status = json_decode($ret, true);

            if ($status["status"] !== "ok") {
                $errors[] = $split[1] . " (" . $split[0] . ")";
            }
        }

        if (count($errors) > 0) {
            throw new APIException(
                "Non &egrave; stato possibile modificare i seguenti componenti:<br>" . (implode(", ", $errors)),
                APIException::$GENERIC_ERROR
            );
        }

        return json_encode(["status" => "ok"]);
    }

    public function modificaComponente($id, $modifiche, $is_bulk = FALSE)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);
        $to_update = [];
        $valori = [];

        if (!$is_bulk)
            $this->controllaErroriCartellino($modifiche);

        foreach ($modifiche as $campo => $valore) {
            if ($campo === "old_costo_attuale_componente" && $valore !== $modifiche["costo_attuale_componente"]) {
                $to_update[] = "costo_vecchio_componente = ?";
                $valori[] = $valore;
            } else if ($campo === "tipo_applicativo_componente" && is_array($valore) && in_array("nessuna", $valore)) {
                throw new APIException("Non &egrave; possibile selezionare 'nessuna' insieme ad altre compatibilit&agrave;.", APIException::$GENERIC_ERROR);
            } else if ($campo === "tipo_applicativo_componente" && $valore === "nessuna") {
                $to_update[] = "$campo = ''";
            } else if ($campo !== "old_costo_attuale_componente") {
                $val = $valore === "NULL" ? "NULL" : "?";

                if ($valore !== "NULL") {
                    if (is_array($valore))
                        $valore = implode(",", $valore);

                    $valori[] = $valore;
                }

                $to_update[] = "$campo = $val";
            }
        }

        if (count($to_update) === 0)
            throw new APIException("Non &egrave; possibile eseguire l'operazione.", APIException::$GENERIC_ERROR);

        $to_update = implode(", ", $to_update);
        $valori[] = $id;

        $query_bg = "UPDATE componenti_crafting SET $to_update WHERE id_componente = ?";
        $this->db->doQuery($query_bg, $valori, False);

        $output = [
            "status" => "ok"
        ];

        return json_encode($output);
    }

    public function eliminaComponente($id)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_ricette = "SELECT ricette_id_ricetta FROM componenti_ricetta WHERE componenti_crafting_id_componente = ?";
        $id_ricette = $this->db->doQuery($query_ricette, [$id], False);

        if (isset($id_ricette) && count($id_ricette) > 0) {
            $values = array_column($id_ricette, "ricette_id_ricetta");
            $marks = str_repeat("?,", count($values) - 1) . "?";

            $query_del_ricette = "DELETE FROM ricette WHERE id_ricetta IN ( $marks )";
            $this->db->doQuery($query_del_ricette, $values, False);
        }

        $query_comps = "DELETE FROM componenti_crafting WHERE id_componente = ?";
        $this->db->doQuery($query_comps, [$id], False);

        $output = [
            "status" => "ok"
        ];

        return json_encode($output);
    }
}
