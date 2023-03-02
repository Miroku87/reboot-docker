-- 2 Marzo 2023
INSERT INTO `reboot_live`.`grants` (`nome_grant`, `descrizione_grant`) VALUES ('scaricaSpecchiettoPG', 'L\'utente può scaricare uno specchietto di tutte le informazioni del proprio pg');
INSERT INTO `reboot_live`.`ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'scaricaSpecchiettoPG');
INSERT INTO `reboot_live`.`ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'scaricaSpecchiettoPG');