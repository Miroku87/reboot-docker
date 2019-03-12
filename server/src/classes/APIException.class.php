<?php

class APIException extends Exception
{
    static $GENERIC_ERROR  = "genericError";
    static $GRANTS_ERROR   = "grantsError";
    static $LOGIN_ERROR    = "loginError";
    static $PG_LOGIN_ERROR = "pgLoginError";
    static $DATABASE_ERROR = "databaseError";
    
    protected $type;
    
    public function __construct( $message = "", $type = "error", $code = 0, Exception $previous = null )
    {
        $this->type = $type;
        
        parent::__construct($message, $code, $previous);
    }
    
    public function getType()
    {
        return $this->type;
    }
}