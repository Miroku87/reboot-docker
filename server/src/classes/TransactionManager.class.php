<?php

$path = $_SERVER['DOCUMENT_ROOT']."/";
include_once($path."classes/APIException.class.php");
include_once($path."classes/UsersManager.class.php");
include_once($path."classes/DatabaseBridge.class.php");
include_once($path."classes/SessionManager.class.php");
include_once($path."classes/CharactersManager.class.php");
include_once($path."classes/Utils.class.php");
include_once($path."config/constants.php");

class TransactionManager
{
    protected $idev_in_corso;
    protected $session;
    protected $character_manager;
    protected $db;

    public function __construct($char_manager, $idev_in_corso = NULL)
    {
        $this->idev_in_corso = $idev_in_corso;
        $this->character_manager = $char_manager;
        $this->db = new DatabaseBridge();
        $this->session = SessionManager::getInstance();
    }

    public function __destruct()
    {
    }

    public function inserisciTransazione( $id_debitore, $importo, $id_creditore, $note = NULL, $id_acq_comp = NULL )
    {
		global $INFINITE_MONEY_PGS;

        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        if( !in_array($id_debitore, $INFINITE_MONEY_PGS) && $this->character_manager->recuperaCredito( $id_debitore ) < $importo )
            throw new APIException("Non hai abbastanza Bit per completare l'operzione.");

        $params = [
            ":pgdeb" => $id_debitore,
            ":importo" => $importo
        ];

        if( isset($id_creditore) )
        {
            $cred_macro = ":pgcred";
            $params[$cred_macro] = $id_creditore;
        }
        else
            throw new APIException("Impossibile inserire una transazione senza indicare l'id del creditore.");

        if( isset($note) )
        {
            $note_macro = ":note";
            $params[$note_macro] = $note;
        }
        else
            $note_macro = "NULL";

        if( isset($id_acq_comp) )
        {
            $id_acq_comp_macro = ":idacqcomp";
            $params[$id_acq_comp_macro] = $id_acq_comp;
        }
        else
            $id_acq_comp_macro = "NULL";

        $sql_ins = "INSERT INTO transazioni_bit (debitore_transazione, creditore_transazione, importo_transazione, note_transazione, id_acquisto_componente) VALUES (:pgdeb,$cred_macro,:importo,$note_macro,$id_acq_comp_macro)";
        $this->db->doQuery( $sql_ins, $params, False );

        $output = ["status" => "ok", "result" => true];

        return json_encode($output);
    }

    public function inserisciTransazioneMolti( $importo, $note, $creditori = [], $debitore = 1 )
    {
        foreach( $creditori as $cc )
            $this->inserisciTransazione( $debitore, $importo, $cc, $note );

        $output = ["status" => "ok", "result" => true];

        return json_encode($output);
    }

    public function compraComponenti( $ids )
    {
        global $SCONTO_MERCATO;
        global $QTA_PER_SCONTO_MERCATO;
		global $INFINITE_MONEY_PGS;

        UsersManager::operazionePossibile( $this->session, __FUNCTION__ );

        if( !isset($this->session->pg_loggato) )
            throw new APIException("Devi essere loggato con un personaggio per compiere questa operazione.");

        if( !isset($ids) || count($ids) === 0 )
            throw new APIException( "Non ci sono articoli nel carrello." );

        $marcatori = str_repeat("?, ", count($ids) - 1) . "?";
        $sql = "SELECT   id_componente
                        ,costo_attuale_componente
                 FROM componenti_crafting WHERE id_componente IN ($marcatori)";
        $risultati = $this->db->doQuery($sql, $ids, False);

        $totale      = 0;
        $sconto      = 0;
        $sconto_txt  = "";
        $params_comp = [];

        foreach( $ids as $i )
        {
            $componente = Utils::filtraArrayDiArrayAssoc( $risultati, "id_componente", [ $i ] )[0];
            $totale += (int)$componente["costo_attuale_componente"];
            $params_comp[] = [ ":idpg" => $this->session->pg_loggato["id_personaggio"], ":idcomp" => $i, ":costo" => (int)$componente["costo_attuale_componente"] ];
        }

        if( count( $ids ) % $QTA_PER_SCONTO_MERCATO === 0 )
        {
            $sconto = ($SCONTO_MERCATO / 100);
            $totale = $totale - ( $totale * $sconto );
        }

        if( !in_array($this->session->pg_loggato["id_personaggio"], $INFINITE_MONEY_PGS) && $this->character_manager->recuperaCredito( $this->session->pg_loggato["id_personaggio"] ) < $totale )
            throw new APIException("Non hai abbastanza Bit per completare l'operzione.");

        $sql_acq_comp = "INSERT INTO componenti_acquistati (cliente_acquisto, id_componente_acquisto, importo_acquisto) VALUES (:idpg, :idcomp, :costo)";

        foreach ($params_comp as $p)
        {
            if( $sconto > 0 )
            {
                $sconto_txt = " Sconto del $SCONTO_MERCATO%. Prezzo pieno " . $p[":costo"] . " Bit.";
                $p[":costo"] = $p[":costo"] - ( $p[":costo"] * $sconto );
            }

            $id_acq_com   = $this->db->doQuery( $sql_acq_comp, $p, False );
            $this->inserisciTransazione( $p[":idpg"], $p[":costo"], 1, "Acquisto componente ".$p[":idcomp"]." dal RavShop.".$sconto_txt, $id_acq_com );
        }

        $output = [
            "status" => "ok",
            "result" => True
        ];

        return json_encode($output);
    }

    public function recuperaInfoBanca( )
    {
        if( !isset( $this->session->pg_loggato["id_personaggio"] ) )
            throw new APIException("Devi essere loggato con un personaggio per eseguire questa operazione.", APIException::$PG_LOGIN_ERROR );

        UsersManager::operazionePossibile( $this->session, __FUNCTION__, $this->session->pg_loggato["id_personaggio"] );

        $sql_check = "SELECT
                        ( SELECT SUM( COALESCE( u.importo, 0 ) ) as credito FROM (
							SELECT SUM( COALESCE( importo_transazione, 0 ) ) as importo, creditore_transazione as pg FROM transazioni_bit GROUP BY creditore_transazione
							UNION ALL
							SELECT ( SUM( COALESCE( importo_transazione, 0 ) ) * -1 ) as importo, debitore_transazione as pg FROM transazioni_bit GROUP BY debitore_transazione
						) as u WHERE pg = :idpg ) AS credito_personaggio,
                        ( SELECT COALESCE( SUM(importo_transazione), 0 ) FROM transazioni_bit WHERE YEAR(data_transazione) = YEAR(NOW()) AND creditore_transazione = :idpg ) as entrate_anno_personaggio,
                        ( SELECT COALESCE( SUM(importo_transazione), 0 ) FROM transazioni_bit WHERE YEAR(data_transazione) = YEAR(NOW()) AND debitore_transazione = :idpg ) as uscite_anno_personaggio";
        $ris_check = $this->db->doQuery( $sql_check, [ ":idpg" => $this->session->pg_loggato["id_personaggio"] ], False );

        $output = [
            "status" => "ok",
            "result" => $ris_check[0]
        ];

        return json_encode($output);
    }

    public function recuperaMovimenti( $draw, $columns, $order, $start, $length, $search, $tutti = False )
    {
        $tutti = (bool)$tutti;

        if( !$tutti && !isset( $this->session->pg_loggato["id_personaggio"] ) )
            throw new APIException("Devi essere loggato con un personaggio per eseguire questa operazione.", APIException::$PG_LOGIN_ERROR );

		if( $tutti )
			$pgid = -1;
		else
			$pgid = $this->session->pg_loggato["id_personaggio"];

        UsersManager::operazionePossibile( $this->session, __FUNCTION__, $pgid );

        $filter     = False;
        $where      = $tutti ? [] : [ "( t.debitore_transazione = :pgid OR t.creditore_transazione = :pgid )" ];
        $params     = $tutti ? [] : [ ":pgid" => $pgid ];
        $sql_tipo   = $tutti ? "" : ", IF( tb.creditore_transazione = :pgid, 'entrata', 'uscita' ) as tipo_transazione";
        $order_str  = "";
        $field_map  = [ "datait_transazione" => "data_transazione" ];

        if (isset($search) && isset($search["value"]) && $search["value"] != "")
        {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where[] = " (
						t.nome_creditore LIKE :search OR
						t.nome_debitore LIKE :search OR
						t.tipo_transazione LIKE :search OR
						t.note_transazione LIKE :search OR
						t.datait_transazione LIKE :search
					  )";
        }

        if( isset( $order ) && count($order) > 0 )
        {
            $order_by_field = $columns[$order[0]["column"]]["data"];
            $order_by_field = !isset( $field_map[$order_by_field] ) ? $order_by_field : $field_map[$order_by_field];
            $order_by_dir   = $order[0]["dir"];
            $order_str      = "ORDER BY t." . $order_by_field . " " . $order_by_dir;
        }

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_ric = "SELECT * FROM
                      (
                        SELECT
                            tb.*,
                            DATE_FORMAT( tb.data_transazione, '%d/%m/%Y %H:%i:%s' ) as datait_transazione,
                            IF( tb.id_acquisto_componente IS NOT NULL, 'RavShop', pgc.nome_personaggio ) as nome_creditore,
                            pgd.nome_personaggio as nome_debitore
                            $sql_tipo
                        FROM transazioni_bit AS tb
                            LEFT OUTER JOIN personaggi AS pgc ON pgc.id_personaggio = tb.creditore_transazione
                            JOIN personaggi AS pgd ON pgd.id_personaggio = tb.debitore_transazione
                      ) AS t $where $order_str";

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
