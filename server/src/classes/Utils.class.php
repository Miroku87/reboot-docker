<?php

class Utils
{
    static function errorJSON($msg, $type = "genericError")
    {
        $json = array(
            "status" => "error",
            "type" => $type,
            "message" => $msg
        );

        return json_encode($json);
    }

    static function mappaPermessiUtente($item)
    {
        return $item["permessi"];
    }

    static function mappaPGUtente($item)
    {
        return $item["id_personaggio"];
    }

    static function mappaRisultatoJson($item)
    {
        return $item["json"];
    }

    static function mappaId($item)
    {
        return $item["id"];
    }

    static function mappaIdAbilita($item)
    {
        return $item["id_abilita"];
    }

    static function mappaOffsetPFAbilita($item)
    {
        return $item["offset_pf_abilita"];
    }

    static function mappaCheckbox($item)
    {
        return $item == "on" ? 1 : 0;
    }

    static function mappaArrayDiArrayAssoc($arr, $key)
    {
        $mappa = function ($item) use ($key) {
            return $item[$key];
        };

        return array_map($mappa, $arr);
    }

    static function filtraArrayConValori($arr, $valori)
    {
        $filtro = function ($item) use ($valori) {
            return in_array($item, $valori);
        };

        return array_filter($arr, $filtro);
    }

    static function filtraArrayDiArrayAssoc($arr, $key, $valori)
    {
        $filtro = function ( $item ) use ($key, $valori)
        {
            return in_array( $item[$key], $valori );
        };

        return array_values( array_filter($arr, $filtro) );
    }

    /*static function filtraArrayConChiavi( $arr, $chiavi )
    {
        $filtro = function ( $key ) use ( $chiavi )
        {
            return in_array($key, $chiavi);
        };

        return array_filter($arr, $filtro, ARRAY_FILTER_USE_KEY);
    }*/

    static function filtraArrayConChiavi($arr, $chiavi)
    {
        $newarr = [];

        if (count($arr) > 0)
        {
            foreach ($arr as $k => $v)
            {
                if (in_array($k, $chiavi))
                    $newarr[$k] = $v;
            }
        }

        return $newarr;
    }

    static function filtraClasseSenzaPrerequisito($item)
    {
        return $item["prerequisito_classe"] != NULL;
    }

    static function filtraAbilitaSenzaPrerequisito($item)
    {
        return $item["prerequisito_abilita"] != NULL;
    }

    static function filtraAbilitaSportivo($item)
    {
        global $ID_CLASSE_SPORTIVO;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_SPORTIVO;
    }

    static function filtraAbilitaGuardianoBase($item)
    {
        global $ID_CLASSE_GUARDIANO_BASE;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_GUARDIANO_BASE;
    }

    static function filtraAbilitaGuardianoAvanzato($item)
    {
        global $ID_CLASSE_GUARDIANO_AVANZATO;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_GUARDIANO_AVANZATO;
    }

    static function filtraAbilitaAssaltatoreBase($item)
    {
        global $ID_CLASSE_ASSALTATORE_BASE;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_ASSALTATORE_BASE;
    }

    static function filtraAbilitaAssaltatoreAvanzato($item)
    {
        global $ID_CLASSE_ASSALTATORE_AVANZATO;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_ASSALTATORE_AVANZATO;
    }

    static function filtraAbilitaSupportoBase($item)
    {
        global $ID_CLASSE_SUPPORTO_BASE;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_SUPPORTO_BASE;
    }

    static function filtraAbilitaSupportoAvanzato($item)
    {
        global $ID_CLASSE_SUPPORTO_AVANZATO;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_SUPPORTO_AVANZATO;
    }

    static function filtraAbilitaGuastatoreBase($item)
    {
        global $ID_CLASSE_GUASTATORE_BASE;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_GUASTATORE_BASE;
    }

    static function filtraAbilitaGuastatoreAvanzato($item)
    {
        global $ID_CLASSE_GUASTATORE_AVANZATO;

        return (int)$item["classi_id_classe"] === $ID_CLASSE_GUASTATORE_AVANZATO;
    }

    static function rimuoviElementoArrayMultidimensionale(&$arr, $chiave, $valore)
    {
        foreach ($arr as $i => $a)
        {
            if ($a[$chiave] === $valore)
            {
                array_splice($arr, $i, 1);
                break;
            }
        }
    }

    static function rimuoviPiuElementiDaArray(&$arr, $elems)
    {
        if( count($elems) > 0 )
        {
            foreach ($elems as $e)
            {
                $i = array_search($e, $arr);
                if ($i !== False)
                    array_splice($arr, $i, 1);
            }
        }
    }

    static function generatePassword($length = 8)
    {
        $alphabet = "abcdefghijklmnopqrstuwxyzABCDEFGHIJKLMNOPQRSTUWXYZ0123456789";
        $pass = array();
        $alphaLength = strlen($alphabet) - 1;

        for ($i = 0; $i < $length; $i++)
        {
            $n = rand(0, $alphaLength);
            $pass[] = $alphabet[$n];
        }
        return implode($pass);
    }

    static function controllaCF($cf)
    {
        $pattern = "/^[a-zA-Z]{6}[0-9]{2}[a-zA-Z][0-9]{2}[a-zA-Z][0-9]{3}[a-zA-Z]$/";

        return preg_match($pattern, $cf);
    }

    static function controllaMail($mail)
    {
        $pattern = "/^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/";

        return preg_match($pattern, $mail);
    }

    static function soloSpazi($stringa)
    {
        $pattern = "/^\s+$/";

        return preg_match($pattern, $stringa);
    }

    static function utf8ize($d)
    {
        if (is_array($d))
        {
            foreach ($d as $k => $v)
            {
                $d[$k] = self::utf8ize($v);
            }
        }
        else if (is_string($d))
        {
            return utf8_encode($d);
        }
        return $d;
    }

    static function getUserIP()
    {
        $client = @$_SERVER['HTTP_CLIENT_IP'];
        $forward = @$_SERVER['HTTP_X_FORWARDED_FOR'];
        $remote = $_SERVER['REMOTE_ADDR'];

        if (filter_var($client, FILTER_VALIDATE_IP))
        {
            $ip = $client;
        }
        elseif (filter_var($forward, FILTER_VALIDATE_IP))
        {
            $ip = $forward;
        }
        else
        {
            $ip = $remote;
        }

        return $ip;
    }

    /**
     * Check if a client IP is in our Server subnet
     *
     * @return boolean
     */
    static function clientInSameLAN($client_ip = false, $server_ip = false)
    {
        // if (!$client_ip)
            // $client_ip = $_SERVER['REMOTE_ADDR'];
        // if (!$server_ip)
            // $server_ip = $_SERVER['SERVER_ADDR'];

        // if( !preg_match("/^192\.168\./", $client_ip) )
            // return False;

        // if( !preg_match("/^192\.168\./", $server_ip) )
            // return False;

        return True;
    }

    static function filterDataTableResults($draw, $columns, $order, $start, $length, $search, $query_res)
    {
        $output = [
            "status" => "ok",
            "draw" => $draw,
            "columns" => $columns,
            "order" => $order,
            "start" => $start,
            "length" => $length,
            "search" => $search,
            "recordsTotal" => count($query_res),
            "recordsFiltered" => 0,
            "data" => []
        ];

        if (count($query_res) == 0) {
            return $output;
        }

        $filtered = array();

        if (isset($search) && isset($search["value"]) && $search["value"] != "") {
            $ricerca = $search["value"];

            foreach($query_res as $row) {
                foreach($row as $campo => $valore) {
                    if (stripos($valore, $ricerca) !== False) {
                        $filtered[] = $row;
                        break 1;
                    }
                } 
            }
        } else {
            $filtered = $query_res;
        }

        if (count($filtered) > 0)
            $result = array_slice($filtered, $start, $length);

        $output["recordsFiltered"] = count($filtered);
        $output["data"] = $result;

        return $output;
    }
}
