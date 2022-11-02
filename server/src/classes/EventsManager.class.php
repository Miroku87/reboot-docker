<?php
$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/Mailer.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class EventsManager
{
    protected $db;
    protected $grants;
    protected $session;
    protected $mailer;

    public function __construct()
    {
        $this->db      = new DatabaseBridge();
        $this->session = SessionManager::getInstance();
        $this->mailer  = new Mailer();
    }

    private function controllaErrori($titolo, $data_inizio, $ora_inizio, $data_fine, $ora_fine, $luogo, $costo, $costo_max)
    {
        $error       = "";

        if (!isset($titolo) || Utils::soloSpazi($titolo))
            $error .= "<li>Il campo Titolo non pu&ograve; essere lasciato vuoto.</li>";
        if (!isset($data_inizio) || Utils::soloSpazi($data_inizio))
            $error .= "<li>Il campo Data Inizio non pu&ograve; essere lasciato vuoto.</li>";
        else
            $d_inizio = DateTime::createFromFormat("d/m/Y", $data_inizio);
        if (!isset($ora_inizio) || Utils::soloSpazi($ora_inizio))
            $error .= "<li>Il campo Ora Inizio non pu&ograve; essere lasciato vuoto.</li>";
        if (!isset($data_fine) || Utils::soloSpazi($data_fine))
            $error .= "<li>Il campo Data Fine non pu&ograve; essere lasciato vuoto.</li>";
        else
            $d_fine = DateTime::createFromFormat("d/m/Y", $data_fine);
        if (!isset($ora_fine) || Utils::soloSpazi($ora_fine))
            $error .= "<li>Il campo Ora Fine non pu&ograve; essere lasciato vuoto.</li>";
        if (isset($costo) && !Utils::soloSpazi($costo) && !preg_match("/^\d+(\.\d+)?$/", $costo))
            $error .= "<li>Il campo Costo pu&ograve; contenere solo numeri.</li>";
        if (isset($costo_max) && Utils::soloSpazi($costo_max) && !preg_match("/^\d+$/", $costo_max))
            $error .= "<li>Il campo Costo Maggiorato pu&ograve; contenere solo numeri.</li>";
        if (!isset($luogo) || Utils::soloSpazi($luogo))
            $error .= "<li>Il campo Luogo non pu&ograve; essere lasciato vuoto.<br>";

        if (isset($d_inizio) && isset($d_fine) && $d_fine < $d_inizio)
            $error .= "<li>La data di fine non pu&ograve; essere prima di quella d'inizio.</li>";

        return $error;
    }

    private function possoPubblicare()
    {
        $query_pub = "SELECT pubblico_evento FROM eventi WHERE pubblico_evento = 1 AND data_inizio_evento > DATE(NOW())";
        $result    = $this->db->doQuery($query_pub, [], False);

        if (count($result) > 0)
            throw new APIException("&Egrave; stato gi&agrave; aperto un evento alle iscrizioni. Non &egrave; possibile pubblicarne altri a meno di ritirare il precedente.");
    }

    private function controllaDataEvento($id)
    {
        $query_data = "SELECT id_evento FROM eventi WHERE data_inizio_evento > DATE(NOW()) AND id_evento = :idev";
        $evento     = $this->db->doQuery($query_data, [":idev" => $id], False);

        if (!isset($evento) || (isset($evento) && count($evento) === 0))
            throw new APIException("Non &egrave; possibile modificare un evento passato.");
    }

    public function creaEvento($titolo, $data_inizio, $ora_inizio, $data_fine, $ora_fine, $luogo, $costo, $costo_max, $note)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $errori = $this->controllaErrori($titolo, $data_inizio, $ora_inizio, $data_fine, $ora_fine, $luogo, $costo, $costo_max);

        if (!empty($errori))
            throw new APIException("Sono stati rilevati i seguenti errori:<ul>" . $errori . "</ul>");

        $params = [
            ":titolo"    => $titolo,
            ":d_inizio"  => DateTime::createFromFormat("d/m/Y", $data_inizio)->format("Y-m-d"),
            ":t_inizio"  => $ora_inizio . ":00",
            ":d_fine"    => DateTime::createFromFormat("d/m/Y", $data_fine)->format("Y-m-d"),
            ":t_fine"    => $ora_fine . ":00",
            ":luogo"     => $luogo,
            ":costo"     => $costo,
            ":costo_max" => $costo_max,
            ":creatore"  => $this->session->email_giocatore,
            ":note"      => nl2br($note)
        ];


        $query_crea = "INSERT INTO eventi (id_evento, titolo_evento, data_inizio_evento, ora_inizio_evento, data_fine_evento, ora_fine_evento, luogo_evento, costo_evento, costo_maggiorato_evento, pubblico_evento, creatore_evento, note_evento) VALUES (NULL, :titolo, :d_inizio, :t_inizio, :d_fine, :t_fine, :luogo, :costo, :costo_max, 0, :creatore, :note)";
        $this->db->doQuery($query_crea, $params, False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function modificaEvento($id, $titolo, $data_inizio, $ora_inizio, $data_fine, $ora_fine, $luogo, $costo, $costo_max, $note)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaDataEvento($id);

        $errori = $this->controllaErrori($titolo, $data_inizio, $ora_inizio, $data_fine, $ora_fine, $luogo, $costo, $costo_max, $note);

        if (!empty($errori))
            throw new APIException("Sono stati rilevati i seguenti errori:<ul>" . $errori . "</ul>");

        $params = [
            ":id"        => $id,
            ":titolo"    => $titolo,
            ":d_inizio"  => DateTime::createFromFormat("d/m/Y", $data_inizio)->format("Y-m-d"),
            ":t_inizio"  => $ora_inizio . ":00",
            ":d_fine"    => DateTime::createFromFormat("d/m/Y", $data_fine)->format("Y-m-d"),
            ":t_fine"    => $ora_fine . ":00",
            ":luogo"     => $luogo,
            ":costo"     => $costo,
            ":costo_max" => $costo_max,
            ":note"      => nl2br($note)
        ];

        $query_crea = "UPDATE eventi SET titolo_evento = :titolo,
                                         data_inizio_evento = :d_inizio,
                                         ora_inizio_evento = :t_inizio,
                                         data_fine_evento = :d_fine,
                                         ora_fine_evento = :t_fine,
                                         luogo_evento = :luogo,
                                         costo_evento = :costo,
                                         costo_maggiorato_evento = :costo_max,
                                         note_evento = :note
                        WHERE id_evento = :id";
        $this->db->doQuery($query_crea, $params, False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function impostaPuntiAssegnatiEvento($id)
    {
        UsersManager::operazionePossibile($this->session, "modificaEvento");

        $query_pt = "UPDATE eventi SET punti_assegnati_evento = :punti
                        WHERE id_evento = :id";
        $this->db->doQuery($query_pt, [":punti" => 1, ":id" => $id], False);

        return json_encode(["status" => "ok", "result" => "true"]);
    }

    public function recuperaEvento($id = "last")
    {
        UsersManager::operazionePossibile($this->session, "recuperaEventi");

        $query_end = $id === "last" ? "WHERE pubblico_evento = 1 AND data_inizio_evento > DATE(NOW()) ORDER BY id_evento DESC LIMIT 1" : "WHERE id_evento = :id";
        $params    = $id === "last" ? [] : [":id" => $id];

        $query_ev = "SELECT ev.*,
                            DATE_FORMAT(ev.data_inizio_evento, '%d/%m/%Y') AS data_inizio_evento_it,
                            DATE_FORMAT(ev.data_fine_evento, '%d/%m/%Y') AS data_fine_evento_it
                     FROM eventi AS ev $query_end";
        $evento = $this->db->doQuery($query_ev, $params, False);

        return json_encode(["status" => "ok", "result" => $evento[0]]);
    }

    public function recuperaEventoInCorso()
    {
        $query_ev = "SELECT id_evento FROM eventi AS ev WHERE ev.pubblico_evento = 1 AND DATE(NOW()) BETWEEN ev.data_inizio_evento AND ev.data_fine_evento";
        $res_ev   = $this->db->doQuery($query_ev, [], False);

        if (!isset($res_ev) || count($res_ev) === 0)
            return NULL;

        return $res_ev[0]["id_evento"];
    }

    public function recuperaListaEventi($draw, $columns, $order, $start, $length, $search)
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

        $query_mex = "SELECT ev.*,
                             CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_completo
                      FROM eventi AS ev
                        JOIN giocatori AS gi ON gi.email_giocatore = ev.creatore_evento
                      $order_str";

        $risultati  = $this->db->doQuery($query_mex, $params, False);
        $output     = Utils::filterDataTableResults($draw, $columns, $order, $start, $length, $search, $risultati);

        return json_encode($output);
    }

    public function recuperaListaEventiPublic()
    {
        $filtra_evts = [6,9,10,11];
        $marker_evts = str_repeat("?,", count($filtra_evts) - 1) . "?";

        $query_mex = "SELECT 
                            id_evento, 
                            titolo_evento,
                            DATE_FORMAT(data_inizio_evento,'%d/%m/%Y') data_inizio_evento,
                            DATE_FORMAT(data_fine_evento,'%d/%m/%Y') data_fine_evento,
                            ora_inizio_evento,
                            ora_fine_evento,
                            luogo_evento
                        FROM eventi 
                        WHERE 
                            pubblico_evento = 1 AND 
                            id_evento NOT IN ($marker_evts)
                        ORDER BY id_evento DESC";
        $risultati  = $this->db->doQuery($query_mex, $filtra_evts, False);

        return json_encode(["status" => "ok", "result" => $risultati]);
    }

    public function iscriviPg($id_pg, $pagato, $tipo_pagamento, $note = "")
    {
        if (!isset($id_pg) || empty($id_pg))
            throw new APIException("Devi selezionare un personaggio da iscrivere.");

        UsersManager::operazionePossibile($this->session, __FUNCTION__, $id_pg);

        $query_idev = "SELECT id_evento FROM eventi WHERE pubblico_evento = 1 ORDER BY data_inizio_evento DESC LIMIT 1";
        $res_idev   = $this->db->doQuery($query_idev, [], False);
        $id_evento  = $res_idev[0]["id_evento"];

        $query_check = "SELECT personaggi_id_personaggio, eventi_id_evento FROM iscrizione_personaggi
                        WHERE eventi_id_evento = :idev
                        AND personaggi_id_personaggio IN 
                            ( SELECT id_personaggio FROM personaggi 
                                WHERE giocatori_email_giocatore = ( SELECT giocatori_email_giocatore FROM personaggi WHERE id_personaggio = :pgid  ) )";
        $res_check   = $this->db->doQuery($query_check, [":idev" => $id_evento, ":pgid" => $id_pg], False);

        if (isset($res_check) && count($res_check) > 0)
            throw new APIException("Lo stesso giocatore non pu&ograve; iscrivere pi&ugrave; di un personaggio allo stesso evento.");

        $params = [
            ":id_ev"     => $id_evento,
            ":id_pg"     => $id_pg,
            ":pagato"    => $pagato,
            ":tipo_pag"  => $tipo_pagamento,
            ":note"      => nl2br($note)
        ];

        $query_ev = "INSERT INTO iscrizione_personaggi (eventi_id_evento,personaggi_id_personaggio,pagato_iscrizione,tipo_pagamento_iscrizione,note_iscrizione) VALUES ( :id_ev, :id_pg, :pagato, :tipo_pag, :note)";
        $evento = $this->db->doQuery($query_ev, $params, False);

        $query_gi = "SELECT pg.nome_personaggio, CONCAT(gi.nome_giocatore, ' ', gi.cognome_giocatore) as nome_completo, gi.note_giocatore
                        FROM personaggi AS pg
                        JOIN giocatori AS gi ON pg.giocatori_email_giocatore = gi.email_giocatore
                     WHERE id_personaggio = :idpg";
        $info     = $this->db->doQuery($query_gi, [":idpg" => $id_pg], False);

        $this->mailer->inviaAvvisoIscrizione($info[0]["nome_completo"], $info[0]["nome_personaggio"], $info[0]["note_giocatore"], $id_pg, $res_pub[0]["titolo_evento"], $note);

        return json_encode(["status" => "ok", "result" => $evento[0]]);
    }

    public function modificaIscrizionePG($id_evento, $pgid, $modifiche)
    {
        foreach ($modifiche as $campo => $valore) {
            UsersManager::operazionePossibile($this->session, __FUNCTION__ . "_" . $campo, $pgid);

            $campi[] = $campo;
            $valori[] = $valore;
        }

        $to_update = implode(" = ?, ", $campi) . " = ?";

        $valori[] = $pgid;
        $valori[] = $id_evento;
        $query_mod = "UPDATE iscrizione_personaggi SET $to_update WHERE personaggi_id_personaggio = ? AND eventi_id_evento = ?";
        $this->db->doQuery($query_mod, $valori, False);

        return json_encode(["status" => "ok", "result" => true]);
    }

    public function disiscriviPG($id_evento, $id_pg)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__, $id_pg);

        $params = [
            ":id_ev"     => $id_evento,
            ":id_pg"     => $id_pg
        ];

        $query_ev = "DELETE FROM iscrizione_personaggi WHERE personaggi_id_personaggio = :id_pg AND eventi_id_evento = :id_ev";
        $evento = $this->db->doQuery($query_ev, $params, False);

        return json_encode(["status" => "ok", "result" => $evento[0]]);
    }

    public function pubblicaEvento($id_evento)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);
        $this->possoPubblicare();

        $params = [
            ":id_ev" => $id_evento,
            ":pub"   => 1
        ];

        $query_pub = "UPDATE eventi SET pubblico_evento = :pub WHERE id_evento = :id_ev";
        $this->db->doQuery($query_pub, $params, False);

        $this->mailer->inviaAvvisoEvento();

        return json_encode(["status" => "ok", "result" => true]);
    }

    public function ritiraEvento($id_evento)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaDataEvento($id_evento);

        $params = [
            ":id_ev" => $id_evento,
            ":pub"   => 0
        ];

        $query_pub = "UPDATE eventi SET pubblico_evento = :pub WHERE id_evento = :id_ev";
        $this->db->doQuery($query_pub, $params, False);

        return json_encode(["status" => "ok", "result" => true]);
    }

    public function eliminaEvento($id_evento)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $this->controllaDataEvento($id_evento);

        $params = [
            ":id_ev" => $id_evento
        ];

        $query_del = "DELETE FROM eventi WHERE id_evento = :id_ev";
        $this->db->doQuery($query_del, $params, False);

        return json_encode(["status" => "ok", "result" => true]);
    }

    private function recuperaListaIscritti($tipo, $draw, $columns, $order, $start, $length, $search, $quando, $where = [])
    {
        $params     = [];
        $filter     = False;
        $extra_sel  = $tipo === "avanzato" ? "ip.pagato_iscrizione, ip.tipo_pagamento_iscrizione, ip.note_iscrizione, ip.ha_partecipato_iscrizione, gi.note_giocatore, " : "";
        $order_str  = "";

        if ($quando === "prossimo")
            $where[] = "t1.pubblico_evento = 1 AND t1.data_inizio_evento > DATE(NOW())";
        else if ($quando === "precedente")
            $where[] = "t1.id_evento = (SELECT id_evento FROM eventi WHERE pubblico_evento = 1 AND data_inizio_evento <= DATE(NOW()) ORDER BY data_inizio_evento DESC LIMIT 1)";

        if (isset($search) && isset($search["value"]) > 0 && $search["value"] != "") {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where[] = "(
						t1.nome_completo LIKE :search OR
						t1.personaggi_id_personaggio LIKE :search OR
						t1.nome_personaggio LIKE :search OR
						t1.classi_civili LIKE :search OR
						t1.classi_militari LIKE :search " . ($tipo === "avanzato" ?
                "OR t1.tipo_pagamento_iscrizione LIKE :search
                        OR t1.note_iscrizione LIKE :search" : "") .

                ")";
        }

        if (isset($order) && count($order) > 0 && !empty($order)) {
            $sorting = array();
            foreach ($order as $elem)
                $sorting[] = $columns[$elem["column"]]["data"] . " " . $elem["dir"];

            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        if (count($where) > 0)
            $where = implode(" AND ", $where);
        else
            $where = "";

        $query_mex = "SELECT * FROM (
                          SELECT ip.personaggi_id_personaggio,
                                 ev.id_evento,
                                 ev.data_inizio_evento,
                                 ev.pubblico_evento,
                                 ev.punti_assegnati_evento,
                                 $extra_sel
                                 pg.nome_personaggio,
                                 CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_completo,
                                 GROUP_CONCAT(DISTINCT cl_c.nome_classe SEPARATOR ', ') AS classi_civili,
                                 GROUP_CONCAT(DISTINCT cl_m.nome_classe SEPARATOR ', ') AS classi_militari,
                                 '$quando' AS quando
                          FROM iscrizione_personaggi AS ip
                            JOIN eventi AS ev ON ev.id_evento = ip.eventi_id_evento
                            JOIN personaggi AS pg ON pg.id_personaggio = ip.personaggi_id_personaggio
                            JOIN giocatori AS gi ON gi.email_giocatore = pg.giocatori_email_giocatore
                            LEFT OUTER JOIN personaggi_has_classi AS phc ON phc.personaggi_id_personaggio = pg.id_personaggio
                            LEFT OUTER JOIN classi AS cl_m ON cl_m.id_classe = phc.classi_id_classe AND cl_m.tipo_classe = 'militare'
                            LEFT OUTER JOIN classi AS cl_c ON cl_c.id_classe = phc.classi_id_classe AND cl_c.tipo_classe = 'civile'
                          GROUP BY ev.id_evento, ip.personaggi_id_personaggio
                          ) AS t1 WHERE $where $order_str";

        $risultati  = $this->db->doQuery($query_mex, $params, False);
        $totale     = count($risultati);

        if (count($risultati) > 0)
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

    public function recuperaListaIscrittiAvanzato($draw, $columns, $order, $start, $length, $search, $quando)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        return $this->recuperaListaIscritti("avanzato", $draw, $columns, $order, $start, $length, $search, $quando);
    }

    public function recuperaListaPartecipanti($id_ev)
    {
        UsersManager::operazionePossibile($this->session, "recuperaListaIscrittiAvanzato");

        return $this->recuperaListaIscritti("avanzato", 1, [], [], 0, 999, [], "precedente", ["t1.ha_partecipato_iscrizione = 1"]);
    }

    public function recuperaListaIscrittiBase($draw, $columns, $order, $start, $length, $search, $quando)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        return $this->recuperaListaIscritti("base", $draw, $columns, $order, $start, $length, $search, $quando);
    }

    public function recuperaNotePGIscritto($id_evento, $id_pg)
    {
        UsersManager::operazionePossibile($this->session, "recuperaListaIscrittiAvanzato");

        $query_note = "SELECT note_iscrizione FROM iscrizione_personaggi WHERE eventi_id_evento = :idev AND personaggi_id_personaggio = :idpg";
        $note       = $this->db->doQuery($query_note, [":idev" => $id_evento, ":idpg" => $id_pg], False);
        $output     = ["status" => "ok", "result" => $note[0]["note_iscrizione"]];

        return json_encode($output);
    }
}
