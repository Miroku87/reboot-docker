# Reboot Live API

## Prerequisiti
* [Git](https://git-scm.com/)
* [NodeJS 4+](https://nodejs.org/it/download/current/) (solo per fare le build)
* NPM (Si installa automaticamente assieme a NodeJS) (solo per fare le build)
* [Grunt CLI](https://gruntjs.com/getting-started#installing-the-cli) (solo per fare le build)
* [PHP](http://www.php.net/)
* [Apache](https://httpd.apache.org/)
* [MySQL](https://www.mysql.com/it/)


## Installazione
Clonare questa repository nella folder `htdocs` o `www` di apache.
Una volta terminato il trasferimento installare tutti i pacchetti di NodeJS:
```
npm install
```
Importare il database tramite il file .sql con la versione più alta trovato nella cartella `data`.
Recuperare il file `gruntconfig.json`, con tutte le password, dalla repository privata (il pc di Andre =D).

## Avvio

* Avviare il server Apache
* Avviare il demone MySQL
