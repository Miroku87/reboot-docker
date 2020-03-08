
-- MESSAGGI -> CONVERSAZIONI

ALTER TABLE `reboot_live`.`messaggi_ingioco` 
ADD COLUMN `id_conversazione` INT(255) NOT NULL DEFAULT 0 AFTER `risposta_a_messaggio`;

ALTER TABLE `reboot_live`.`messaggi_fuorigioco` 
ADD COLUMN `id_conversazione` INT(255) NOT NULL DEFAULT 0 AFTER `risposta_a_messaggio`;

UPDATE `reboot_live`.`grants` SET `nome_grant`='recuperaConversazione_altri' WHERE `nome_grant`='recuperaMessaggioSingolo_altri';
UPDATE `reboot_live`.`grants` SET `nome_grant`='recuperaConversazione_proprio' WHERE `nome_grant`='recuperaMessaggioSingolo_proprio';


INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('rispondiPerPNG', 'L\'utente può rispondere a nome di ogni PNG a database invece che soltanto per i propri.');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'rispondiPerPNG');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'rispondiPerPNG');
