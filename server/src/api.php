<?php
$path = $_SERVER['DOCUMENT_ROOT']."/";

include_once( $path."classes/APIException.class.php" );
include_once( $path."classes/UsersManager.class.php" );
include_once( $path."classes/CharactersManager.class.php" );
include_once( $path."classes/MessagingManager.class.php" );
include_once( $path."classes/EventsManager.class.php" );
include_once( $path."classes/GrantsManager.class.php" );
include_once( $path."classes/NewsManager.class.php" );
include_once( $path."classes/CraftingManager.class.php" );
include_once( $path."classes/TransactionManager.class.php" );
include_once( $path."classes/Statistics.class.php" );
include_once( $path."config/constants.php" );

class Main
{
	protected $usersmanager;
	protected $charactersmanager;
	protected $messagingmanager;
	protected $eventsmanager;
	protected $grantsmanager;
	protected $newsmanager;
	protected $craftingmanager;
	protected $transactionmanager;
	protected $statistics;

	public function __construct()
	{
	    global $ALLOWED_ORIGINS;

		ini_set( 'html_errors', false );

		date_default_timezone_set( 'Europe/Rome' );

		header( 'Content-Type: application/json;charset=UTF-8' );
		header( 'Access-Control-Allow-Credentials: true' );

		if( in_array( @$_SERVER["HTTP_ORIGIN"], $ALLOWED_ORIGINS ) )
            header( 'Access-Control-Allow-Origin: '.$_SERVER["HTTP_ORIGIN"] );

        $this->eventsmanager     = new EventsManager();
        $idev_in_corso = $this->eventsmanager->recuperaEventoInCorso();

		$this->usersmanager       = new UsersManager( $idev_in_corso );
		$this->charactersmanager  = new CharactersManager( $idev_in_corso );
		$this->messagingmanager   = new MessagingManager( $idev_in_corso );
		$this->grantsmanager      = new GrantsManager();
		$this->newsmanager        = new NewsManager( $idev_in_corso );
		$this->craftingmanager    = new CraftingManager( $idev_in_corso );
		$this->transactionmanager = new TransactionManager( $this->charactersmanager, $idev_in_corso );
		$this->statistics         = new Statistics( $this->charactersmanager );
	}

	public function __destruct()
	{
	}

	public function runAPI()
	{
	    global $DEBUG;
	    global $MAINTENANCE;
        global $MESSAGGIO_CHIUSURA;
	    global $IP_MAINTAINER;

		$method  = $_SERVER['REQUEST_METHOD'];
		$request = explode( '/', trim( $_SERVER['PATH_INFO'], '/' ) );
		$classe  = $request[0];
		$func    = $request[1];
		$data    = [];

		try
		{
            if( $MAINTENANCE && !in_array( Utils::getUserIP(), $IP_MAINTAINER) )
                throw new APIException("Ci scusiamo, ma al momento il database &egrave; in manutenzione. Per favore attendi comunicazioni dallo Staff.");

			if( $method == "GET" )        $data = $_GET;
			else if ( $method == "POST" ) $data = $_POST;

			return call_user_func_array( array( $this->$classe, $func ), $data );
		}
		catch( Exception $e )
		{
		    $mex = $e->getMessage();

            if( $DEBUG )
                $mex .= " \n".$e->getTraceAsString();

		    if( method_exists($e,'getType') )
		        $err = Utils::errorJSON( $mex, $e->getType() );
		    else
                $err = Utils::errorJSON( $mex );

			return $err;
		}
	}
}

$main = new Main();
echo $main->runAPI();
