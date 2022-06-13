<?php

$path = $_SERVER['DOCUMENT_ROOT'] . "/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/UsersManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");

class AbilitiesManager
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

    public function recuperaAbilita($draw, $columns, $order, $start, $length, $search)
    {
        UsersManager::operazionePossibile($this->session, __FUNCTION__);
        $filter = False;
        $params = [];

        if (isset($search) && isset($search["value"]) && $search["value"] != "") {
            $filter = True;
            $params[":search"] = "%$search[value]%";
            $where[] = " (
						a1.id_abilita LIKE :search OR
						a1.tipo_abilita LIKE :search OR
						a1.nome_abilita LIKE :search OR
						a1.descrizione_abilita LIKE :search OR
						a1.costo_abilita LIKE :search OR
						a1.prerequisito_abilita LIKE :search OR
						a1.distanza_abilita LIKE :search OR
						a1.effetto_abilita LIKE :search
					  )";
        }

        if (isset($order) && !empty($order) && count($order) > 0) {
            $sorting = array();
            foreach ($order as $elem) {
                $colonna = $columns[$elem["column"]]["data"];
                $sorting[] = "a1." . $colonna . " " . $elem["dir"];
            }
            $order_str = "ORDER BY " . implode(",", $sorting);
        }

        if (count($where) > 0)
            $where = "WHERE " . implode(" AND ", $where);
        else
            $where = "";

        $query_abilita = "SELECT 
                                a1.*, 
                                a2.nome_abilita nome_prerequisito_abilita, 
                                c.nome_classe nome_classe_abilita 
                            FROM abilita a1
                            LEFT JOIN abilita a2 ON a1.prerequisito_abilita > 0 AND a1.prerequisito_abilita = a2.id_abilita
                            JOIN classi c ON a1.classi_id_classe = c.id_classe
                            $where $order_str";
        $abilita       = $this->db->doQuery($query_abilita, $params, False);

        $result = [];
        if (count($abilita) > 0)
            $result = array_splice($abilita, $start, $length);
        else
            $result = array();

        $output = [
            "status" => "ok",
            "draw" => $draw,
            "columns" => $columns,
            "order" => $order,
            "start" => $start,
            "length" => $length,
            "search" => $search,
            "recordsTotal" => count($abilita),
            "recordsFiltered" =>  $filter ? count($result) : count($abilita),
            "data" => $result
        ];

        return json_encode($output);
    }
}
