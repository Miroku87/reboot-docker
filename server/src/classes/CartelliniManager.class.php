<?php

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class CartelliniManager
{
    protected $db;
    protected $session;

    public function __construct()
    {
        $this->session = SessionManager::getInstance();
        $this->db      = new DatabaseBridge();
    }

    public function __destruct()
    { }

    private function controllaErroriCartellino($form_obj)
    {
        $errori = [];

        if (!isset($form_obj["titolo_cartellino"]) || $form_obj["titolo_cartellino"] === "")
            $errori[] = "Il titolo del cartellino non pu&ograve; essere vuoto.";
        if (!isset($form_obj["descrizione_cartellino"]) || $form_obj["descrizione_cartellino"] === "")
            $errori[] = "La descrizione del cartellino non pu&ograve; essere vuota.";

        if (count($errori) > 0)
            throw new APIException("Sono stati trovati errori durante l'invio dei dati del cartellino:<br><ul><li>" . implode("</li><li>", $errori) . "</li></ul>");
    }

    public function creaCartellino($params, $etichette = NULL, $trama = NULL)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaErroriCartellino($params);

        if (isset($params["approvato_cartellino"]) && $params["approvato_cartellino"] == 1 && !UsersManager::controllaPermessi($this->session, ["approvaCartellino"]))
            throw new APIException("Non hai i permessi per approvare i cartellini.");

        if (isset($params["nome_modello_cartellino"])) {
            $query_check_modello = "SELECT id_cartellino FROM cartellini WHERE nome_modello_cartellino = ?";
            $modello             = $this->db->doQuery($query_check_modello, [$params["nome_modello_cartellino"]], False);

            if (isset($modello) && count($modello) > 0)
                throw new APIException("Un modello con il nome <strong>" . $params["nome_modello_cartellino"] . "</strong> esiste gi&agrave;. Nel caso si voglia modificarlo, modificare direttamente il cartellino con ID " . $modello[0]["id_cartellino"] . ".");
        }

        if (isset($params["costo_attuale_ravshop_cartellino"]))
            $params["costo_vecchio_ravshop_cartellino"] = floor((int) $params["costo_attuale_ravshop_cartellino"] * rand(0.25, 0.75));

        //$params["approvato_cartellino"]   = UsersManager::controllaPermessi($this->session, ["approvaCartellino"]) ? 1 : 0;
        $params["titolo_cartellino"]      = nl2br($params["titolo_cartellino"]);
        $params["descrizione_cartellino"] = nl2br($params["descrizione_cartellino"]);
        $params["creatore_cartellino"]    = $this->session->email_giocatore;
        $params["icona_cartellino"]       = !isset($params["icona_cartellino"]) ? "NULL" : $params["icona_cartellino"];

        $campi  = implode(", ", array_keys($params));
        $marchi = ""; //str_repeat("?,", count(array_keys($params)) - 1) . "?";
        $valori = []; //array_values($params);

        foreach ($params as $k => $v) {
            $marchi .= strtoupper($v) !== "NULL" ? "?," : "NULL,";

            if (strtoupper($v) !== "NULL")
                $valori[] = $v;
        }

        $marchi = substr($marchi, 0, strlen($marchi) - 1);

        $query_insert  = "INSERT INTO cartellini ($campi) VALUES ($marchi)";
        $id_cartellino = $this->db->doQuery($query_insert, $valori, False);

        if (isset($etichette))
            $this->associazioneCartellinoEtichette($id_cartellino, explode(",", $etichette));

        if (isset($trama))
            $this->associazioneCartellinoTrama($trama, $id_cartellino);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function modificaCartellino($id, $params, $etichette = NULL, $old_etichette = NULL)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaErroriCartellino($params);

        if (isset($params["approvato_cartellino"]) && $params["approvato_cartellino"] == 1 && !UsersManager::controllaPermessi($this->session, ["approvaCartellino"]))
            throw new APIException("Non hai i permessi per approvare i cartellini.");

        if (
            isset($params["old_costo_attuale_ravshop_cartellino"]) &&
            $params["costo_attuale_ravshop_cartellino"] != $params["old_costo_attuale_ravshop_cartellino"]
        ) {
            $params["costo_vecchio_ravshop_cartellino"] = $params["old_costo_attuale_ravshop_cartellino"];
        }

        unset($params["old_costo_attuale_ravshop_cartellino"]);

        if (isset($params["nome_modello_cartellino"])) {
            $query_check_modello = "SELECT id_cartellino FROM cartellini WHERE nome_modello_cartellino = ?";
            $modello             = $this->db->doQuery($query_check_modello, [$params["nome_modello_cartellino"]], False);

            if (isset($modello) && count($modello) > 0 && $modello[0]["id_cartellino"] !== $id)
                throw new APIException("Un modello con il nome <strong>" . $params["nome_modello_cartellino"] . "</strong> esiste gi&agrave;. Nel caso si voglia modificarlo, modificare direttamente il cartellino con ID " . $modello[0]["id_cartellino"] . ".");
        }

        //$params["approvato_cartellino"]   = isset($params["approvato_cartellino"]) && UsersManager::controllaPermessi($this->session, ["approvaCartellino"]) ? 1 : 0;
        $params["titolo_cartellino"]      = nl2br($params["titolo_cartellino"]);
        $params["descrizione_cartellino"] = nl2br($params["descrizione_cartellino"]);
        $params["icona_cartellino"]       = !isset($params["icona_cartellino"]) ? "NULL" : $params["icona_cartellino"];

        $to_update = [];
        foreach ($params as $k => $p)
            $to_update[] =  $k . " = " . (strtoupper($p) !== "NULL" ? "?" : "NULL");

        $campi    = implode(", ", $to_update);

        foreach ($params as $k => $p)
            if (strtoupper($p) === "NULL")
                unset($params[$k]);

        $valori   = array_values($params);
        $valori[] = $id;

        $query_update = "UPDATE cartellini SET $campi WHERE id_cartellino = ?";
        $this->db->doQuery($query_update, $valori, False);

        if (isset($etichette)) {
            if (isset($old_etichette)) {
                $et_arr = explode(",", $etichette);
                $et_old_arr = explode(",", $old_etichette);

                $rimosse = array_diff($et_old_arr, $et_arr);
                $aggiunte = array_diff($et_arr, $et_old_arr);

                if (count($rimosse) > 0)
                    $this->disassociazioneCartellinoEtichette($id, $rimosse);
            } else
                $aggiunte = explode(",", $etichette);

            if (count($aggiunte) > 0)
                $this->associazioneCartellinoEtichette($id, $aggiunte);
        }

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function eliminaCartellino($id)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_del = "DELETE FROM cartellini WHERE id_cartellino = ?";
        $this->db->doQuery($query_del, [$id], False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function associazioneCartellinoTrama($id_trama, $id_cartellino)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_trama = "INSERT INTO trame_has_cartellini (trame_id_trama, cartellini_id_cartellino) VALUES (?,?)";
        $this->db->doQuery($query_trama, [$id_trama, $id_cartellino], False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function associazioneCartellinoEtichette($id_cartellino, $etichette)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_etichette = "INSERT INTO cartellino_has_etichette (cartellini_id_cartellino, etichetta) VALUES (?,?)";

        $params = array_map(function ($tag) use ($id_cartellino) {
            return [$id_cartellino, $tag];
        }, $etichette);

        $this->db->doMultipleManipulations($query_etichette, array_values($params), False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function disassociazioneCartellinoEtichette($id_cartellino, $etichette)
    {
        UsersManager::operazionePossibile($this->session, "associazioneCartellinoEtichette");

        $query_etichette = "DELETE FROM cartellino_has_etichette WHERE cartellini_id_cartellino = ? AND etichetta = ?";

        $params = array_map(function ($tag) use ($id_cartellino) {
            return [$id_cartellino, $tag];
        }, $etichette);

        $this->db->doMultipleManipulations($query_etichette, array_values($params), False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function recuperaModelli()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_modelli = "SELECT * FROM cartellini WHERE nome_modello_cartellino IS NOT NULL";
        $modelli       = $this->db->doQuery($query_modelli, [], False);

        $result = [];
        if (isset($modelli) && count($modelli) > 0)
            $result = $modelli;

        $output = [
            "status" => "ok",
            "result" => $result
        ];

        return json_encode($output);
    }

    public function recuperaTagsUnici()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_tags = "SELECT DISTINCT etichetta FROM (
                            SELECT etichetta FROM cartellino_has_etichette AS che
                            UNION ALL
                            SELECT etichetta FROM trame_has_etichette AS the
                          ) AS u";
        $tags = $this->db->doQuery($query_tags, [], False);

        $result = [];
        if (isset($tags) && count($tags) > 0)
            $result = $tags;

        return json_encode(array_column($result, "etichetta"));
    }

    public function recuperaCartellini($draw, $columns, $order, $start, $length, $search, $etichette = [], $where = [])
    {
        $filter    = False;
        $order_str = "";
        $params    = [];
        $campi     = array_column($columns, "data");
        $campi     = array_filter($campi, function ($el) {
            return preg_match("/^\D+$/", $el);
        });

        if (($index = array_search("nome_creatore_cartellino", $campi)) !== False)
            $campi[$index]  = "CONCAT( gi.nome_giocatore, ' ', gi.cognome_giocatore ) AS nome_creatore_cartellino";

        if (isset($search) && isset($search["value"]) && $search["value"] != "") {
            $filter              = True;
            $params[":search"]   = "%$search[value]%";
            $campi_search        = array_filter($campi, function ($el) {
                return preg_replace("/^(.*?) AS.*$/i", "${1}", $el);
            });
            $campi_where         = implode(" LIKE :search OR ", $campi_search) . " LIKE :search";
            $where[]             = " ($campi_where)";
        }

        if (isset($order) && !empty($order) && count($order) > 0) {
            $sorting = array();
            foreach ($order as $elem)
                $sorting[] = $columns[$elem["column"]]["data"] . " " . $elem["dir"];

            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        $campi[]   = "GROUP_CONCAT( che.etichetta SEPARATOR ',' ) AS etichette_cartellino";
        //$campi[]   = "CONCAT( gi.nome_giocatore, ' ', gi.cognome_giocatore ) AS nome_creatore_cartellino";
        $campi_str = implode(", ", $campi);

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_ric = "SELECT $campi_str FROM cartellini AS ca
                        LEFT JOIN cartellino_has_etichette AS che ON ca.id_cartellino = che.cartellini_id_cartellino
                        JOIN giocatori AS gi ON gi.email_giocatore = ca.creatore_cartellino
                      $where
                      GROUP BY ca.id_cartellino
                      $order_str";

        $risultati_tot = $this->db->doQuery($query_ric, $params, False);
        $totale        = count($risultati_tot);
        if (count($etichette) > 0) {
            $risultati_tot = array_filter($risultati_tot, function ($el) use ($etichette) {
                if (!$el["etichette_cartellino"])
                    return false;

                $etichette_cartellino = explode(",", $el["etichette_cartellino"]);
                $presenti             = array_intersect($etichette, $etichette_cartellino);
                // Se tutti i tag cercati sono stati trovati all'interno dei tag del cartellino
                // questo può essere lasciato nella tabella
                return count($presenti) === count($etichette);
            });

            $recordsFiltered = count($risultati_tot);
        }

        if (count($risultati_tot) > 0)
            $pagina = array_splice($risultati_tot, $start, $length);
        else
            $pagina = array();

        $output = array(
            "status"          => "ok",
            "draw"            => $draw,
            "columns"         => $columns,
            "order"           => $order,
            "start"           => $start,
            "length"          => $length,
            "search"          => $search,
            "recordsTotal"    => $totale,
            "recordsFiltered" => isset($recordsFiltered) ? $recordsFiltered : $totale,
            "data"            => $pagina
        );

        return json_encode($output);
    }

    public function recuperaCartelliniConId($ids)
    {
        $colonne = [
            ["data" => "id_cartellino"],
            ["data" => "data_creazione_cartellino"],
            ["data" => "tipo_cartellino"],
            ["data" => "titolo_cartellino"],
            ["data" => "descrizione_cartellino"],
            ["data" => "icona_cartellino"],
            ["data" => "testata_cartellino"],
            ["data" => "piepagina_cartellino"],
            ["data" => "costo_attuale_ravshop_cartellino"],
            ["data" => "costo_vecchio_ravshop_cartellino"],
            ["data" => "approvato_cartellino"],
            ["data" => "attenzione_cartellino"],
            ["data" => "nome_modello_cartellino"]
        ];
        $where = ["id_cartellino IN (" . implode(", ", $ids) . ")"];
        return $this->recuperaCartellini(NULL, $colonne, NULL, 0, 9999999, NULL, NULL, $where);
    }
}
