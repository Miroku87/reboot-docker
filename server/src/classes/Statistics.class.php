<?php
$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class Statistics
{
    protected $db;
    protected $charactersmanager;
    protected $session;
    private $event_id;
    private $event_sql;

    public function __construct($cm)
    {
        $this->db = new DatabaseBridge();
        $this->session = SessionManager::getInstance();
        $this->charactersmanager = $cm;
        $this->event_sql = "AND pg.id_personaggio IN (SELECT personaggi_id_personaggio FROM iscrizione_personaggi WHERE eventi_id_evento = :idev)";

        $query_idev     = "SELECT id_evento FROM eventi WHERE pubblico_evento = 1 ORDER BY data_inizio_evento DESC LIMIT 1";
        $res_idev       = $this->db->doQuery($query_idev, [], False);
        $this->event_id = [":idev" => $res_idev[0]["id_evento"] ];
    }

    public function recuperaStatisticheClassi()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT COUNT(cl.nome_classe) AS QTY,
                       cl.tipo_classe,
                       cl.nome_classe
                FROM personaggi_has_classi
                    JOIN classi AS cl ON cl.id_classe = classi_id_classe
                    JOIN personaggi AS pg ON pg.id_personaggio = personaggi_id_personaggio
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') $this->event_sql
                GROUP BY cl.tipo_classe, cl.id_classe
                ORDER BY QTY DESC, tipo_classe, nome_classe";

        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheAbilita()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT COUNT(ab.nome_abilita) AS QTY,
                       ab.tipo_abilita,
                       CONCAT(ab.nome_abilita,' (', cl.nome_classe, ')') AS nome_abilita
                FROM personaggi_has_abilita
                    JOIN abilita AS ab ON ab.id_abilita = abilita_id_abilita
                    JOIN classi AS cl ON cl.id_classe = classi_id_classe
                    JOIN personaggi AS pg ON pg.id_personaggio = personaggi_id_personaggio
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') $this->event_sql
                GROUP BY ab.tipo_abilita, ab.id_abilita
                ORDER BY QTY DESC, tipo_abilita, nome_abilita";

        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheAbilitaPerProfessione()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT
                    COUNT(QTY) AS num_pgs,
                    QTY,
                    nome_classe
                FROM (
                    SELECT
                        pg.nome_personaggio,
                        COUNT(ab.nome_abilita) AS QTY,
                        cl.nome_classe
                    FROM personaggi_has_abilita
                        JOIN abilita AS ab ON ab.id_abilita = abilita_id_abilita
                        JOIN classi AS cl ON cl.id_classe = classi_id_classe
                        JOIN personaggi AS pg ON pg.id_personaggio = personaggi_id_personaggio
                        JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                    WHERE g.ruoli_nome_ruolo NOT IN ('staff' , 'admin') AND ab.tipo_abilita = 'civile' $this->event_sql
                    GROUP BY ab.classi_id_classe , pg.id_personaggio
                    ORDER BY cl.nome_classe , QTY DESC , nome_abilita
                ) AS qty_t
                GROUP BY QTY, nome_classe
                ORDER BY nome_classe, QTY DESC";

        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheCrediti()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT SUM( COALESCE( u.importo, 0 ) ) AS credito_personaggio,
                       data_transazione_str,
                       pg_id
                FROM (
                    SELECT SUM( COALESCE( importo_transazione, 0 ) ) AS importo,
                           creditore_transazione AS pg_id,
                           DATE_FORMAT( data_transazione, '%d/%m/%Y' ) AS data_transazione_str
                    FROM transazioni_bit
                    GROUP BY creditore_transazione

                        UNION ALL

                    SELECT SUM( COALESCE( importo_transazione, 0 ) ) * -1 AS importo,
                           debitore_transazione AS pg_id,
                           DATE_FORMAT( data_transazione, '%d/%m/%Y' ) AS data_transazione_str
                    FROM transazioni_bit
                    GROUP BY debitore_transazione
                ) AS u
                    JOIN personaggi AS pg ON pg.id_personaggio = pg_id
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') $this->event_sql
                GROUP BY data_transazione_str";

        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatistichePG()
    {
        global $PF_INIZIALI;

        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT id_personaggio,
                       MAX(cl_m.mente_base_classe) AS mente_base_personaggio,
                       MAX(cl_m.shield_max_base_classe) AS scudo_base_personaggio
                FROM personaggi AS pg
                    LEFT OUTER JOIN personaggi_has_classi AS phc ON phc.personaggi_id_personaggio = pg.id_personaggio
                    LEFT OUTER JOIN classi AS cl_m ON cl_m.id_classe = phc.classi_id_classe AND cl_m.tipo_classe = 'militare'
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') $this->event_sql
                GROUP BY id_personaggio";
        $pg = $this->db->doQuery($sql, $this->event_id, False);
        $data = ["pf" => [], "ps" => [], "mente" => []];

        for ($i = 0; $i < count($pg); $i++) {
            $query_ab = "SELECT id_abilita, offset_pf_abilita, offset_shield_abilita, offset_mente_abilita
                         FROM abilita
                         WHERE id_abilita IN ( SELECT abilita_id_abilita FROM personaggi_has_abilita WHERE personaggi_id_personaggio = :pgid )";
            $abilita = $this->db->doQuery($query_ab, [":pgid" => $pg[$i]["id_personaggio"]], False);

            $pf_personaggio = $this->charactersmanager->calcolaPF($PF_INIZIALI, $abilita);
            $shield_personaggio = $this->charactersmanager->calcolaShield($pg[$i]["scudo_base_personaggio"], $abilita);
            $mente_personaggio = $this->charactersmanager->calcolaDifesaMentale($pg[$i]["mente_base_personaggio"], $abilita);

            if (!isset($data["pf"][$pf_personaggio + ""]))
                $data["pf"][$pf_personaggio + ""] = 1;
            else
                $data["pf"][$pf_personaggio + ""]++;

            if (!isset($data["ps"][$shield_personaggio + ""]))
                $data["ps"][$shield_personaggio + ""] = 1;
            else
                $data["ps"][$shield_personaggio + ""]++;

            if (!isset($data["mente"][$mente_personaggio + ""]))
                $data["mente"][$mente_personaggio + ""] = 1;
            else
                $data["mente"][$mente_personaggio + ""]++;
        }

        arsort($data["pf"]);
        arsort($data["ps"]);
        arsort($data["mente"]);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatistichePunteggi()
    {
        global $MAPPA_COSTO_CLASSI_CIVILI;

        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT  id_personaggio,
                        pc_personaggio,
                        px_personaggio,
                        COUNT(DISTINCT cl_c.nome_classe) AS num_classi_civili,
                        COUNT(DISTINCT cl_m.nome_classe) AS num_classi_militari,
                        COUNT(DISTINCT ab_m.nome_abilita) AS num_abilita_militari,
                        ( SELECT
                          SUM(costo_abilita) FROM abilita
                          WHERE tipo_abilita = 'civile' AND id_abilita IN (
                            SELECT abilita_id_abilita FROM personaggi_has_abilita
                            WHERE personaggi_id_personaggio = pg.id_personaggio
                            )
                        ) AS costo_abilita_civili
                FROM personaggi AS pg
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                    LEFT OUTER JOIN personaggi_has_classi AS phc ON phc.personaggi_id_personaggio = pg.id_personaggio
                    LEFT OUTER JOIN personaggi_has_abilita AS pha ON pha.personaggi_id_personaggio = pg.id_personaggio
                    LEFT OUTER JOIN classi AS cl_m ON cl_m.id_classe = phc.classi_id_classe AND cl_m.tipo_classe = 'militare'
                    LEFT OUTER JOIN classi AS cl_c ON cl_c.id_classe = phc.classi_id_classe AND cl_c.tipo_classe = 'civile'
                    LEFT OUTER JOIN abilita AS ab_m ON ab_m.id_abilita = pha.abilita_id_abilita AND ab_m.tipo_abilita = 'militare'
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') $this->event_sql
                GROUP BY id_personaggio";

        $pg = $this->db->doQuery($sql, $this->event_id, False);
        $data = ["pc_risparmiati" => [], "px_risparmiati" => [], "pc_spesi" => [], "px_spesi" => [], "pc_ora" => [], "px_ora" => []];

        for ($i = 0; $i < count($pg); $i++) {
            $pc_ora = (int) $pg[$i]["pc_personaggio"];
            $px_ora = (int) $pg[$i]["px_personaggio"];
            $pc_spesi = (int) $pg[$i]["num_classi_militari"] + (int) $pg[$i]["num_abilita_militari"];
            $px_spesi = (int) $pg[$i]["costo_abilita_civili"];

            for ($j = 0; $j < (int) $pg[$i]["num_classi_civili"]; $j++)
                $px_spesi += $MAPPA_COSTO_CLASSI_CIVILI[$j];

            $pc_risparmiati = $pc_ora - $pc_spesi;
            $px_risparmiati = $px_ora - $px_spesi;

            if (!isset($data["pc_ora"][$pc_ora + ""]))
                $data["pc_ora"][$pc_ora + ""] = 0;

            if (!isset($data["px_ora"][$px_ora + ""]))
                $data["px_ora"][$px_ora + ""] = 0;

            if (!isset($data["pc_spesi"][$pc_spesi + ""]))
                $data["pc_spesi"][$pc_spesi + ""] = 0;

            if (!isset($data["px_spesi"][$px_spesi + ""]))
                $data["px_spesi"][$px_spesi + ""] = 0;

            if (!isset($data["pc_risparmiati"][$pc_risparmiati + ""]))
                $data["pc_risparmiati"][$pc_risparmiati + ""] = 0;

            if (!isset($data["px_risparmiati"][$px_risparmiati + ""]))
                $data["px_risparmiati"][$px_risparmiati + ""] = 0;

            $data["pc_ora"][$pc_ora + ""]++;
            $data["px_ora"][$px_ora + ""]++;
            $data["pc_spesi"][$pc_spesi + ""]++;
            $data["px_spesi"][$px_spesi + ""]++;
            $data["pc_risparmiati"][$pc_risparmiati + ""]++;
            $data["px_risparmiati"][$px_risparmiati + ""]++;
        }

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheQtaRavShop()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT COUNT(id_transazione) AS num_transazioni,
                       DATE_FORMAT(data_transazione,'%d/%m/%Y') AS data_transazione_str
                FROM transazioni_bit
                    JOIN personaggi AS pg ON pg.id_personaggio = debitore_transazione
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE id_acquisto_componente IS NOT NULL AND g.ruoli_nome_ruolo NOT IN ('staff','admin')
                GROUP BY data_transazione_str
                ORDER BY data_transazione";
        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheAcquistiRavShop()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT COUNT(id_acquisto) AS num_acquisti,
                       id_componente_acquisto,
                       comp.nome_componente
                FROM componenti_acquistati
                    JOIN personaggi AS pg ON pg.id_personaggio = cliente_acquisto
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                    JOIN componenti_crafting AS comp ON comp.id_componente = id_componente_acquisto
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin') 
                GROUP BY id_componente_acquisto
                ORDER BY num_acquisti DESC";
        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }

    public function recuperaStatisticheArmiStampate()
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);

        $sql = "SELECT COUNT(dichiarazione) AS QTA,
                       dichiarazione
                FROM (
                    SELECT 'DEVE DOPPIO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%DEVE dichiarare%' AND risultato_ricetta LIKE '%DOPPIO%'
                        UNION ALL
                    SELECT 'DEVE TRIPLO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%DEVE dichiarare%' AND risultato_ricetta LIKE '%TRIPO%'
                        UNION ALL
                    SELECT 'DEVE QUADRUPLO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%DEVE dichiarare%' AND risultato_ricetta LIKE '%QUADRUPLO%'
                        UNION ALL
                    SELECT 'PUO CRASH' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%CRASH%'
                        UNION ALL
                    SELECT 'PUO A ZERO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%A ZERO%'
                        UNION ALL
                    SELECT 'PUO DOLORE' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%può dichiarare%' AND risultato_ricetta LIKE '%DOLORE%'
                        UNION ALL
                    SELECT 'PUO FUOCO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%può dichiarare%' AND risultato_ricetta LIKE '%FUOCO%'
                        UNION ALL
                    SELECT 'PUO GELO' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%può dichiarare%' AND risultato_ricetta LIKE '%GELO%'
                        UNION ALL
                    SELECT 'PUO PARALISI' AS dichiarazione, personaggi_id_personaggio FROM ricette WHERE risultato_ricetta LIKE '%può dichiarare%' AND risultato_ricetta LIKE '%PARALISI%'
                ) AS d
                    JOIN personaggi AS pg ON pg.id_personaggio = d.personaggi_id_personaggio
                    JOIN giocatori AS g ON g.email_giocatore = pg.giocatori_email_giocatore
                WHERE g.ruoli_nome_ruolo NOT IN ('staff','admin')
                GROUP BY dichiarazione
                ORDER BY QTA DESC";
        $data = $this->db->doQuery($sql, $this->event_id, False);

        return json_encode(["status" => "ok", "data" => $data]);
    }
}
