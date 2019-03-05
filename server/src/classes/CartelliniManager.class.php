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

        if( isset($params["nome_modello_cartellino"]) )
        {
            $query_check_modello = "SELECT id_cartellino FROM cartellini WHERE nome_modello_cartellino = ?";
            $modello = $this->db->doQuery($query_check_modello,[$params["nome_modello_cartellino"]],False);

            if( isset($modello) && count($modello) > 0 )
                throw new APIException("Un modello con il nome <strong>".$params["nome_modello_cartellino"]."</strong> esiste gi&agrave;. Nel caso si voglia modificarlo, modificare direttamente il cartellino #".$modello[0]["id_cartellino"].".");
        }
        
        if( isset($params["costo_attuale_ravshop_cartellino"]) )
            $params["costo_vecchio_ravshop_cartellino"] = floor((int)$params["costo_attuale_ravshop_cartellino"] * rand(0.25, 0.75) );

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
        $to_update = [];
        
        if( isset($params["old_costo_attuale_ravshop_cartellino"]) && $params["costo_attuale_ravshop_cartellino"] !== $params["old_costo_attuale_ravshop_cartellino"] )
            $params["costo_vecchio_ravshop_cartellino"] = $params["old_costo_attuale_ravshop_cartellino"];

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

    public function associazioneCartellinoTrama($id_trama, $id_cartellino)
    {
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

}
