<?php
$path = $_SERVER['DOCUMENT_ROOT']."/";
include_once($path."classes/APIException.class.php");
include_once($path."config/config.inc.php");

class DatabaseBridge extends PDO
{
	public function __construct()
	{
	}

	public function __destruct()
	{
	}

	private function connect()
	{
		global $DB_DATA;
		$dns = $DB_DATA["DB_DRIVER"] . ':host=' . $DB_DATA["DB_HOST"] . ';dbname=' . $DB_DATA["DB_NAME"] . ';charset=utf8';

        try
		{
			$connection = new PDO( $dns, $DB_DATA["DB_USER"], $DB_DATA["DB_PASS"] );
			$connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION );
            $connection->setAttribute(PDO::ATTR_STRINGIFY_FETCHES, false );
            $connection->setAttribute(PDO::MYSQL_ATTR_INIT_COMMAND, "SET NAMES 'utf8'" );
		}
		catch (PDOException $e)
		{
			die( "{\"status\":\"error\", \"message\":\"".$e->getMessage()."\"}" );
		}

		return $connection;
	}

    /**
     * @param string $query
     * @param Array $params
     * @param bool $to_json
     * @return array|bool|string
     * @throws Exception
     */
	public function doQuery( $query, $params, $to_json = True )
	{
	    global $DB_ERR_DELIMITATORE;

		if( !is_array( $params ) )
			throw new APIException("$query<br><br>I parametri passati devono essere sotto forma di array di traduzione PDO. Il valore passato non lo è: ".$params, APIException::$DATABASE_ERROR);

		$query = str_replace("\n","",$query);
		$query = str_replace("\r","",$query);
		$query = preg_replace("/\s+/"," ",$query);

		try {
            $conn = $this->connect();
            $stmnt = $conn->prepare($query);

            $stmnt->execute($params);

//            $stmnt->debugDumpParams();

            if ($stmnt->columnCount() !== 0)
                $result = $stmnt->fetchAll(PDO::FETCH_ASSOC);
            else if ($stmnt->columnCount() === 0 && $conn->lastInsertId() !== 0) {
                $result = $conn->lastInsertId();
                $to_json = False;
            } else if ($stmnt->columnCount() === 0 && $conn->lastInsertId() === 0) {
                $result = True;
                $to_json = False;
            }

            $stmnt->closeCursor(); // this is not even required
            $stmnt = null; // doing this is mandatory for connection to get closed
            $conn  = null;

            if ($result && !$to_json)
                return $result;
            else if ($result && $to_json)
                return json_encode($result);
        }
        catch( Exception $e )
        {
            throw new APIException($e->getCode().$DB_ERR_DELIMITATORE.$query."<br>".$e->getMessage(),APIException::$DATABASE_ERROR);
        }
	}

	public function doMultipleManipulations( $query, $params, $to_json = True )
	{
		if( !is_array( $params ) || ( is_array( $params ) && !is_array( $params[0] ) ) )
			throw new APIException("I parametri passati devono essere sotto forma di array di traduzione PDO a due dimensioni.", APIException::$DATABASE_ERROR);

        try {
            $conn   = $this->connect();
            $stmnt  = $conn->prepare( $query );

            foreach( $params as $p )
                $stmnt->execute( $p );

            $stmnt->closeCursor(); // this is not even required
            $stmnt = null; // doing this is mandatory for connection to get closed
            $conn  = null;

            return True;
        }
        catch( Exception $e )
        {
            throw new APIException(str_replace("\n","",$query )."<br>".$e->getMessage(), APIException::$DATABASE_ERROR);
        }
	}
}
