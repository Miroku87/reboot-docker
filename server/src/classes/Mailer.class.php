<?php
$path = $_SERVER['DOCUMENT_ROOT']."/";
include_once($path . "classes/APIException.class.php");
include_once($path . "classes/SessionManager.class.php");
include_once($path . "classes/DatabaseBridge.class.php");
include_once($path . "classes/Utils.class.php");
include_once($path . "config/constants.php");
include_once($path . "phpmailer/Exception.php");
include_once($path . "phpmailer/PHPMailer.php");
include_once($path . "phpmailer/SMTP.php");

use PHPMailer\PHPMailer\PHPMailer;

class Mailer
{
    protected $session;
    protected $db;

    public function __construct()
    {
        $this->session = SessionManager::getInstance();
        $this->db = new DatabaseBridge();
    }

    public function __destruct()
    {
    }

    private function impostaMailer()
    {
        global $MAIL_ACCOUNT;
        global $MAIL_MITTENTE_INDIRIZZO;
        global $MAIL_MITTENTE_NOME;
        global $MAIL_PASSWORD;
        global $MAIL_HOST;
        global $MAIL_PORT;

        //Create a new PHPMailer instance
        $mail = new PHPMailer(true);
        //Tell PHPMailer to use SMTP
        $mail->isSMTP();
        //Enable SMTP debugging
        // 0 = off (for production use)
        // 1 = client messages
        // 2 = client and server messages
        $mail->SMTPDebug = 0;
        //Set the hostname of the mail server
        $mail->Host = $MAIL_HOST;
        // use
        // $mail->Host = gethostbyname('smtp.gmail.com');
        // if your network does not support SMTP over IPv6
        //Set the SMTP port number - 587 for authenticated TLS, a.k.a. RFC4409 SMTP submission
        $mail->Port = $MAIL_PORT;
        //Set the encryption system to use - ssl (deprecated) or tls
        $mail->SMTPSecure = 'tls';
        //Whether to use SMTP authentication
        $mail->SMTPAuth = true;
        $mail->AuthType = 'LOGIN';
        //Username to use for SMTP authentication - use full email address for gmail
        $mail->Username = $MAIL_ACCOUNT;
        //Password to use for SMTP authentication
        $mail->Password = $MAIL_PASSWORD;
        //Set who the message is to be sent from
        $mail->setFrom($MAIL_MITTENTE_INDIRIZZO, $MAIL_MITTENTE_NOME);
        //Set an alternative reply-to address
        $mail->addReplyTo($MAIL_MITTENTE_INDIRIZZO, $MAIL_MITTENTE_NOME);

        return $mail;
    }

    public function inviaMailRegistrazione( $dest_indirizzo, $dest_nome, $pass )
    {
        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        $mail->addAddress($dest_indirizzo, $dest_nome);
        //Set the subject line
        $mail->Subject = 'Reboot Live: Registrazione Giocatore';
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $mail->msgHTML( "Gentile giocatore,<br>
                         ti informiamo che il tuo account &egrave; stato creato.<br><br>
                         Qui di seguito i dati di accesso:<br>
                         <b>Nome Utente:</b> $dest_indirizzo<br>
                         <b>Password:</b> $pass" );
        //Replace the plain text body with one created manually
        $mail->AltBody = "Gentile giocatore,
                         ti informiamo che il tuo account e' stato creato.

                         Qui di seguito i dati di accesso:
                         Nome Utente: $dest_indirizzo
                         Password: $pass";

        $mail->send();
    }

    public function inviaMailDatiAccesso( $dest_indirizzo, $dest_nome, $pass )
    {
        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        $mail->addAddress($dest_indirizzo, $dest_nome);
        //Set the subject line
        $mail->Subject = 'Reboot Live: Dati Accesso';
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $mail->msgHTML( "Gentile giocatore,<br>
                         qui di seguito troverai i tuoi dati di accesso:<br><br>
                         <b>Nome Utente:</b> $dest_indirizzo<br>
                         <b>Password:</b> $pass" );
        //Replace the plain text body with one created manually
        $mail->AltBody = "Gentile giocatore,
                         qui di seguito troverai i tuoi dati di accesso:
                         Nome Utente: $dest_indirizzo
                         Password: $pass";

        $mail->send();
    }

    public function inviaAvvisoPunti( $pg_id, $old_pc = NULL, $new_pc = NULL, $old_px = NULL, $new_px = NULL )
    {
        if( !isset($old_pc) && !isset($new_pc) && !isset($old_px) && !isset($new_px) )
            return False;

        $info_dest = "SELECT pg.nome_personaggio, gi.email_giocatore, CONCAT(gi.nome_giocatore,' ',gi.cognome_giocatore) AS nome_completo FROM personaggi AS pg
                      JOIN giocatori AS gi ON pg.giocatori_email_giocatore = gi.email_giocatore
                      WHERE id_personaggio = :pgid";
        $info      = $this->db->doQuery($info_dest, [":pgid"=>$pg_id], False);

        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        $mail->addAddress($info[0]["email_giocatore"], $info[0]["nome_completo"]);
        //Set the subject line
        $mail->Subject = 'Reboot Live: Punteggi Modificati';
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $html = "Gentile giocatore,<br>
                         ti avvisiamo che i punteggi per il tuo personaggio <b>".$info[0]["nome_personaggio"]."</b> con id <b>$pg_id</b> sono stati modificati:<br>";
        $txt = "Gentile giocatore,
                         ti avvisiamo che i tuoi punteggi sono stati modificati:\n";

        if(isset($old_pc) && isset($new_pc))
        {
            $html .= "<br><b>Punti Combattimento:</b> da $old_pc a $new_pc";
            $txt .= "\nPunti Combattimento: da $old_pc a $new_pc";
        }

        if(isset($old_px) && isset($new_px))
        {
            $html .= "<br><b>Punti Esperienza:</b> da $old_px a $new_px";
            $txt .= "\nPunti Combattimento: da $old_px a $new_px";
        }

        $mail->msgHTML( $html );
        //Replace the plain text body with one created manually
        $mail->AltBody = $txt;

        $mail->send();
    }

    public function inviaAvvisoBackground( $pgid )
    {
        global $MAIL_MITTENTE_INDIRIZZO;
        global $MAIL_MITTENTE_NOME;
        global $SITE_URL ;

        $pg_url = "$SITE_URL?r=scheda_pg&i=$pgid";

        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        $mail->addAddress($MAIL_MITTENTE_INDIRIZZO, $MAIL_MITTENTE_NOME);
        //Set the subject line
        $mail->Subject = 'Reboot Live: Un personaggio ha aggiunto il proprio background';
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $mail->msgHTML( "Ehi Staff!<br>
                         Un personaggio ha appena aggiunto il proprio background.<br>
                         Clicca il link seguente per andare direttamente al suo profilo:<br>
                         <a href='$pg_url'>$pg_url</a>" );
        //Replace the plain text body with one created manually
        $mail->AltBody = "Ehi Staff!
                         Un personaggio ha appena aggiunto il proprio background.
                         Vai al link seguente per vedere direttamente il suo profilo:
                         $pg_url";

        $mail->send();
    }

    public function inviaAvvisoEvento( )
    {
        $query_mails = "SELECT email_giocatore, CONCAT(nome_giocatore,' ',cognome_giocatore) AS nome_completo FROM giocatori WHERE eliminato_giocatore = 0";
        $lista       = $this->db->doQuery($query_mails, [], False );

        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        if( isset($lista) && count($lista) > 0 )
        {
            foreach ($lista as $l)
                $mail->addBCC($l["email_giocatore"], $l["nome_completo"]);

            //Set the subject line
            $mail->Subject = 'Reboot Live: E\' stato pubblicato un evento live!';
            //Read an HTML message body from an external file, convert referenced images to embedded,
            //convert HTML into a basic plain-text alternative body
            $mail->msgHTML("Gentile Giocatore,<br>
                         ti comunichiamo che lo staff di Reboot Live ha appena pubblicato un nuovo evento.<br>
                         Sappi che da ora in poi potrai iscriverti nell'apposita sezione del database.");
            //Replace the plain text body with one created manually
            $mail->AltBody = "Gentile Giocatore,
                         ti comunichiamo che lo staff di Reboot Live ha appena pubblicato un nuovo evento.
                         Sappi che da ora in poi potrai iscriverti nell'apposita sezione del database.";

            $mail->send();
        }
    }

    public function inviaAvvisoIscrizione( $giocatore, $pg_nome, $note, $pg_id, $nome_evento, $note_iscr = NULL )
    {
        global $MAIL_MITTENTE_INDIRIZZO;
        global $MAIL_MITTENTE_NOME;

        $mail = $this->impostaMailer();
        //Set who the message is to be sent to
        $mail->addAddress($MAIL_MITTENTE_INDIRIZZO, $MAIL_MITTENTE_NOME);
        //Set who the message is to be sent to
        //Set the subject line
        $mail->Subject = "Reboot Live: $giocatore si e\' iscritto a $nome_evento";
        //Read an HTML message body from an external file, convert referenced images to embedded,
        //convert HTML into a basic plain-text alternative body
        $html = "Ehi Staff!<br>
                     <strong>$giocatore</strong> ha appena iscritto il suo personaggio <strong>$pg_nome</strong> con id <strong>$pg_id</strong><br>
                     all'evento <strong>$nome_evento</strong>.";
        $txt  = "Ehi Staff!
                     $giocatore ha appena iscritto il suo personaggio $pg_nome con id $pg_id
                     all'evento $nome_evento.";

        if( isset($note) && !empty($note) )
        {
            $html .= "<br><br>ATTENZIONE: questo giocatore ha inserito delle note in fase di registrazione:<br>$note";
            $txt  .= "\n\nATTENZIONE: questo giocatore ha inserito delle note in fase di registrazione:\n$note";
        }

        if( isset($note_iscr) && !empty($note_iscr) )
        {
            $html .= "<br><br>ATTENZIONE: questo giocatore ha inserito delle note in fase di <b>iscrizione</b>:<br>$note_iscr";
            $txt  .= "\n\nATTENZIONE: questo giocatore ha inserito delle note in fase di iscrizione:\n$note_iscr";
        }

        $mail->msgHTML($html);
        //Replace the plain text body with one created manually
        $mail->AltBody = $txt;

        $mail->send();
    }
}
