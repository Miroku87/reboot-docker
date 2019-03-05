<?php

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class NewsManager
{
    protected $db;
    protected $session;
    protected $idev_in_corso;

    public static $MAPPA_PAGINA_ABILITA = [
        26 => "Informazioni Commerciali",
        75 => "Contatti nell'Ago",
        81 => "Contatti tra gli Sbirri",
        77 => "Contatti nella Malavita",
        82 => "Contatti nella Famiglia"
    ];

    public function __construct( $idev_in_corso = NULL )
    {
        $this->idev_in_corso = $idev_in_corso;
        $this->session = SessionManager::getInstance();
        $this->db = new DatabaseBridge();
    }

    public function __destruct()
    {
    }

    private function controllaInputArticolo( $tipo, $titolo, $autore, $pub_manuale, $data_pub, $ora_pub, $testo )
    {
        $error      = "";

        if( !isset($tipo) || $tipo === "-1" )
            $error .= "<li>&Egrave; obbligatorio scegliere il tipo dell'articolo.</li>";

        if( !isset($titolo) || Utils::soloSpazi($titolo) )
            $error .= "<li>Il campo Titolo non pu&ograve; essere lasciato vuoto.</li>";

        if( !isset($autore) || Utils::soloSpazi($autore) )
            $error .= "<li>Il campo Autore non pu&ograve; essere lasciato vuoto.</li>";

        if( isset($pub_manuale) && $pub_manuale === "0" && ( !isset($data_pub) || empty($data_pub) || Utils::soloSpazi($data_pub) || !isset($ora_pub) || empty($ora_pub) || Utils::soloSpazi($ora_pub) ) )
            $error .= "<li>Se la pubblicazione &egrave; automatica &egrave; obbligatorio inserire data e ora di pubblicazione.</li>";

        if( !isset($testo) || Utils::soloSpazi($testo) )
            $error .= "<li>Il Testo dell'Articolo non pu&ograve; essere lasciato vuoto.</li>";

        return $error;
    }

    private function azioneNotizia( $tipo, $titolo, $autore, $data_ig, $pub_manuale, $data_pub, $ora_pub, $testo, $id_articolo = NULL )
    {
        $errors = $this->controllaInputArticolo( $tipo, $titolo, $autore, $pub_manuale, $data_pub, $ora_pub, $testo );

        if( !empty($errors) )
            throw new APIException( "Sono stati riscontrati i seguenti errori: <ul>$errors</ul>" );

        $macro_data = "NULL";
        $params = [
            ":tipo" => $tipo,
            ":titolo" => $titolo,
            ":autore" => $autore,
            ":dataig" => $data_ig,
            ":testo" => $testo
        ];

        if( $pub_manuale === "0" )
        {
            $datetime = DateTime::createFromFormat("d/m/Y H:i", $data_pub." ".$ora_pub );
            $time_str = $datetime->format("Y-m-d H:i:s" );

            $params[":data_pub"] = $time_str;
            $macro_data = ":data_pub";
        }

        if ( !isset($id_articolo) )
        {
            $query = "INSERT INTO notizie (id_notizia, tipo_notizia, titolo_notizia, autore_notizia, data_ig_notizia, data_pubblicazione_notizia, testo_notizia, creatore_notizia)
                            VALUES ( NULL, :tipo, :titolo, :autore, :dataig, $macro_data, :testo, :creatore)";
            $params[":creatore"] = $this->session->email_giocatore;
        }
        else if ( isset($id_articolo) )
        {
            $query = "UPDATE notizie SET tipo_notizia = :tipo,
                                         titolo_notizia = :titolo,
                                         autore_notizia = :autore,
                                         data_ig_notizia = :dataig,
                                         data_pubblicazione_notizia = $macro_data,
                                         testo_notizia = :testo WHERE id_notizia = :id";
            $params[":id"] = $id_articolo;
        }

        $this->db->doQuery( $query, $params, False );

        $output = ["status" => "ok"];
        return json_encode($output);
    }

    public function creaNotizia( $tipo, $titolo, $autore, $data_ig, $pub_manuale, $data_pub, $ora_pub, $testo )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
        return $this->azioneNotizia( $tipo, $titolo, $autore, $data_ig, $pub_manuale, $data_pub, $ora_pub, $testo );
    }

    public function modificaNotizia( $tipo, $titolo, $autore, $data_ig, $pub_manuale, $data_pub, $ora_pub, $testo, $id_art )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );
        return $this->azioneNotizia( $tipo, $titolo, $autore, $data_ig, $pub_manuale, $data_pub, $ora_pub, $testo, $id_art );
    }

    public function recuperaNotizie( $draw, $columns, $order, $start, $length, $search )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $filter     = False;
        $where      = "";
        $params     = [];

        if( isset( $search ) && isset( $search["value"] ) && $search["value"] != "" )
        {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where .= " (
						CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) LIKE :search OR
						n.creatore_notizia LIKE :search OR
						n.data_pubblicazione_notizia LIKE :search OR
						n.titolo_notizia LIKE :search OR
						n.tipo_notizia LIKE :search OR
						n.autore_notizia LIKE :search OR
						n.data_ig_notizia LIKE :search OR
						n.testo_notizia LIKE :search
					  )";
        }

        if( isset( $order ) )
        {
            $sorting = array();
            foreach ( $order as $elem )
                $sorting[] = $columns[$elem["column"]]["data"]." ".$elem["dir"];

            $order_str = "ORDER BY ".implode( $sorting, "," );
        }

        if( !empty($where) )
            $where = "WHERE".$where;

        $query = "SELECT n.*,
                         IF( ( n.pubblica_notizia = 1 OR ( n.data_pubblicazione_notizia IS NOT NULL AND n.data_pubblicazione_notizia <= NOW() ) ), 'S&igrave;', 'No') as pubblica_notizia,
                         IF( n.data_pubblicazione_notizia IS NULL, 'Manuale', DATE_FORMAT( n.data_pubblicazione_notizia, '%d/%m/%Y %H:%i:%s' ) ) AS data_pubblicazione_notizia,
                         DATE_FORMAT( n.data_creazione_notizia, '%d/%m/%Y %H:%i:%s' ) AS data_creazione_notizia,
                         CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_giocatore
                      FROM notizie AS n
                        JOIN giocatori AS gi ON gi.email_giocatore = n.creatore_notizia
                      $where $order_str";

        $risultati  = $this->db->doQuery( $query, $params, False );
        $totale     = count($risultati);

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

        return json_encode($output);
    }

    public function recuperaNotiziePubbliche( $tipi = NULL )
    {
        global $GRANT_CREA_NOTIZIE;
        global $GRANT_MODIFICA_NOTIZIE;

        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $legge_tutto = UsersManager::controllaPermessi( $this->session, [$GRANT_CREA_NOTIZIE, $GRANT_MODIFICA_NOTIZIE], False );

        if( !$legge_tutto && !isset($this->session->pg_loggato) )
            throw new APIException("Devi essere loggato con un personaggio per compiere questa operazione.", APIException::$PG_LOGIN_ERROR);

        if (!$legge_tutto)
        {
            if (!isset($tipi))
            {
                $ids_civile = Utils::mappaArrayDiArrayAssoc($this->session->pg_loggato["abilita"]["civile"], "id_abilita");
                $ids_militare = Utils::mappaArrayDiArrayAssoc($this->session->pg_loggato["abilita"]["militare"], "id_abilita");
                $ids = array_merge($ids_civile, $ids_militare);
                $id_con_pag = Utils::filtraArrayConValori($ids, array_keys(self::$MAPPA_PAGINA_ABILITA));
                $pagine = Utils::filtraArrayConChiavi(self::$MAPPA_PAGINA_ABILITA, $id_con_pag);
                $tipi = array_values($pagine);
            }
            else if (isset($tipi) && !is_array($tipi))
                $tipi = [$tipi];

            $marcatori = str_repeat("?, ", count( $tipi ) - 1 ) . "?";
            $query_sel = "SELECT * FROM notizie
                            WHERE tipo_notizia IN ($marcatori) AND ( pubblica_notizia = 1 OR ( data_pubblicazione_notizia IS NOT NULL AND data_pubblicazione_notizia <= NOW() ) )
                            ORDER BY tipo_notizia ASC, data_creazione_notizia DESC ";
        }
        else
        {
            $query_sel = "SELECT * FROM notizie WHERE ( pubblica_notizia = 1 OR ( data_pubblicazione_notizia IS NOT NULL AND data_pubblicazione_notizia <= NOW() ) )
                            ORDER BY tipo_notizia ASC, data_creazione_notizia DESC ";
            $tipi = [];
        }

        $result = $this->db->doQuery($query_sel, $tipi, False);
        $result = !isset( $result ) ? [] : $result;
        $output = [ "status" => "ok", "result" => $result ];

        return json_encode($output);
    }

    public function pubblicaNotizia( $id )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $query = "UPDATE notizie SET pubblica_notizia = :pub WHERE id_notizia = :id";
        $params = [":id" => $id, ":pub" => 1];

        $this->db->doQuery( $query, $params, False );

        $output = ["status" => "ok"];
        return json_encode($output);
    }

    public function ritiraNotizia( $id )
    {
        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        $query = "UPDATE notizie SET pubblica_notizia = :pub, data_pubblicazione_notizia = NULL WHERE id_notizia = :id";
        $params = [":id" => $id, ":pub" => 0];

        $this->db->doQuery( $query, $params, False );

        $output = ["status" => "ok"];
        return json_encode($output);
    }
}
