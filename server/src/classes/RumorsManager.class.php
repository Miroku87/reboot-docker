<?php
$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class RumorsManager
{
    protected $db;
    protected $grants;
    protected $session;

    public function __construct()
    {
        $this->db      = new DatabaseBridge();
        $this->session = SessionManager::getInstance();
    }

    private function controllaErrori($luogo_ig, $testo, $data_ig, $data_pubblicazione, $ora_pubblicazione, $is_bozza)
    {
        $error = "";

        if ($is_bozza === True)
            return "";

        if (!isset($luogo_ig) || Utils::soloSpazi($luogo_ig))
            $error .= "<li>Il campo Luogo IG non pu&ograve; essere lasciato vuoto.</li>";

        if (!isset($testo) || Utils::soloSpazi($testo))
            $error .= "<li>Il testo del rumor non pu&ograve; essere lasciato vuoto.</li>";

        if (!isset($data_ig) || Utils::soloSpazi($data_ig))
            $error .= "<li>Il campo Data IG non pu&ograve; essere lasciato vuoto.</li>";

        if (!isset($data_pubblicazione) || Utils::soloSpazi($data_pubblicazione))
            $error .= "<li>Il campo Data di Pubblicazione non pu&ograve; essere lasciato vuoto.</li>";
        else
            $d_inizio = DateTime::createFromFormat("d/m/Y", $data_pubblicazione);

        if (!isset($ora_pubblicazione) || Utils::soloSpazi($ora_pubblicazione))
            $error .= "<li>Il campo Ora di Pubblicazione non pu&ograve; essere lasciato vuoto.</li>";

        return $error;
    }

    public function inserisciRumor($luogo_ig, $testo, $data_ig, $data_pubblicazione, $ora_pubblicazione, $is_bozza, $id_evento = NULL)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $errori = $this->controllaErrori($luogo_ig, $testo, $data_ig, $data_pubblicazione, $ora_pubblicazione, $is_bozza);

        if (!empty($errori))
            throw new APIException("Sono stati rilevati i seguenti errori:<ul>" . $errori . "</ul>");

        $params = [
            ":luogo_ig"   => $luogo_ig,
            ":testo"      => $testo,
            ":data_ig"    => $data_ig,
            ":is_bozza"   => $is_bozza == "true" ? 1 : 0,
            ":creatore"   => $this->session->email_giocatore,
            ":data_crea"  => (new DateTime())->format("Y-m-d H:i:s")
        ];

        $id_evento_pl = "NULL";
        $data_pubb = "NULL";
        $ora_pubb = "NULL";

        if (!empty($data_pubblicazione)) {
            $dt_pubb = DateTime::createFromFormat("d/m/Y H:i", $data_pubblicazione." ".$ora_pubblicazione);
            if((new DateTime()) > $dt_pubb) {
                throw new APIException("La data e l'ora di pubblicazione non possono essere già passate.");
            }

            $data_pubb = ":data_pubb";
            $params[":data_pubb"] = DateTime::createFromFormat("d/m/Y", $data_pubblicazione)->format("Y-m-d");

            $ora_pubb = ":ora_pubb";
            $params[":ora_pubb"] = $ora_pubblicazione . ":00";
        }

        if (!is_null($id_evento) && !empty($id_evento)) {
            $id_evento_pl = ":id_evento";
            $params[":id_evento"] = $id_evento;
        }

        $query_ins = "INSERT INTO rumors (luogo_ig_rumor,testo_rumor,data_ig_rumor,data_pubblicazione_rumor,ora_pubblicazione_rumor,eventi_id_evento,is_bozza_rumor,creatore_rumor, data_creazione) VALUES (:luogo_ig, :testo, :data_ig, $data_pubb, $ora_pubb, $id_evento_pl, :is_bozza, :creatore, :data_crea)";
        $this->db->doQuery($query_ins, $params, False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function modificaRumor($id, $luogo_ig, $testo, $data_ig, $data_pubblicazione, $ora_pubblicazione, $is_bozza, $id_evento = NULL)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__, $this->session->email_giocatore);
        
        $query_sel = "SELECT data_pubblicazione_rumor, 
                        ora_pubblicazione_rumor,
                        is_bozza_rumor
                      FROM rumors
                      WHERE id_rumor = :id";

        $rumor     = $this->db->doQuery($query_sel, [":id" => $id], False);

        if (count($rumor) == 0) {
            throw new APIException("Nessun rumor trovato con l'id inviato");
        }

        $pubblicazione_rumor = DateTime::createFromFormat("Y-m-d H:i:s", $rumor[0]["data_pubblicazione_rumor"]." ".$rumor[0]["ora_pubblicazione_rumor"]);
        
        if((new DateTime()) > $pubblicazione_rumor && $rumor[0]["is_bozza_rumor"] !== "1") {
            throw new APIException("Non &egrave; possibile modificare un rumor gi&agrave; pubblicato.");
        }

        $errori = $this->controllaErrori($luogo_ig, $testo, $data_ig, $data_pubblicazione, $ora_pubblicazione, $is_bozza);

        if (!empty($errori))
            throw new APIException("Sono stati rilevati i seguenti errori:<ul>" . $errori . "</ul>");

        $params = [
            ":id"         => $id,
            ":luogo_ig"   => $luogo_ig,
            ":testo"      => $testo,
            ":data_ig"    => $data_ig,
            ":is_bozza"   => $is_bozza == "true" ? 1 : 0,
        ];

        $id_evento_pl = "NULL";
        $data_pubb = "NULL";
        $ora_pubb = "NULL";

        if (!empty($data_pubblicazione)) {
            $dt_pubb = DateTime::createFromFormat("d/m/Y H:i", $data_pubblicazione." ".$ora_pubblicazione);
            if((new DateTime()) > $dt_pubb) {
                throw new APIException("La data e l'ora di pubblicazione non possono essere già passate.");
            }

            $data_pubb = ":data_pubb";
            $params[":data_pubb"] = $dt_pubb->format("Y-m-d");

            $ora_pubb = ":ora_pubb";
            $params[":ora_pubb"] = $ora_pubblicazione . ":00";
        }

        if (!is_null($id_evento) && !empty($id_evento)) {
            $id_evento_pl = ":id_evento";
            $params[":id_evento"] = $id_evento;
        }

        $query_mod = "UPDATE rumors SET luogo_ig_rumor = :luogo_ig,
                                        testo_rumor = :testo,
                                        data_ig_rumor = :data_ig,
                                        data_pubblicazione_rumor = $data_pubb,
                                        ora_pubblicazione_rumor = $ora_pubb,
                                        is_bozza_rumor = :is_bozza,
                                        eventi_id_evento = $id_evento_pl
                        WHERE id_rumor = :id";
        $this->db->doQuery($query_mod, $params, False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function approvaRumor($id, $approvato)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__, $this->session->email_giocatore);

        $query_pt = "UPDATE rumors SET approvato_rumor = :approvato WHERE id_rumor = :id";
        $this->db->doQuery($query_pt, [":approvato" => $approvato ? 1 : 0, ":id" => $id], False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function recuperaListaRumors($draw, $columns, $order, $start, $length, $search)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $filter     = False;
        $params     = [];

        if (isset($order)) {
            $sorting = array();
            foreach ($order as $elem)
                $sorting[] = $columns[$elem["column"]]["data"] . " " . $elem["dir"];

            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        $query_sel = "SELECT r.*,
                             DATE_FORMAT(r.data_pubblicazione_rumor,'%d/%m/%Y') data_pubb_formattata,
                             ev.titolo_evento,
                             CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_completo
                      FROM rumors AS r
                        JOIN giocatori AS gi ON gi.email_giocatore = r.creatore_rumor
                        LEFT JOIN eventi AS ev ON ev.id_evento = r.eventi_id_evento
                      $order_str";

        $risultati  = $this->db->doQuery($query_sel, $params, False);
        $output     = Utils::filterDataTableResults($draw, $columns, $order, $start, $length, $search, $risultati);

        return json_encode($output);
    }

    public function eliminaRumor($id)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__, $this->session->email_giocatore);
        
        $query_sel = "SELECT data_pubblicazione_rumor, 
                        ora_pubblicazione_rumor
                      FROM rumors
                      WHERE id_rumor = :id";

        $rumor     = $this->db->doQuery($query_sel, [":id" => $id], False);

        if (count($rumor) == 0) {
            throw new APIException("Nessun rumor trovato con l'id inviato");
        }

        $pubblicazione_rumor = DateTime::createFromFormat("Y-m-d H:i:s", $rumor[0]["data_pubblicazione_rumor"]." ".$rumor[0]["ora_pubblicazione_rumor"]);
        if((new DateTime()) > $pubblicazione_rumor) {
            throw new APIException("Non &egrave; possibile eliminare un rumor gi&agrave; pubblicato.");
        }

        $query_del = "DELETE FROM rumors WHERE id_rumor = :id";
        $this->db->doQuery($query_del,  [":id" => $id], False);

        return json_encode(["status" => "ok", "result" => true]);
    }

    public function recuperaListaRumorsPublic($id_evento, $id_tornata)
    {
        $query_sel = "SELECT r.*,
                             DATE_FORMAT(r.data_pubblicazione_rumor,'%d/%m/%Y') data_pubb_formattata,
                             ev.id_evento,
                             ev.titolo_evento
                      FROM rumors AS r
                        JOIN eventi AS ev ON ev.id_evento = r.eventi_id_evento
                      WHERE eventi_id_evento = :id AND 
                        r.is_bozza_rumor = 0 AND
                        CAST(CONCAT(r.data_pubblicazione_rumor,' ',r.ora_pubblicazione_rumor) as DATETIME) <= now()
                      ORDER BY r.eventi_id_evento ASC, r.data_pubblicazione_rumor ASC, r.ora_pubblicazione_rumor ASC, r.id_rumor ASC";

        $risultati  = $this->db->doQuery($query_sel, [":id" => $id_evento], False);

        $eventi = [];
        foreach($risultati as $row) {
            $datastr = $row["data_pubblicazione_rumor"]."T".$row["ora_pubblicazione_rumor"];
            $eventi[$row["titolo_evento"]][$datastr][] = $row;
        }

        return json_encode(["status" => "ok", "result" => $eventi]);
    }
}
