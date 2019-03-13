<?php
$path = $_SERVER['DOCUMENT_ROOT']."/";
include_once($path."classes/APIException.class.php");
include_once($path."classes/DatabaseBridge.class.php");
include_once($path."classes/Mailer.class.php");
include_once($path."classes/SessionManager.class.php");
include_once($path."classes/Utils.class.php");
include_once($path."config/constants.php");

class UsersManager
{
	protected $db;
	protected $grants;
	protected $session;
    protected $idev_in_corso;

	public function __construct( $idev_in_corso = NULL )
	{
        $this->idev_in_corso = $idev_in_corso;
		$this->session = SessionManager::getInstance();
		$this->db      = new DatabaseBridge();
		$this->mailer  = new Mailer();
	}

	public function __destruct()
	{
	}

	public function __toString()
    {
        return "[UsersManager]";
    }

    static function controllaPermessi( $sessione, $permessi, $tutti = True )
    {
        foreach ($permessi as $p)
        {
            if( in_array($p, $sessione->permessi_giocatore) && !$tutti )
                return True;
            else if ( !in_array($p, $sessione->permessi_giocatore) && $tutti )
                return False;
        }

        if( $tutti )
            return True;
        else
            return False;
    }

    static function controllaLogin( $sessione )
    {
        if( !isset($sessione->permessi_giocatore) )
            throw new APIException( "Devi essere loggato per compiere questa operazione.", APIException::$LOGIN_ERROR );
    }

    static function operazionePossibile( $sessione, $funzione, $id = NULL, $throw_exception = True )
    {
        global $TIPO_GRANT_PG_PROPRIO;
        global $TIPO_GRANT_PG_ALTRI;

        $tipo_grant = "";

        self::controllaLogin( $sessione );

        if( isset( $id ) && in_array($id, $sessione->pg_propri) )
            $tipo_grant = in_array($id, $sessione->pg_propri) ? $TIPO_GRANT_PG_PROPRIO : $TIPO_GRANT_PG_ALTRI;
        else if ( isset( $id ) && !in_array($id, $sessione->pg_propri) )
            $tipo_grant = $id === $sessione->email_giocatore ? $TIPO_GRANT_PG_PROPRIO : $TIPO_GRANT_PG_ALTRI;

        if( $throw_exception && !in_array( $funzione.$tipo_grant, $sessione->permessi_giocatore ) )
            throw new APIException( "Non hai i permessi per compiere questa operazione: <code>$funzione$tipo_grant</code>", APIException::$GRANTS_ERROR );
        else
            return in_array( $funzione.$tipo_grant, $sessione->permessi_giocatore );
    }

	private function controllaInputPwd( $pass1, $pass2 )
    {
        $errors = "";

        if ( $pass1 === "" || Utils::soloSpazi($pass1) )
            $errors .= "Il primo campo Password non pu&ograve; essere vuoto.<br>";

        if ( $pass2 === "" || Utils::soloSpazi($pass2) )
            $errors .= "Il secondo campo Password non pu&ograve; essere vuoto.<br>";

        if( $pass1 !== "" && !Utils::soloSpazi($pass1) &&
            $pass2 !== "" && !Utils::soloSpazi($pass2) &&
            $pass1 !== $pass2
        )
            $errors .= "Le password inserite non combaciano.<br>";

        return $errors;
    }

	private function controllaDatiRegistrazione( $nome, $cognome, $note, $mail, $pass1, $pass2 )
	{
		$errors = "";

		if ( $nome === "" || Utils::soloSpazi($nome) )
			$errors .= "Il campo Nome non pu&ograve; essere vuoto.<br>";

		if ( $cognome === "" || Utils::soloSpazi($cognome) )
			$errors .= "Il campo Cognome non pu&ograve; essere vuoto.<br>";

		if ( $mail === "" || Utils::soloSpazi($mail) )
			$errors .= "Il campo Mail non pu&ograve; essere vuoto.<br>";
		else if ( !Utils::controllaMail($mail) )
			$errors .= "Il campo Mail contiene un indirizzo non valido.<br>";

		$errors .= $this->controllaInputPwd($pass1,$pass2);

		return $errors;
	}

	public function login( $mail, $pass )
	{
	    global $GRANT_MOSTRA_ALTRI_PG;
        global $GRANT_LOGIN_QUANDO_CHIUSO;
        global $GRANT_VISUALIZZA_MAIN;
	    global $MESSAGGIO_CHIUSURA;

	    if( !Utils::controllaMail($mail) )
	        throw new APIException("La mail inserita non &egrave; valida. Riprova con un'altra.");

		$query_grants  = "SELECT gi.email_giocatore,
                                 gi.default_pg_giocatore,
                                 CONCAT(gi.nome_giocatore,' ', gi.cognome_giocatore) AS nome_completo,
                                 rhg.grants_nome_grant AS permessi
                            FROM giocatori AS gi
                            LEFT OUTER JOIN ruoli_has_grants AS rhg ON gi.ruoli_nome_ruolo = rhg.ruoli_nome_ruolo
                            WHERE gi.email_giocatore = :mail AND
                                  gi.password_giocatore = :pass AND
                                  gi.eliminato_giocatore = 0";

		$params = array( ":mail" => $mail, ":pass" => sha1( $pass ) );
		$result = $this->db->doQuery( $query_grants, $params, False );

		if( count( $result ) === 0 )
			throw new APIException( "Email utente o password sono errati. Per favore riprovare." );

		$grants = array_map( "Utils::mappaPermessiUtente", $result );
		$query_pg_propri = "SELECT id_personaggio FROM personaggi WHERE giocatori_email_giocatore = :email";
        $pg_propri       = $this->db->doQuery( $query_pg_propri, array( ":email" => $mail ), False );

        if( !isset($pg_propri) || count($pg_propri) === 0 )
            $pg_propri = [];

        if( isset($MESSAGGIO_CHIUSURA) && !empty($MESSAGGIO_CHIUSURA) && !in_array( $GRANT_LOGIN_QUANDO_CHIUSO, $grants ) )
            throw new APIException($MESSAGGIO_CHIUSURA, APIException::$GRANTS_ERROR);

        $this->session->destroy();
        $this->session                     = SessionManager::getInstance();
		$this->session->email_giocatore    = $result[0]["email_giocatore"];
		$this->session->nome_giocatore     = $result[0]["nome_completo"];
		$this->session->permessi_giocatore = $grants;
		$this->session->pg_propri          = array_map( "Utils::mappaPGUtente", $pg_propri );

		$output = [
		    "status"          => "ok",
            "email_giocatore" => $this->session->email_giocatore,
            "nome_giocatore"  => $this->session->nome_giocatore,
            "pg_propri"       => $this->session->pg_propri,
            "permessi"        => $this->session->permessi_giocatore
        ];

		if( Utils::clientInSameLAN() && isset($this->idev_in_corso) && !UsersManager::controllaPermessi( $this->session, [$GRANT_MOSTRA_ALTRI_PG] ) )
        {
            $query_iscrizione = "SELECT personaggi_id_personaggio FROM iscrizione_personaggi AS ip
                                    JOIN personaggi AS pg ON pg.id_personaggio = ip.personaggi_id_personaggio
                                    JOIN giocatori AS gi ON gi.email_giocatore = pg.giocatori_email_giocatore
									WHERE eventi_id_evento = :idev AND gi.email_giocatore = :mail";
            $res_iscrizione   = $this->db->doQuery( $query_iscrizione, [ ":idev" => $this->idev_in_corso, ":mail" => $this->session->email_giocatore ], False );

            if( !isset($res_iscrizione) || count($res_iscrizione) === 0 )
                throw new APIException("Ci dispiace, solo i giocatori con personaggi iscritti all'evento in corso possono loggare.");

            $output["pg_da_loggare"] = $res_iscrizione[0]["personaggi_id_personaggio"];
            $output["event_id"] = $this->idev_in_corso;
        }
        else if ( $result[0]["default_pg_giocatore"] != NULL )
            $output["pg_da_loggare"] = $result[0]["default_pg_giocatore"];

		return json_encode($output);
	}

	public function controllaaccesso( )
	{
	    $section = func_get_arg(0);
		if( !isset( $this->session ) || ( isset( $this->session ) && !in_array( "visualizza_pagina_".$section, $this->session->permessi_giocatore ) ) )
            throw new APIException( "Impossibile accedere a questa sezione.", APIException::$GRANTS_ERROR );

		return "{\"status\": \"ok\"}";
	}

	public function controllaPwd( $pass )
	{
        $query_pwd  = "SELECT * FROM giocatori WHERE email_giocatore = :mail AND password_giocatore = :pass";
        $params = array( ":mail" => $this->session->email_giocatore, ":pass" => sha1( $pass ) );
        $result = $this->db->doQuery( $query_pwd, $params, False );

        if( count( $result ) > 0 )
            $json = "{\"status\": \"ok\"}";
        else
            $json = "{\"status\": \"error\", \"message\":\"Password errata.\"}";

		return $json;
	}

	public function logout( )
	{
		$this->session->destroy();

		return "{\"status\": \"ok\"}";
	}

	public function registra( $nome, $cognome, $note, $mail, $pass1, $pass2, $condizioni = NULL )
	{
		$errors = $this->controllaDatiRegistrazione( $nome, $cognome, $note, $mail, $pass1, $pass2, $condizioni );

		if( isset( $errors ) && $errors !== "" )
			throw new APIException($errors);

		$query_controllo = "SELECT email_giocatore FROM giocatori WHERE email_giocatore = :mail";
		$controllo       = $this->db->doQuery( $query_controllo, array( ":mail" => $mail ), False );

		if( count($controllo) > 0 )
		    throw new APIException("Esiste gi&agrave; un utente con la mail inserita. Inserirne una differente.");

        $macro_note = "NULL";
		$pass   = sha1( $pass1 );
		$params = array(
			":pass"    => $pass,
			":nome"    => $nome,
			":cognome" => $cognome,
			":mail"    => $mail
		);

		if( !empty($nome) && !Utils::soloSpazi($nome) )
        {
            $params[":note"] = $note;
            $macro_note = ":note";
        }

        $query  = "INSERT INTO giocatori (email_giocatore, password_giocatore, nome_giocatore, cognome_giocatore, note_giocatore) VALUES (:mail,:pass,:nome,:cognome,$macro_note)";
		$this->db->doQuery( $query, $params );

		$this->mailer->inviaMailRegistrazione( $mail, $nome." ".$cognome, $pass1  );

		return "{\"status\": \"ok\"}";
	}

	public function recuperaPassword( $mail )
	{
        if( !Utils::controllaMail($mail) )
            throw new APIException("La mail inserita non &egrave; valida.");

		$query_check = "SELECT CONCAT(nome_giocatore, ' ', cognome_giocatore) as nome_completo FROM giocatori WHERE email_giocatore = :id";
		$giocatore = $this->db->doQuery( $query_check, array( ":id" => $mail ), False );

		if( count( $giocatore ) < 1 )
		    throw new APIException("La mail inserita non esiste.");

	    $new_pass = Utils::generatePassword();

		$pass   = sha1( $new_pass );
		$query  = "UPDATE giocatori SET password_giocatore = :pass WHERE email_giocatore = :id";
		$params = array(
			":pass" => $pass,
			":id"   => $mail,
		);

		$this->db->doQuery( $query, $params, False );
		$this->mailer->inviaMailDatiAccesso( $mail, $giocatore[0]["nome_completo"], $new_pass  );

		return "{\"status\": \"ok\"}";
	}

	public function recuperaListaGiocatori( $draw, $columns, $order, $start, $length, $search )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $filter = False;
        $where  = "";
        $params = array();

        if( isset( $search ) && $search["value"] != "" )
        {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where = "AND (
						nome_giocatore LIKE :search OR
						email_giocatore LIKE :search OR
						ruoli_nome_ruolo LIKE :search OR
						note_giocatore LIKE :search OR
						note_staff_giocatore LIKE :search
					  )";
        }

        if( isset( $order ) )
        {
            $sorting = array();
            foreach ( $order as $elem )
                $sorting[] = $columns[$elem["column"]]["data"]." ".$elem["dir"];

            $order_str = "ORDER BY ".implode( $sorting, "," );
        }

        $query_players = "SELECT giocatori.*, CONCAT(nome_giocatore, ' ', cognome_giocatore) AS nome_completo
                              FROM giocatori WHERE eliminato_giocatore = 0 $where $order_str";
        $risultati = $this->db->doQuery( $query_players, $params, False );
        $totale    = count($risultati);

        if( count($risultati) > 0 )
            $risultati = array_splice($risultati, $start, $length);
        else
            $risultati = array();

        $output     = array(
            "status"          => "ok",
            "draw"            => $draw,
            "columns"         => $columns,
            "order"           => $order,
            "start"           => $start,
            "length"          => $length,
            "search"          => $search,
            "recordsTotal"    => $totale,
            "recordsFiltered" => $filter ? count($risultati) : $totale,
            "data"            => $risultati
        );

        return json_encode( $output );
	}

    public function recuperaNoteUtente( $id = NULL )
    {
        $id = isset( $id ) ? $id : $this->session->email_giocatore;
        self::operazionePossibile( $this->session, __FUNCTION__, $id );

        $query_note = "SELECT note_giocatore FROM giocatori WHERE email_giocatore = :id";
        $result     = $this->db->doQuery( $query_note, array( ":id" => $id ), False );

        return "{\"status\": \"ok\",\"result\": ".json_encode($result[0])." }";
    }

    public function modificaPassword( $vecchia, $pass1, $pass2 )
    {
        $pass_check = json_decode( $this->controllaPwd( $vecchia ) );

        if( $pass_check->status === "error" )
            throw new APIException("La vecchia password inserita non &egrave; corretta.");

        $errors = $this->controllaInputPwd( $pass1, $pass2 );

        if( isset( $errors ) && $errors !== "" )
            throw new APIException($errors);

        $this->modificaUtente( array( "password_giocatore" => sha1($pass1) ) );

        $this->mailer->inviaMailDatiAccesso( $this->session->email_giocatore, $this->session->nome_giocatore, $pass1 );

        return "{\"status\": \"ok\",\"result\": \"true\"}";
    }

    public function modificaUtente( $modifiche, $id = NULL )
    {
        $id = isset( $id ) ? $id : $this->session->email_giocatore;
        $to_update = [];
        $valori = [];

        foreach( $modifiche as $campo => $valore )
        {
            if( self::operazionePossibile($this->session, __FUNCTION__ . "_" . $campo, $id, False ) )
            {
                $val = $valore === "NULL" ? "NULL" : "?";

                if( $valore !== "NULL" )
                    $valori[] = $valore;

                $to_update[] = "$campo = $val";
            }
        }

        if( empty($to_update) )
            throw new APIException("Non &egrave; possibile eseguire l'operazione.",APIException::$GENERIC_ERROR);

        $to_update_str = implode(",",$to_update);
        $valori[] = $id;

        $query_bg = "UPDATE giocatori SET $to_update_str WHERE email_giocatore = ?";

        $this->db->doQuery( $query_bg, $valori, False );

        return "{\"status\": \"ok\",\"result\": \"true\"}";
    }

	public function eliminaGiocatore( $id )
	{
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $query_canc_pg = "UPDATE giocatori SET eliminato_giocatore = 1 WHERE email_giocatore = :id";
        $this->db->doQuery( $query_canc_pg, array( ":id" => $id ), False );

        return "{ \"status\":\"ok\" }";
	}
}
