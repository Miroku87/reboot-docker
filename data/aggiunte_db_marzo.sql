ALTER TABLE `giocatori` 
ADD COLUMN `default_pg_giocatore` INT(11) NULL DEFAULT NULL AFTER `ruoli_nome_ruolo`,
ADD INDEX `fk_default_pg_idx` (`default_pg_giocatore` ASC);
ALTER TABLE `giocatori` 
ADD CONSTRAINT `fk_default_pg`
  FOREIGN KEY (`default_pg_giocatore`)
  REFERENCES `personaggi` (`id_personaggio`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaUtente_default_pg_giocatore_altri', 'L\'utente può modificare il PG di default di un altro utente');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaUtente_default_pg_giocatore_proprio', 'L\'utente può modificare il proprio PG di default ');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaUtente_default_pg_giocatore_altri');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaUtente_default_pg_giocatore_proprio');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'modificaUtente_default_pg_giocatore_altri');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'modificaUtente_default_pg_giocatore_proprio');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('giocatore', 'modificaUtente_default_pg_giocatore_proprio');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_gestione_componenti', 'L\'utente può visualizzare la pagina di gestione dei componenti');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_gestione_componenti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_gestione_componenti');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaComponenti', 'L\'utente può modificare le caratteristiche dei componenti del crafting');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaComponenti');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('eliminaComponenti', 'L\'utente può eliminare un componente dal database');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'eliminaComponenti');


ALTER TABLE `componenti_ricetta` 
DROP FOREIGN KEY `fk_componenti_id_componente`,
DROP FOREIGN KEY `fk_ricetta_id_ricetta`;
ALTER TABLE `componenti_ricetta` 
ADD CONSTRAINT `fk_componenti_id_componente`
  FOREIGN KEY (`componenti_crafting_id_componente`)
  REFERENCES `componenti_crafting` (`id_componente`)
  ON DELETE CASCADE
  ON UPDATE CASCADE,
ADD CONSTRAINT `fk_ricetta_id_ricetta`
  FOREIGN KEY (`ricette_id_ricetta`)
  REFERENCES `ricette` (`id_ricetta`)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `transazioni_bit` 
DROP FOREIGN KEY `fk_acq_comp`;
ALTER TABLE `transazioni_bit` 
ADD CONSTRAINT `fk_acq_comp`
  FOREIGN KEY (`id_acquisto_componente`)
  REFERENCES `componenti_acquistati` (`id_acquisto`)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;

ALTER TABLE `componenti_acquistati` 
DROP FOREIGN KEY `fk_id_comp_acq`;
ALTER TABLE `componenti_acquistati` 
CHANGE COLUMN `id_componente_acquisto` `id_componente_acquisto` VARCHAR(255) CHARACTER SET 'utf8' NULL ;
ALTER TABLE `componenti_acquistati` 
ADD CONSTRAINT `fk_id_comp_acq`
  FOREIGN KEY (`id_componente_acquisto`)
  REFERENCES `componenti_crafting` (`id_componente`)
  ON DELETE SET NULL
  ON UPDATE CASCADE;

-- BRANCH gestione_cartellini

CREATE TABLE `cartellini` (
  `id_cartellino` int(11) NOT NULL AUTO_INCREMENT,
  `data_creazione_cartellino` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_cartellino` varchar(255) NOT NULL,
  `titolo_cartellino` varchar(255) NOT NULL,
  `descrizione_cartellino` text NOT NULL,
  `icona_cartellino` varchar(255) DEFAULT NULL,
  `testata_cartellino` varchar(255) DEFAULT NULL,
  `piepagina_cartellino` varchar(255) DEFAULT NULL,
  `costo_attuale_ravshop_cartellino` int(255) DEFAULT NULL, 
  `costo_vecchio_ravshop_cartellino` int(255) DEFAULT NULL,
  `approvato_cartellino` TINYINT NOT NULL DEFAULT 0,
  `nome_modello_cartellino` varchar(255) DEFAULT NULL,
  `attenzione_cartellino` TINYINT NOT NULL DEFAULT 0,
  `creatore_cartellino` VARCHAR(255) NOT NULL DEFAULT 'rebootlivebg@gmail.com',
  PRIMARY KEY (`id_cartellino`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cartellino_has_etichette` (
  `cartellini_id_cartellino` INT(11) NOT NULL,
  `etichetta` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`cartellini_id_cartellino`, `etichetta`),
  CONSTRAINT `fk_cartellino`
    FOREIGN KEY (`cartellini_id_cartellino`)
    REFERENCES `cartellini` (`id_cartellino`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);
	

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_gestione_cartellini', 'L\'utente può accedere alla pagina di gestione dei cartellini');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('creaCartellino', 'L\'utente può creare cartellini');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaCartellino', 'L\'utente può modificare cartellini');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('eliminaCartellino', 'L\'utente può eliminare cartellini');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('associazioneCartellinoTrama', 'L\'utente può associare cartellini alle trame');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('associazioneCartellinoEtichette', 'L\'utente può associare cartellini alle etichette');


INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_gestione_cartellini');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'creaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'eliminaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'associazioneCartellinoTrama');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'associazioneCartellinoEtichette');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_gestione_cartellini');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'creaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'modificaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'eliminaCartellino');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'associazioneCartellinoTrama');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'associazioneCartellinoEtichette');


INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('approvaCartellino', 'L\'utente può approvare cartellini creati');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'creaCartellino');

CREATE TABLE `reboot_live`.`trame_has_etichette` (
  `trame_id_trama` INT(11) NOT NULL,
  `etichetta` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`trame_id_trama`));

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaModelli', 'L\'utente può listare i modelli per creare i cartellini');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaTagsUnici', 'L\'utente può recuperare tutti i tag precedentemente inseriti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaModelli');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaTagsUnici');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaModelli');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaTagsUnici');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_stampa_cartellini', 'L\'utente può visualizzare la pagina di stampa dei cartellini');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_stampa_cartellini');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_stampa_cartellini');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('inserisciComponente', 'L\'utente può inserire nuovi componenti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'inserisciComponente');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'inserisciComponente');

ALTER TABLE `reboot_live`.`componenti_crafting` 
CHANGE COLUMN `costo_attuale_componente` `costo_attuale_componente` INT(255) NOT NULL DEFAULT 0 ,
CHANGE COLUMN `costo_vecchio_componente` `costo_vecchio_componente` INT(255) NOT NULL DEFAULT 0 ,
ADD COLUMN `visibile_ravshop_componente` TINYINT(1) NOT NULL DEFAULT 1 AFTER `costo_vecchio_componente`;


ALTER TABLE `reboot_live`.`ricette` 
ADD COLUMN `in_ravshop_ricetta` TINYINT(1) NOT NULL DEFAULT 0 AFTER `extra_cartellino_ricetta`,
ADD COLUMN `disponibilita_ravshop_ricetta` INT(255) NULL DEFAULT 1 AFTER `in_ravshop_ricetta`,
ADD COLUMN `costo_attuale_ricetta` INT(255) NULL DEFAULT NULL AFTER `disponibilita_ravshop_ricetta`,
ADD COLUMN `costo_vecchio_ricetta` INT(255) NULL DEFAULT NULL AFTER `costo_attuale_ricetta`;


INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaComponentiAvanzato', 'L\'utente può vedere tutti i campi della tabella dei componenti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaComponentiAvanzato');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaComponentiAvanzato');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_mercato_oggetti', 'L\'utente può accedere alla pagina del Ravshop Oggetti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_mercato_oggetti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_mercato_oggetti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('giocatore', 'visualizza_pagina_mercato_oggetti');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaRicettePerRavshop', 'L\'utente può recuperare gli oggetti craftati venudti nel ravshop');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaRicettePerRavshop');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaRicettePerRavshop');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('giocatore', 'recuperaRicettePerRavshop');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('compraOggetti', 'L\'utente può comprare gli oggetti craftati venudti nel ravshop');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'compraOggetti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'compraOggetti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('giocatore', 'compraOggetti');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('creaPNG', 'L\'utente può creare personaggi non giocanti');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'creaPNG');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'creaPNG');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaUtentiStaffer', 'L\'utente può ricevere dal DB la lista degli staffer');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaUtentiStaffer');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaUtentiStaffer');
















