

ALTER TABLE `ricette` 
ADD COLUMN `in_ravshop_ricetta` TINYINT(1) NULL, 
ADD COLUMN `costo_attuale_ricetta` VARCHAR(45) NULL,
ADD COLUMN `disponibilita_ravshop_ricetta` INT(255) NULL AFTER `extra_cartellino_ricetta`;

ALTER TABLE `componenti_crafting` 
ADD COLUMN `visibile_ravshop_componente` VARCHAR(45) NULL AFTER `tipo_applicativo_componente`;


UPDATE `grants` SET `nome_grant`='recuperaComponentiAvanzato' WHERE `nome_grant`='recuperaComponentiAvanzata';

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaModelli', 'L\'utente può recuperare i modelli di cartellini dal database');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaModelli');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaModelli');

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('inserisciComponente', 'L\'utente può inserire un nuovo componente crafting all\'interno del database.');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'inserisciComponente');


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
  `approvato_cartellino` tinyint(4) NOT NULL DEFAULT '0',
  `nome_modello_cartellino` varchar(255) DEFAULT NULL,
  `attenzione_cartellino` tinyint(4) NOT NULL DEFAULT '0',
  `creatore_cartellino` varchar(255) NOT NULL DEFAULT 'rebootlivebg@gmail.com',
  PRIMARY KEY (`id_cartellino`)
) ENGINE=InnoDB AUTO_INCREMENT=212 DEFAULT CHARSET=latin1;

CREATE TABLE `cartellino_has_etichette` (
  `cartellini_id_cartellino` int(11) NOT NULL,
  `etichetta` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`cartellini_id_cartellino`,`etichetta`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;