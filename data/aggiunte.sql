ALTER TABLE `giocatori` 
COLLATE = utf8_general_ci ;

CREATE TABLE `rumors` (
  `id_rumor` INT(255) NOT NULL AUTO_INCREMENT,
  `luogo_ig_rumor` VARCHAR(255) NULL,
  `testo_rumor` TEXT NULL,
  `data_ig_rumor` VARCHAR(255) NULL,
  `data_pubblicazione_rumor` DATE NULL,
  `ora_pubblicazione_rumor` TIME NULL,
  `eventi_id_evento` INT(255) NULL DEFAULT NULL,
  `is_bozza_rumor` TINYINT(1) NULL,
  `approvato_rumor` TINYINT(1) NOT NULL DEFAULT 0,
  `creatore_rumor` VARCHAR(255) NULL,
  `data_creazione` DATETIME NOT NULL,
  PRIMARY KEY (`id_rumor`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;

ALTER TABLE `rumors` 
ADD CONSTRAINT `fk_evento`
  FOREIGN KEY (`eventi_id_evento`)
  REFERENCES `eventi` (`id_evento`)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;

ALTER TABLE `rumors` 
ADD CONSTRAINT `fk_creatore`
  FOREIGN KEY (`creatore_rumor`)
  REFERENCES `giocatori` (`email_giocatore`)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;


INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_gestione_rumors', 'L\'utente può accedere alla pagina della gestione dei rumors.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaListaRumors', 'L\'utente può recuperare i rumors inseriti a database.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('approvaRumor', 'L\'utente può approvare un rumor.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaRumor_proprio', 'L\'utente può modificare un proprio rumor.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('inserisciRumor', 'L\'utente può creare un rumor.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('eliminaRumor_proprio', 'L\'utente può eliminare un proprio rumor.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('modificaRumor_altri', 'L\'utente può modificare un rumor altrui.');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('eliminaRumor_altri', 'L\'utente può modificare un rumor altrui.');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_gestione_rumors');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaListaRumors');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaRumor_proprio');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'inserisciRumor');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'eliminaRumor_proprio');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'modificaRumor_altri');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'eliminaRumor_altri');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'approvaRumor');

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_gestione_rumors');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaListaRumors');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'modificaRumor_proprio');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'inserisciRumor');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'eliminaRumor_proprio');
