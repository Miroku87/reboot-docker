<?php

$path = $_SERVER['DOCUMENT_ROOT']."/";
include_once($path."classes/APIException.class.php");
include_once($path."classes/UsersManager.class.php");
include_once($path."classes/DatabaseBridge.class.php");
include_once($path."classes/SessionManager.class.php");
include_once($path."classes/Utils.class.php");
include_once($path."config/constants.php");

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
    {
    }

    private function controllaErroriCartellino( $form_obj )
    {
        $errori = [];

        if( $form_obj["titolo_cartellino"] === ""  )
            $errori[] = "Il titolo del cartellino non pu&ograve; essere vuoto.";
        if( $form_obj["descrizione_cartellino"] === ""  )
            $errori[] = "La descrizione del cartellino non pu&ograve; essere vuota.";

        if( count($errori) > 0 )
            throw new APIException("Sono stati trovati errori durante l'invio dei dati del cartellino:<br><ul><li>".implode("</li><li>",$errori)."</li></ul>");
    }

    public function creaCartellino( $params, $etichette = NULL, $trama = NULL )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $this->controllaErroriCartellino( $params );

        if( $params["approvato_cartellino"] && !UsersManager::operazionePossibile( $this->session, "approvaCartellino" ) )
            throw new APIException("Non hai i permessi per approvare i cartellini.");

        if( isset($params["nome_modello_cartellino"]) )
        {
            $query_check_modello = "SELECT id_cartellino FROM cartellini WHERE nome_modello_cartellino = ?";
            $modello = $this->db->doQuery($query_check_modello,[$params["nome_modello_cartellino"]],False);

            if( isset($modello) && count($modello) > 0 )
                throw new APIException("Un modello con il nome <strong>".$params["nome_modello_cartellino"]."</strong> esiste gi&agrave;. Nel caso si voglia modificarlo, modificare direttamente il cartellino con ID ".$modello[0]["id_cartellino"].".");
        }

        if( isset($params["costo_attuale_ravshop_cartellino"]) )
            $params["costo_vecchio_ravshop_cartellino"] = floor((int)$params["costo_attuale_ravshop_cartellino"] * rand(0.25, 0.75) );

        if( UsersManager::controllaPermessi( $this->session, ["approvaCartellino"] ) )
            $params["approvaCartellino"] = 1;

        $params = array_map($params, Utils::mappaCheckbox);
        $campi = implode(", ", array_keys($params) );
        $marchi = str_repeat("?,", count(array_keys($params)) - 1 )."?";
        $valori = array_values($params);

        $query_insert = "INSERT INTO cartellini ($campi) VALUES ($marchi)";
        $id_cartellino = $this->db->doQuery($query_insert, $valori, False);

        if( isset($etichette) )
            $this->associazioneCartellinoEtichette($id_cartellino, explode(",",$etichette));

        if( isset($trama) )
            $this->associazioneCartellinoTrama($trama, $id_cartellino);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function modificaCartellino( $id, $params, $etichette = NULL )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $this->controllaErroriCartellino( $params );

        if( $params["approvato_cartellino"] && !UsersManager::operazionePossibile( $this->session, "approvaCartellino" ) )
            throw new APIException("Non hai i permessi per approvare i cartellini.");

        if( isset($params["old_costo_attuale_ravshop_cartellino"]) && $params["costo_attuale_ravshop_cartellino"] !== $params["old_costo_attuale_ravshop_cartellino"] )
            $params["costo_vecchio_ravshop_cartellino"] = $params["old_costo_attuale_ravshop_cartellino"];

        if( isset($params["nome_modello_cartellino"]) )
        {
            $query_check_modello = "SELECT id_cartellino FROM cartellini WHERE nome_modello_cartellino = ?";
            $modello = $this->db->doQuery($query_check_modello,[$params["nome_modello_cartellino"]],False);

            if( isset($modello) && count($modello) > 0 && $modello[0]["id_cartellino"] !== $id )
                throw new APIException("Un modello con il nome <strong>".$params["nome_modello_cartellino"]."</strong> esiste gi&agrave;. Nel caso si voglia modificarlo, modificare direttamente il cartellino con ID ".$modello[0]["id_cartellino"].".");
        }

        $to_update = [];
        foreach( $params as $k => $p )
            $to_update[] = $k." = ?";

        $campi = implode(", ", $to_update );
        $valori = array_values($params);
        $valori[] = $id;

        $query_update = "UPDATE cartellini SET $campi WHERE id_cartellino = ?";
        $this->db->doQuery($query_update, $valori, False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function eliminaCartellino( $id )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
        //TODO: controllare trame associate nel frontend
        $query_del = "DELETE FROM cartellini WHERE id_cartellino = ?";
        $this->db->doQuery($query_update, [$id], False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function associazioneCartellinoTrama($id_trama, $id_cartellino)
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

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
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $query_etichette = "INSERT INTO cartellino_has_etichette (cartellini_id_cartellino, etichetta) VALUES (?,?)";

        $params = array_map( function($tag) use ($id_cartellino)
        {
            return [$id_cartellino, $tag];
        }, $etichette);

        $this->db->doMultipleManipulations($query_etichette, $params, False);

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function recuperaModelli($id_trama, $id_cartellino)
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $query_modelli = "SELECT * FROM cartellini WHERE nome_modello_cartellino IS NOT NULL";
        $modelli = $this->db->doQuery($query_modelli, [], False);

        $result = [];
        if( isset($modelli) && count($modelli) > 0 )
            $result = $modelli;

        $output = [
            "status" => "ok",
            "result" => $result
        ];

        return json_encode($output);
    }

    public function recuperaCartellini($draw, $columns, $order, $start, $length, $search, $where = [])
    {
        $filter = False;
        $order_str = "";
        $params = [];
        $campi = array_column($columns, "data");
        $campi = array_filter($campi,function($el){ return preg_match("/^\D+$/",$el); });
        $campi_str = implode(", ", $campi);

        if (isset($search) && isset($search["value"]) && $search["value"] != "")
        {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $campi_where = implode(" LIKE :search OR ",$campi)." LIKE :search";
            $where[] = " ($campi_where)";
        }

        if (isset($order) && !empty($order) && count($order) > 0)
        {
            $sorting = array();
            foreach ($order as $elem)
                $sorting[] = $columns[$elem["column"]]["data"] . " " . $elem["dir"];

            $order_str = "ORDER BY " . implode($sorting, ",");
        }

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_ric = "SELECT $campi_str FROM cartellini $where $order_str";

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

}
