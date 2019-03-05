<?php

$path = $_SERVER['DOCUMENT_ROOT']."/reboot-live-api/src/";
include_once($path."classes/APIException.class.php");
include_once($path."classes/UsersManager.class.php");
include_once($path."classes/DatabaseBridge.class.php");
include_once($path."classes/Mailer.class.php");
include_once($path."classes/SessionManager.class.php");
include_once($path."classes/Utils.class.php");
include_once($path."config/constants.php");

class GrantsManager
{
    protected $db;
    protected $session;
    protected $mailer;
    
    public function __construct()
    {
        $this->session = SessionManager::getInstance();
        $this->db      = new DatabaseBridge();
        $this->mailer  = new Mailer();
    }
    
    public function __destruct()
    {
    }
    
    public function creaRuolo( $nome )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
    
        $query_check = "SELECT nome_ruolo FROM ruoli WHERE LOWER(nome_ruolo) = :ruolo";
        $result = $this->db->doQuery($query_check,[":ruolo" => strtolower($nome)],False);
        
        if( isset($result) && count($result) > 0 )
            throw new APIException("Questo ruolo esiste gi&agrave;. Inserirne uno differente.");
        
        $query_ruoli = "INSERT INTO ruoli VALUES (:ruolo)";
        $this->db->doQuery($query_ruoli,[":ruolo" => $nome],False);
    
        $output = [
            "status" => "ok",
            "result" => True
        ];
    
        return json_encode($output);
    }
    
    public function eliminaRuolo( $nome, $sostituto )
    {
        global $RUOLO_ADMIN;
        
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
        
        if( $nome === $RUOLO_ADMIN )
            throw new APIException("Non &egrave; possibile eliminare o modificare il ruolo di amministratore.");
    
        $query_check = "SELECT nome_ruolo FROM ruoli WHERE nome_ruolo = :ruolo";
        $result = $this->db->doQuery($query_check,[":ruolo" => $nome],False);
    
        if( !isset($result) || count($result) === 0 )
            throw new APIException("Questo ruolo non esiste.");
    
        $query_update = "UPDATE giocatori SET ruoli_nome_ruolo = :sostituto WHERE ruoli_nome_ruolo = :ruolo";
        $this->db->doQuery($query_update,[":sostituto" => $sostituto, ":ruolo" => $nome],False);
        
        $query_ruoli = "DELETE FROM ruoli WHERE nome_ruolo = :ruolo";
        $this->db->doQuery($query_ruoli,[":ruolo" => $nome],False);
    
        $output = [
            "status" => "ok",
            "result" => True
        ];
    
        return json_encode($output);
    }
    
    public function associaPermessi( $ruolo, $grants = [] )
    {
        global $DB_ERR_DELIMITATORE;
        global $MYSQL_DUPLICATE_ENTRY_ERRCODE;
        
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
        
        $query_perm = "SELECT grants_nome_grant FROM ruoli_has_grants WHERE ruoli_nome_ruolo = :ruolo";
        $posseduti  = $this->db->doQuery($query_perm, [ ":ruolo" => $ruolo ], False);
        $posseduti  = !isset($posseduti) || count($posseduti) === 0 ? [] : Utils::mappaArrayDiArrayAssoc( $posseduti, "grants_nome_grant" );
    
        $query_tutti = "SELECT nome_grant FROM grants";
        $tutti       = $this->db->doQuery($query_tutti, [ ], False);
        $tutti       = Utils::mappaArrayDiArrayAssoc( $tutti, "nome_grant" );
        
        $params_insert = [];
        $params_delete = [];
        
        foreach ( $tutti as $p )
        {
            if ( isset($grants[$p]) && $grants[$p] === "on" && !in_array($p,$posseduti) )
                $params_insert[] = [":ruolo" => $ruolo, ":grnt" => $p];
            else if ( !isset($grants[$p]) && in_array($p,$posseduti) )
                $params_delete[] = [":ruolo" => $ruolo, ":grnt" => $p];
        }
        
        $query_insert = "INSERT INTO ruoli_has_grants VALUES (:ruolo, :grnt)";
        $query_delete = "DELETE FROM ruoli_has_grants WHERE ruoli_nome_ruolo = :ruolo AND grants_nome_grant = :grnt";
    
        try
        {
            if(count($params_insert) > 0) $this->db->doMultipleManipulations($query_insert, $params_insert, False);
            if(count($params_delete) > 0) $this->db->doMultipleManipulations($query_delete, $params_delete, False);
        }
        catch (Exception $e)
        {
            $code = explode($DB_ERR_DELIMITATORE, $e->getMessage())[0];
            
            if( $code === $MYSQL_DUPLICATE_ENTRY_ERRCODE )
                throw new APIException("Impossibile inserire due volte la stessa coppia ruolo -> permesso.", APIException::$DATABASE_ERROR);
            else
                throw $e;
        }
    
        $output = [
            "status" => "ok",
            "result" => True
        ];
    
        return json_encode($output);
    }
    
    public function recuperaRuoli()
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
    
        $query_ruoli = "SELECT ru.nome_ruolo, COUNT(rhg.grants_nome_grant) AS numero_grants
                            FROM ruoli AS ru
                            LEFT OUTER JOIN ruoli_has_grants AS rhg ON rhg.ruoli_nome_ruolo = ru.nome_ruolo
                            GROUP BY ru.nome_ruolo ORDER BY ru.nome_ruolo ASC";
        $ruoli = $this->db->doQuery($query_ruoli,[],False);
        
        $output = [
            "status" => "ok",
            "result" => $ruoli
        ];
        
        return json_encode($output);
    }
    
    public function recuperaListaPermessi()
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
    
        $query_grants = "SELECT nome_grant, descrizione_grant FROM grants";
        $grants = $this->db->doQuery($query_grants,[],False);
    
        $output = [
            "status" => "ok",
            "result" => $grants
        ];
    
        return json_encode($output);
    }
    
    public function recuperaPermessiDeiRuoli()
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
    
        $query_ruoli = "SELECT * FROM ruoli_has_grants";
        $ruoli = $this->db->doQuery($query_ruoli,[],False);
    
        $result = [];
        
        if( count($ruoli) > 0 )
        {
            foreach ($ruoli as $r)
            {
                if( !isset($result[ $r["ruoli_nome_ruolo"] ]) )
                    $result[ $r["ruoli_nome_ruolo"] ] = [];
    
                $result[ $r["ruoli_nome_ruolo"] ][] = $r["grants_nome_grant"];
            }
        }
        
        $output = [
            "status" => "ok",
            "result" => $result
        ];
    
        return json_encode($output);
    }

}