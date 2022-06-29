-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: mariadb
-- Creato il: Nov 04, 2021 alle 22:12
-- Versione del server: 10.1.48-MariaDB-1~bionic
-- Versione PHP: 7.4.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `reboot_live`
--

DELIMITER $$
--
-- Procedure
--
CREATE PROCEDURE `controllaPrerequisitoAbilita` (`_id_pg` INT, `_id_abilita` INT)  BEGIN
	-- Trigger che controlla se il pg ha i prerequisiti necessari
	-- Solitamente nel campo prerequisito_abilita c'e' l'id
	-- dell'abilita necessaria, ma esistono degli id d'eccezione:
	--  -1: servono tutte le abilta della classe dell'abilita che si sta cercando di inserire
	--  -2: servono FUOCO A TERRA e TIRATORE SCELTO (id 135 e 130)
	--  -3: servono almeno 5 abilita di Supporto Base ( id 12 )
	--  -4: servono almeno 3 abilita Guastatore Base (id 14)
    --  -5: servono almeno 4 abilita da Sportivo (id 1)
    --  -6: servono almeno 3 talenti da Assaltatore-Base (id 10)
    --  -7: servono almeno 3 talenti da Guastatore-Avanzato (id 15)
    --  -8: servono almeno 3 talenti da Assaltatore-Avanzato (id 15)

    SET @id_fuoco_a_terra = 135;
    SET @id_tiratore_scelto = 130;
    SET @id_supporto_base = 12;
    SET @id_guastatore_base = 14;
    SET @id_sportivo = 1;
    SET @id_assaltatore_base = 10;
    SET @id_assaltatore_avanzato = 11;
    SET @id_guastatore_avanzato = 15;

	SELECT prerequisito_abilita, classi_id_classe INTO @prerequisito, @classe
		FROM abilita
		WHERE id_abilita = _id_abilita;

	IF @prerequisito = -1 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @classe
                )
		) != (
			SELECT COUNT(*) AS tot_abilita_classe
				FROM abilita
                WHERE classi_id_classe = @classe
        ) - 1
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza avere tutte le altre della stessa classe.@@@';

	ELSEIF @prerequisito = -2 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN ( @id_fuoco_a_terra, @id_tiratore_scelto )
		) != 2
    THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza avere FUOCO A TERRA e TIRATORE SCELTO.@@@';

	ELSEIF @prerequisito = -3 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_supporto_base
                )
		) < 5
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 5 abilit&agrave; di Supporto Base.@@@';

	ELSEIF @prerequisito = -4 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_guastatore_base
                )
		) < 3
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 3 abilit&agrave; CONTROLLER.@@@';

	ELSEIF @prerequisito = -5 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_sportivo
                )
		) < 4
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 4 abilit&agrave; da Sportivo.@@@';

	ELSEIF @prerequisito = -6 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_assaltatore_base
                )
		) < 3
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 3 abilit&agrave; da Assaltatore Base.@@@';

	ELSEIF @prerequisito = -7 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_guastatore_avanzato
                )
		) < 3
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 4 abilit&agrave; da Guastatore Avanzato.@@@';

	ELSEIF @prerequisito = -8 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita IN (
					SELECT id_abilita
						FROM abilita
                        WHERE classi_id_classe = @id_assaltatore_avanzato
                )
		) < 3
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi acquistare questa abilit&agrave; senza almeno 4 abilit&agrave; da Assaltatore Avanzato.@@@';

	ELSEIF @prerequisito > 0 AND (
		SELECT COUNT(*) AS num_abilita
			FROM personaggi_has_abilita
            WHERE personaggi_id_personaggio = _id_pg AND
				abilita_id_abilita = @prerequisito
        ) = 0
	THEN
		SELECT nome_abilita INTO @nome_abilita FROM abilita WHERE id_abilita = @prerequisito;
        SET @message = CONCAT('@@@Non puoi acquistare questa abilit&agrave; senza aver prima acquistato ', CAST(@nome_abilita AS CHAR), '@@@');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @message;

	END IF;
END$$

CREATE PROCEDURE `controllaPrerequisitoClassi` (`_id_pg` INT, `_id_classe` INT)  BEGIN
	SELECT prerequisito_classe INTO @prerequisito
		FROM classi
		WHERE id_classe = _id_classe;

	IF @prerequisito > 0 AND (
		SELECT COUNT(*) AS num_classi
			FROM personaggi_has_classi
            WHERE personaggi_id_personaggio = _id_pg AND
				classi_id_classe = @prerequisito
        ) = 0
	THEN
		SELECT nome_classe INTO @nome_classe FROM classi WHERE id_classe = @prerequisito;
        SET @message = CONCAT('@@@Non puoi acquistare questa classe senza aver prima acquistato ', CAST(@nome_classe AS CHAR),'@@@');
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @message;

	END IF;
END$$

CREATE PROCEDURE `registraAzione` (`_id_pg` VARCHAR(255), `_email_giocatore` VARCHAR(255), `_azione` VARCHAR(255), `_vecchio` VARCHAR(255), `_nuovo` VARCHAR(255))  BEGIN
	INSERT INTO storico_azioni (id_personaggio_azione, giocatori_email_giocatore, tipo_azione, valore_vecchio_azione, valore_nuovo_azione)
		VALUES ( _id_pg, _email_giocatore, _azione, _vecchio, _nuovo );
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `abilita`
--

CREATE TABLE `abilita` (
  `id_abilita` int(255) NOT NULL,
  `tipo_abilita` set('civile','militare') COLLATE utf8_unicode_ci NOT NULL,
  `nome_abilita` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `descrizione_abilita` text COLLATE utf8_unicode_ci NOT NULL,
  `costo_abilita` int(255) NOT NULL DEFAULT '1',
  `classi_id_classe` int(255) NOT NULL,
  `prerequisito_abilita` int(255) DEFAULT NULL COMMENT 'I prerequisiti possono assumere valori minori di zero. Questi hanno significati eccezionali:\n* -1: servono tutte le abilta della classe dell''abilita che si sta cercando di inserire\n* -2: servono FUOCO A TERRA e TIRATORE SCELTO (id 134 e 129)\n* -3: servono almeno 5 abilita di Supporto Base (id 12)\n* -4: servono almeno 3 abilita "CONTROLLER"\n* -5: servono almeno 4 abilita da Sportivo',
  `distanza_abilita` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `effetto_abilita` set('attivo','passivo') COLLATE utf8_unicode_ci DEFAULT NULL,
  `offset_pf_abilita` int(5) DEFAULT '0',
  `offset_shield_abilita` int(5) DEFAULT '0',
  `offset_mente_abilita` int(5) DEFAULT '0',
  `abilitacol` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `abilita`
--

INSERT INTO `abilita` (`id_abilita`, `tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`, `abilitacol`) VALUES
(1, 'civile', 'Glitch', 'Una volta per vita, se il personaggio entra in uno dei punti di Respawn viene teletrasportato a un altro. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(2, 'civile', 'Lag', 'Una volta per vita , il personaggio se si muove a scatti dichiara IMMUNE! al primo danno che subisce. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(3, 'civile', 'Barra spaziatrice', 'Se il personaggio si muove saltellando dichiara IMMUNE! ai danni delle chiamate ad area e raggio. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(4, 'civile', 'Tea bag', 'Se al primo avversario abbattuto il personaggio esulta in modo evidente al pubblico, guadagna automaticamente 1 punto in classifica nelle partite DEATHMATCH. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(5, 'civile', 'Conoscenza mappe', 'Il personaggio ha tempo 15 secondi per girare la mappa prima di giocare la partita', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(6, 'civile', 'Akimbo', 'Il personaggio può giocare usando 2 pistole', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(7, 'civile', 'Aim bot', 'Una volta per Vita il personaggio può fare la dichiarazione di danno a dito indicando la vittima', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(8, 'civile', 'Autokill', 'Il personaggio può suicidarsi per non dare punti al nemico. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(9, 'civile', 'Lancia la bandiera', 'Se il personaggio in un match \"cattura la bandiera\" è equipaggiato con la sua arma base e tiene la bandiera la può lanciare. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(10, 'civile', 'Finto morto', 'Il personaggio può fingersi morto per 30 secondi consecutivi. ', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(11, 'civile', 'Camperone', 'Ogni volta che il personaggio sta fermo in un posto per sparare almeno per 3 secondi può dichiarare al primo colpo che spara + 1 alla chiamata secondo lo schema SINGOLO!, DOPPIO! TRIPLO, QUADRUPLO', 20, 1, NULL, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(12, 'civile', 'Idolo della folla', 'Se il personaggio ha appena vinto ( o fa parte della squadra che ha  vinto) una partita  può richiedere allo sponsor un extra del 25% del suo ingaggio dichiarando SONO L\'IDOLO DELLA FOLLA.', 40, 1, -5, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(13, 'civile', 'Coca e mignotte', 'Il personaggio sceglie tra una di queste due opzioni:<br>DROGA: il personaggio ha passato la sua vita a sniffare, risulta immune agli effetti negativi  fisici delle droghe da inalazione.<br>CONTATTO: il personaggio ha passato la sua vita a contatto con sostanze schifose, risulta immune agli effetti negativi delle droghe da contatto.', 70, 1, 12, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(14, 'civile', 'Stalker', 'I numerosi successi sportivi e mondani del personaggio hanno attirato l\'attenzione di uno Stalker che lo seguirà dall\'ombra e potrà fornire qualche aiuto, ma anche delle complicazioni, al personaggio.', 20, 1, 12, 'Utilizzabile solo durante una partita di Deathmatch', NULL, 0, 0, 0, NULL),
(15, 'civile', 'Gavetta', 'Tra un evento e il successivo il personaggio può inviare 1 articolo per farlo pubblicare, se questo avviene guadagna Bit aggiuntivi che gli saranno consegnati al prossimo evento.', 20, 2, NULL, '', NULL, 0, 0, 0, NULL),
(16, 'civile', 'Ottimo scrittore', 'I compensi degli articoli pubblicati aumentano del 30%.', 40, 2, 15, '', NULL, 0, 0, 0, NULL),
(17, 'civile', 'Campo di specializzazione 1', 'Il personaggio deve scegliere tra i seguenti campi: cronaca nera, cronaca rosa, sport, economica, politica, giornalismo spazzatura.<br>Scrivendo nel campo selezionato può mandare un articolo aggiuntivo.', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(18, 'civile', 'Campo di specializzazione 2', 'Il personaggio deve scegliere tra i seguenti campi: cronaca nera, cronaca rosa, sport, economica, politica, giornalismo spazzatura.<br>Scrivendo nel campo selezionato può mandare un articolo aggiuntivo.', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(19, 'civile', 'Campo di specializzazione 3', 'Il personaggio deve scegliere tra i seguenti campi: cronaca nera, cronaca rosa, sport, economica, politica, giornalismo spazzatura.<br>Scrivendo nel campo selezionato può mandare un articolo aggiuntivo.', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(20, 'civile', 'Campo di specializzazione 4', 'Il personaggio deve scegliere tra i seguenti campi: cronaca nera, cronaca rosa, sport, economica, politica, giornalismo spazzatura.<br>Scrivendo nel campo selezionato può mandare un articolo aggiuntivo.', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(21, 'civile', 'Foto scottanti', 'Il personaggio ha contatti per vendere facilmente e a un buon prezzo foto compromettenti (se le deve comunque procurare in gioco).', 30, 2, NULL, '', NULL, 0, 0, 0, NULL),
(22, 'civile', 'Clicca qui', 'Il personaggio ha un sito dove vende informazioni spazzatura per allocchi, questo gli garantisce il 25% in più del tuo attuale stipendio.', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(23, 'civile', 'Disinformazione', 'Il personaggio può far pubblicare informazioni palesemente false anche sui canali di informazione regolari.', 30, 2, 22, '', NULL, 0, 0, 0, NULL),
(24, 'civile', 'Deviare l\'attenzione', 'Il personaggio può scrivere un articolo \"realistico \"che devi l\'attenzione da un altro evento che vuole nascondere ( questa abilità blocca un articolo già uscito fino all\'evento successivo).', 40, 2, NULL, '', NULL, 0, 0, 0, NULL),
(25, 'civile', 'Servo del sistema', 'Il personaggio guadagna il 75% in più del suo stipendio MA non potrà mai utilizzare le seguenti abilità: DISINFORMAZIONE, DEVIARE L\'ATTENZIONE, CLICCA QUI.', 140, 2, NULL, '', NULL, 0, 0, 0, NULL),
(26, 'civile', 'Informazioni prelibate', 'Il personaggio ottiene informazioni commerciali preferenziali sull\'apposita sezione del Ravnet.', 30, 2, NULL, '', NULL, 0, 0, 0, NULL),
(27, 'civile', 'Bunga bunga', 'Il personaggio può investire una quantità di Bit a sua discrezione per ottenere informazioni su personaggi di spicco della politica.', 30, 2, NULL, '', NULL, 0, 0, 0, NULL),
(28, 'civile', 'Voci di strada ', 'Il personaggio ottiene informazioni di quello che accade nelle strade in ambiti legati a Guardie di vigilanza o malavita tra un live e l\'altro inoltrando allo staff una mail con la domanda.', 30, 2, NULL, '', NULL, 0, 0, 0, NULL),
(29, 'civile', 'Programmare', 'Il personaggio può assemblare stringhe di codice per creare programmi singoli.', 20, 3, NULL, '', NULL, 0, 0, 0, NULL),
(30, 'civile', 'Programmazione avanzata', 'Il personaggio può assemblare due programmi assieme; i bonus dei singoli programmi sono accorpati. I programmi così assemblati non possono più essere separati e verranno consumati contemporaneamente.', 40, 3, 29, '', NULL, 0, 0, 0, NULL),
(31, 'civile', 'Programmazione totale', 'Il personaggio può assemblare fino a 4 programmi assieme; i bonus dei singoli programmi sono accorpati. I programmi così assemblati non possono più essere separati e verranno consumati contemporaneamente.', 60, 3, 30, '', NULL, 0, 0, 0, NULL),
(32, 'civile', 'Riallocazione codice', 'Nella programmazione il giocatore può modificare di +/- 1 uno dei parametri numerici di un singolo programma prima del Debug finale.', 50, 3, NULL, '', NULL, 0, 0, 0, NULL),
(33, 'civile', 'Ctrl-c, Ctrl-v', 'Il giocatore può richiedere allo staff una copia di un programma in suo possesso una volta per evento.', 50, 3, NULL, '', NULL, 0, 0, 0, NULL),
(34, 'civile', 'Tutto da solo', 'Il giocatore in possesso di una singola stringa di codice può compilare un programma di massimo due righe utilizzando due volte la stessa stringa di codice.', 60, 3, NULL, '', NULL, 0, 0, 0, NULL),
(35, 'civile', 'Cancellazione programma', 'Il personaggio mentre è nella rete può decidere di cancellare un qualsiasi  programma che ha equipaggiato per ottenere uno spazio vuoto.', 30, 3, NULL, '', NULL, 0, 0, 0, NULL),
(36, 'civile', 'Bruciare il supporto', 'Il personaggio può chiedere allo staff un cartellino \"CRIPT-LOCK®\" . ', 50, 3, NULL, '', NULL, 0, 0, 0, NULL),
(37, 'civile', 'Multitasking', 'Il personaggio può caricare fino ad un numero di programmi pari alla metà delle abilità da netrunner che possiede (arrotondate per difetto, con un minimo di 2) prima di entrare nella rete.', 30, 3, NULL, '', NULL, 0, 0, 0, NULL),
(38, 'civile', 'Zerg rush', 'Il  personaggio può, avvisando un membro staff, prima di entrare nella rete creare un proprio \"clone\" ogni 2 cartellini codice che sacrifica (con profilo base e senza programmi) fino a un massimo di 10 cloni. Questi cloni non sono altri che \"vite\" aggiuntive che il giocatore utilizzerà prima del suo ingresso effettivo nella rete.', 50, 3, 37, '', NULL, 0, 0, 0, NULL),
(39, 'civile', 'Strada sicura', 'Il personaggio 1 volta per accesso alla rete può inviare in modo sicuro un pacchetto dati a una sua casella \"sicura\". In termini di gioco può prendere un singolo cartellino dati in suo possesso all\'interno della rete e consegnarlo a un membro staff presente e richiederlo alla sua uscita dalla rete. ', 60, 3, NULL, '', NULL, 0, 0, 0, NULL),
(40, 'civile', 'Neuro armatura', 'Il personaggio ha installato un programma di protezione latente, se non equipaggiato con programmi di armatura il suo avatar ha 6 punti ferita. ', 30, 3, NULL, '', NULL, 0, 0, 0, NULL),
(41, 'civile', 'Sistema di sicurezza integrato', 'Il personaggio nella rete virtuale può dichiare DISINTEGRAZIONE! su se stesso anche se non è cosciente.', 50, 3, 38, '', NULL, 0, 0, 0, NULL),
(42, 'civile', 'Guerriglia informatica', 'Il personaggio può, quando entra nella rete, dichiarare BONUS! +X DANNI! RAGGIO 5! oppure dichiarare BONUS! +X PUNTI FERITA! RAGGIO 5! (in entrambi i casi X è pari alla metà dei personaggi che sono entrati insieme a lui nella rete virtuale).', 40, 3, 37, '', NULL, 0, 0, 0, NULL),
(43, 'civile', 'Alter ego', 'Il personaggio può, se vuole, modificare il proprio costume prima di entrare nella rete. Se la modifica al costume è totale, non è possibile riconoscere il personaggio.', 30, 3, 37, '', NULL, 0, 0, 0, NULL),
(44, 'civile', 'Riparare', 'Il personaggio può dichiarare RIPARAZIONE 1 dopo 5 Minuti di lavoro.', 30, 4, NULL, '', NULL, 0, 0, 0, NULL),
(45, 'civile', 'Riparazione veloce', 'Il personaggio riduce il tempo TOTALE di applicazione dell\'abilità RIPARARE di 1 minuto (fino ad un minimo di 1 minuto).', 40, 4, 44, '', NULL, 0, 0, 0, NULL),
(46, 'civile', 'Mago della brugola', 'Il personaggio aggiunge sempre + 1 al suo valore di RIPARAZIONE! Dato dall\'abilità Riparare.', 50, 4, NULL, '', NULL, 0, 0, 0, NULL),
(47, 'civile', 'Lavoro di squadra', 'Il personaggio se lavora con un altro personaggio con questa abilità dimezza i tempi di riparazione (approssimati per eccesso) e aggiunge +1 al valore della chiamata. Questa abilità non può essere usata assieme a RIPARAZIONE VELOCE.', 40, 4, NULL, '', NULL, 0, 0, 0, NULL),
(48, 'civile', 'Specializzazione-Armi', 'Il personaggio può scegliere tra i progetti fattibili qualsiasi tipologia da arma.', 40, 4, 45, '', NULL, 0, 0, 0, NULL),
(49, 'civile', 'Specializzazione-Protesi', 'Il personaggio può scegliere tra i progetti fattibili qualsiasi tipologia di protesi.', 40, 4, 45, '', NULL, 0, 0, 0, NULL),
(50, 'civile', 'Specializzazione-Gadget e Shield', 'Il personaggio può scegliere tra i progetti fattibili qualsiasi tipologia di gadget e Shield.', 40, 4, 45, '', NULL, 0, 0, 0, NULL),
(51, 'civile', 'Specializzazione-Esoscheletri e scudi', 'Il personaggio può scegliere tra i progetti fattibili qualsiasi tipologia di potenziamento per tutte le tipologie di esoscheletro e scudi.', 40, 4, 45, '', NULL, 0, 0, 0, NULL),
(52, 'civile', 'Specializzazione avanzata-Esoscheletri', 'Il personaggio può progettare esoscheletri completi.', 40, 4, 51, '', NULL, 0, 0, 0, NULL),
(53, 'civile', 'Specializzazione avanzata-Gadget', 'Il personaggio può progettare gadget complessi.', 40, 4, 50, '', NULL, 0, 0, 0, NULL),
(54, 'civile', 'Scansione schemi', 'Il personaggio può demolire un oggetto per scoprire il suo esatto schema di realizzazione', 80, 4, NULL, '', NULL, 0, 0, 0, NULL),
(55, 'civile', 'Smontaggio veloce', 'Il personaggio può smontare qualsiasi oggetto dotato di cartellino Azzurro recuperando la componente più facile da ottenere, mimando di smontare l\'oggetto per 1 minuti e riconsegnando l\'oggetto demolito allo Staff.', 70, 4, NULL, '', NULL, 0, 0, 0, NULL),
(56, 'civile', 'Ricerca mirata', 'Il personaggio può demolire un oggetto Bianco per ottenere un suo componente. Il personaggio deve consegnare l\'oggetto allo staff specificando quale parte vuole ottenere tra le seguenti tipologie: struttura, batteria, applicativo.', 60, 4, 55, '', NULL, 0, 0, 0, NULL),
(57, 'civile', 'Macchinari specialistici', '', 20, 4, NULL, '', NULL, 0, 0, 0, NULL),
(58, 'civile', 'Squadra di aiutanti', 'Il personaggio può farsi aiutare da altri personaggi (da uno ad un massimo pari alla metà delle abilità di Tecnico che possiede, arrotondate per difetto) nel compiere le operazioni di riparazione. Se lui, i suoi aiutanti e l\'oggetto da riparare sono in un raggio di 5 metri, può utilizzare le abilità di riparazione riducendo di 30 SECONDI i tempi per ogni aiutante, fino ad un minimo di 1 minuto per operazione.', 40, 4, NULL, '', NULL, 0, 0, 0, NULL),
(59, 'civile', 'Impiantologia cibernetica', 'Il personaggio è in grado di montare protesi a un personaggio se opera in un struttura adeguata. L\'operazione deve essere mimata per 10 minuti. Al termine dichiara NEUTRALIZZA! MUTILAZIONE!', 20, 5, NULL, '', NULL, 0, 0, 0, NULL),
(60, 'civile', 'Impiantologia cibernetica migliorata', 'Il personaggio è in grado di montare protesi a un personaggio se opera in un struttura adeguata. L\'operazione deve essere mimata per 5 minuti.', 40, 5, 59, '', NULL, 0, 0, 0, NULL),
(61, 'civile', 'Prime cure', 'Il personaggio può, dopo 10 secondi di lavoro, allungare il tempo di coma del bersaglio di ulteriori 5 minuti. Può essere utilizzata solo una volta sullo stesso bersaglio, anche da diversi Biomedici. Il giocatore dovrà spiegare al bersaglio gli effetti di questa abilità.', 20, 5, NULL, '', NULL, 0, 0, 0, NULL),
(62, 'civile', 'Cure intensive', 'Il personaggio può dichiarare GUARIGIONE! X! (dove X è pari alla metà delle abilità di medicina che possiede) dopo aver mimato la procedura per 5 minuti ad un personaggio che non sia in stato di coma.', 30, 5, NULL, '', NULL, 0, 0, 0, NULL),
(63, 'civile', 'Cure avanzatre', 'Il personaggio può dichiarare GUARIGIONE! X! (dove X è pari alla metà delle abilità di medicina che possiede) su un personaggio in coma dopo aver mimato la procedura per 5 minuti.', 40, 5, 62, '', NULL, 0, 0, 0, NULL),
(64, 'civile', 'Sintesi e analisi chimica', 'Il personaggio è in grado di analizzare e produrre sostanze chimiche tramite la specifica sezione del database medico e dello strumento di sintesi preposto.', 20, 5, NULL, '', NULL, 0, 0, 0, NULL),
(65, 'civile', 'Produzione migliorata', 'Durante la sintesi chimica un personaggio ottiene il doppio dei prodotti normalmente ottenibili.', 60, 5, NULL, '', NULL, 0, 0, 0, NULL),
(66, 'civile', 'Equipe medica', 'Il personaggio se lavora con un altro personaggio con questa abilità aggiunge +1 al valore della chiamata per ogni personaggio con cui collabora.', 40, 5, NULL, '', NULL, 0, 0, 0, NULL),
(67, 'civile', 'Gestire gli aiutanti', 'Il personaggio può farsi aiutare da altri personaggi (da uno ad un massimo pari alla metà delle abilità di medicina che possiede, arrotondate per difetto ) nel compiere le operazioni mediche. Se lui, i suoi aiutanti e i pazienti sono in un raggio di 5 metri, può utilizzare le abilità \"Prime Cure\", \"Cure Intensive\" e \"Cure Avanzate\" su un paziente aggiuntivo per ogni aiutante.<br><br>(N.B. : Si intende \"Paziente\" il personaggio sottoposto a cure, \"Aiutante\" la persona, anche non medico, che sta aiutando chi usa l\'abilità. L\'Aiutante non può in nessun caso essere anche un paziente, e non potrà utilizzare altre abilità mentre aiuta il personaggio. L\'uso di questa abilità esclude l\'utilizzo dell\'abilità \"Gestire i Tempi\")', 60, 5, NULL, '', NULL, 0, 0, 0, NULL),
(68, 'civile', 'Gestire i tempi', 'Il personaggio può farsi aiutare da altri personaggi (da uno ad un massimo pari alla metà delle abilità di medicina che possiede, arrotondate per difetto) nel compiere le operazioni mediche. Se lui, i suoi aiutanti e il paziente sono in un raggio di 5 metri, può utilizzare le abilità \"Prime Cure\", \"Cure Intensive\" e \"Cure Avanzate\" riducendo di 1 minuto i tempi per ogni aiutante, fino a dimezzare le tempistiche.<br><br>(N.B. : Si intende \"Paziente\" il personaggio sottoposto a cure, \"Aiutante\" la persona, anche non medico, che sta aiutando chi usa l\'abilità. L\'Aiutante non può in nessun caso essere anche un paziente, e non potrà utilizzare altre abilità mentre aiuta il personaggio. L\'uso di questa abilità esclude l\'utilizzo dell\'abilità \"Gestire gli aiutanti\").<br><br>N.b. Quando il medico sta operando su un altro personaggio, il conteggio di coma del ferito si interrompe.', 60, 5, NULL, '', NULL, 0, 0, 0, NULL),
(69, 'civile', 'Non puoi ingrandirla di più?', 'Il personaggio può ottenere informazioni aggiuntive tramite la Ravnet, su prove che sono già state analizzate.', 20, 6, NULL, '', NULL, 0, 0, 0, NULL),
(70, 'civile', 'Grissom è amico mio', 'Il personaggio ottiene informazioni aggiunte nei cartellini \"Interazione\".', 20, 6, NULL, '', NULL, 0, 0, 0, NULL),
(71, 'civile', 'Linguaggio del corpo', 'Il personaggio, dopo aver parlato almeno 5 minuti con una persona può dichiarare SINCERITA\'!: MI HAI MENTITO SU QUALCOSA IN QUESTI ULTIMI 5 MINUTI?. Non è possibile interrogare con questa abilità la stessa persona più volte nell\'arco di un ora.', 40, 6, NULL, '', NULL, 0, 0, 0, NULL),
(72, 'civile', 'Direzione dei colpi', 'Il personaggio se in presenza di un cadavere può chiedere allo staff la direzione, il numero di colpi e la tipologia dell\'arma che ha ucciso la persona.', 20, 6, NULL, '', NULL, 0, 0, 0, NULL),
(73, 'civile', 'Interrogatorio', 'Durante un interrogatorio il personaggio può, dopo aver posto allo stesso un bersaglio 5 domande sullo stesso argomento, dichiarare SINCERITA\'! HAI MENTITO IN QUALCUNA DELLE RISPOSTE CHE MI HAI DATO?. Non è possibile interrogare con questa abilità la stessa persona più volte nell\'arco di un ora.', 60, 6, NULL, '', NULL, 0, 0, 0, NULL),
(74, 'civile', 'Poliziotto buono e Poliziotto cattivo', 'Se 2 giocatori hanno l\'abilità INTERROGATORIO possono interrogare lo stesso soggetto in contemporanea anche sullo stesso argomento. Viene richiesto ai due giocatori di interpretare correttamente la cosa con uno dei due \"buono\" e l\'altro \"cattivo\".', 60, 6, NULL, '', NULL, 0, 0, 0, NULL),
(75, 'civile', 'Contatti nell\'Ago', 'Il personaggio ha contatti nell\'Ago e ottiene accesso all\'apposita sezione nel Ravnet.', 40, 6, NULL, '', NULL, 0, 0, 0, NULL),
(76, 'civile', 'Chiuderemo un occhio', 'La prima volta che il personaggio fa qualche errore grosso e si ritrova il dipartimento disciplinare può dichiarare a un membro staff l\'uso di questa abilità e il suo problema verrà ignorato solo per quella volta. Il favore può essere recuperato in gioco.  ', 80, 6, NULL, '', NULL, 0, 0, 0, NULL),
(77, 'civile', 'Contatti nella malavita', 'Il personaggio ha contatti nella malavita e ottiene accesso all\'apposita sezione nel Ravnet.', 40, 6, NULL, '', NULL, 0, 0, 0, NULL),
(78, 'civile', 'Nemesi', 'Il personaggio nel suo passato si è creato un nemico giurato con cui si è andato a creare una strana simbiosi, il suo nemico cercherà di ostacolarlo ma non ucciderlo, non lo aiuterà ma potrebbe salvarlo da situazioni estreme solo perché \"è una questione personale\".', 60, 6, NULL, '', NULL, 0, 0, 0, NULL),
(79, 'civile', 'Torturare', 'Durante un interrogatorio e dopo aver causato dei danni al bersaglio, il personaggio può, dopo aver posto allo stesso bersaglio 5 domande sullo stesso argomento, dichiarare SINCERITA\'! HAI MENTITO IN QUALCUNA DELLE RISPOSTE CHE MI HAI DATO?. Non è possibile interrogare con questa abilità la stessa persona più volte nell\'arco di un ora.', 50, 7, NULL, '', NULL, 0, 0, 0, NULL),
(80, 'civile', 'Baciamo le mani', 'Il personaggio ha contatti che gli garantiscono informazioni sui movimenti delle guardie corporative e ottiene accesso all\'apposita sezione nel Ravnet.', 80, 7, NULL, '', NULL, 0, 0, 0, NULL),
(81, 'civile', 'Contatti tra gli sbirri', 'Il personaggio ha contatti che gli garantiscono informazioni sui movimenti delle guardie corporative e ottiene accesso all\'apposita sezione nel Ravnet.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(82, 'civile', 'Contatti nella famiglia', 'Il personaggio ha contatti nella malavita e ottiene accesso all\'apposita sezione nel Ravnet.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(83, 'civile', 'Inquinare le prove', 'Il personaggio può interagire su Cartellini Interazione \"Prove\" chiedendo allo staff di modificarli permanentemente.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(84, 'civile', 'Scassinare', 'Il personaggio può mimare di scassinare una serratura e aprirla dopo 1 minuto di interazione per ogni livello di difficoltà della serratura.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(85, 'civile', 'Ricettare merce', 'Il personaggio può \"vendere\" alla segreteria oggetti in suo possesso e ottenerne il 50 % del valore.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(86, 'civile', 'Menù del Continental', 'Il personaggio ottiene prima del live una lista di prodotti ottenibili sul mercato nero ma deve trovare qualcuno che gli venda l\'oggetto del suo desiderio.', 30, 7, NULL, '', NULL, 0, 0, 0, NULL),
(87, 'civile', 'Consierge del Continental', 'Il personaggio sapendo cosa vendono al Continental può acquistare prima del live uno o più beni (sempre se possiede i Bit necessari per farlo).', 80, 7, 86, '', NULL, 0, 0, 0, NULL),
(88, 'civile', 'Allibratore', 'Se il personaggio perde giocando a delle scommesse ufficiali recupera il 25% del valore perso.', 40, 7, NULL, '', NULL, 0, 0, 0, NULL),
(89, 'civile', 'Vita allo sbando', 'Il personaggio sceglie tra una di queste due opzioni:<br><br>ALCOLISMO: il personaggio ha passato la sua vita a bere, risulta immune agli effetti negativi fisici delle droghe da ingestione.<br>INIEZIONE: il personaggio ha passato la sua vita a bucarsi, risulta immune agli effetti negativi delle droghe da iniezione.<br><br>Tuttavia, se subisce la chiamata SINCERITA\' mentre è sotto l\'effetto della tipologia da lui selezionata dovrà rispondere a 3 domande dicendo la verità .', 60, 7, NULL, '', NULL, 0, 0, 0, NULL),
(90, 'civile', 'Conversione sicura', 'Il personaggio può convertire Bit in Platino e viceversa senza problemi andando in sala staff.', 70, 7, NULL, '', NULL, 0, 0, 0, NULL),
(91, 'civile', 'Riconoscere droghe e sostanze illegali', 'Il personaggio è in grado di riconoscere sostanze illegali non identificate se appartengono alla categoria \"Droghe\".', 20, 7, NULL, '', NULL, 0, 0, 0, NULL),
(92, 'militare', 'Istinto omicida', 'Se il personaggio è sotto l\'effetto di CONFUSIONE! può comunque attaccare colpendo col danno base<br>dell\'arma usata ridotto di 1 seguendo la normale catena:<br>COMA! - A ZERO! - CRASH! - QUADRUPLO! - TRIPLO! - DOPPIO! - SINGOLO!.', 1, 8, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(93, 'militare', 'Istinto di sopravvivenza', 'Se il personaggio è sotto effetto della chiamata DOLORE! può comunque muoversi arrancando per tutta<br>la durata della chiamata, senza compiere nessun\'altra azione.', 1, 8, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(94, 'militare', 'Scudo umano', 'Il personaggio può dichiarare NEUTRALIZZA GRANATA! Il personaggio deve mimare di coprire la granata<br>col proprio corpo (NOTA: è sufficiente essere entro un raggio massimo di 1 metro dalla granata)<br>subendo però ARTEFATTO COMA! nel caso in cui la granata causi danno o ARTEFATTO SHOCK! nel caso<br>in cui sia una qualunque chiamata di effetto. Quest\'abilità non funziona se non si è coscienti.', 1, 8, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(95, 'militare', 'Posizione difensiva', 'Il personaggio può rilocare un danno subito dalla locazione vitale ad un arto o viceversa.<br>ESEMPIO: un colpo alla gamba può essere spostato sul torso ma non sulle braccia; un colpo al torso può<br>essere spostato dove si vuole.', 1, 8, 93, 'personale', 'passivo', 0, 0, 0, NULL),
(96, 'militare', 'Difesa mentale 1', 'Il punteggio di Difesa Mentale del personaggio è aumentato permanentemente di 1.', 1, 8, NULL, 'personale', 'passivo', 0, 0, 1, NULL),
(97, 'militare', 'Addestramento fisico 1', 'I Punti Ferita del personaggio aumentano permanentemente di 1.', 1, 8, NULL, 'personale', 'passivo', 1, 0, 0, NULL),
(98, 'militare', 'Shield MK2', 'Se il personaggio ha almeno un Punto Shield base, guadagna +2 punti al suo valore globale.', 1, 8, NULL, 'personale', 'passivo', 0, 2, 0, NULL),
(99, 'militare', 'Resistere alla paura', 'Il personaggio può dichiarare IMMUNE! Alla chiamata PAURA!.', 1, 8, 95, 'personale', 'attivo', 0, 0, 0, NULL),
(100, 'militare', 'Tuta corazzata MK2', 'Il valore base dei punti Shield garantiti dalle locazioni equipaggiate con una tuta da combattimento<br>corazzata (come indicato a pag. 17) è moltiplicato per 1,5.', 1, 8, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(101, 'militare', 'Tuta corazzata MK3', 'Il valore base dei punti Shield garantiti dalle locazioni equipaggiate con una tuta da combattimento<br>corazzata (come indicato a pag. 17) è raddoppiato. Questa abilità sostituisce TUTA CORAZZATA MK2.', 1, 8, 100, 'personale', 'passivo', 0, 0, 0, NULL),
(102, 'militare', 'Shield MK3', 'Se il personaggio ha almeno un Punto Shield base, guadagna +4 punti al suo valore globale. Questa<br>abilità sostituisce SHIELD MK2.', 1, 8, 98, 'personale', 'passivo', 0, 4, 0, NULL),
(103, 'militare', 'Braccio di ferro', 'Il personaggio può dichiarare IMMUNE! alla chiamata DISARMO!.', 1, 8, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(104, 'militare', 'Fuciliere', 'Il personaggio può aumentare di 2 i danni causati col Fucile d\'Assalto per il prossimo colpo sparato in<br>base alla seguente scala: SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!.', 1, 8, 105, 'personale', 'attivo', 0, 0, 0, NULL),
(105, 'militare', 'Presa ferma', 'Il personaggio può impugnare armi di categoria Fucile d\'Assalto con una sola mano se nell\'altra impugna<br>uno Scudo.', 1, 8, 103, 'personale', 'passivo', 0, 0, 0, NULL),
(106, 'militare', 'Testa dura', 'Il personaggio può dichiarare IMMUNE! alla chiamata SHOCK!', 1, 8, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(107, 'militare', 'Scarica d\'adrenalina', 'Il personaggio quando entra in stato di COMA può, simulando un \"urlo belluino\" (o altro effetto<br>scenografico simile ad alto tasso di testosterone), subire BLOCCO! TEMPO 1 ORA! alla batteria e ritorna<br>a pieni punti ferita e punteggio Shield al massimo.', 1, 8, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(108, 'militare', 'Farsi scudo', 'Se il personaggio impugna un Mitragliatore Pesante può dichiarare IMMUNE! ad un colpo subito ma<br>l\'arma subisce l\'effetto BLOCCO! Eccezioni sono le chiamate DISINTEGRAZIONE! (applicata comunque al<br>bersaglio) e le chiamate MUTILAZIONE! o CREPA! che infliggono all\'arma che la subisce<br>DISINTEGRAZIONE! Invece di BLOCCO!.', 1, 9, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(109, 'militare', 'Addestramento fisico 2', 'I Punti ferita del personaggio aumentano permanentemente di 2 (questa abilità sostituisce<br>ADDESTRAMENTO FISICO I).', 1, 9, 97, 'personale', 'passivo', 2, 0, 0, NULL),
(110, 'militare', 'Difendere gli altri', 'Il personaggio può dichiarare IMMUNE! ad una chiamata subita da un bersaglio entro 1 metro da lui,<br>subendo la chiamata al suo posto.', 1, 9, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(111, 'militare', 'Inarrestabile', 'Il personaggio può dichiarare IMMUNE! a una qualsiasi delle seguenti chiamate:<br>PARALISI! - CONFUSIONE! - SHOCK! - DISARMO! - SPINTA!.', 1, 9, 112, 'personale', 'attivo', 0, 0, 0, NULL),
(112, 'militare', 'E\' solo un graffietto', 'Il personaggio può dichiarare IMMUNE! alla chiamata DOLORE!', 1, 9, 93, 'personale', 'passivo', 0, 0, 0, NULL),
(113, 'militare', 'Bunker semovente', 'Il personaggio utilizzando un\'arma di classe Mitragliatore Pesante può, se appostato dietro un riparo,<br>camminare per un massimo di 10 metri fino a posizionarsi dietro un altro riparo contando come se fosse<br>stazionario e appostato ai fini del prerequisito \"Posizionamento\" per questa classe d\'arma.<br>(N.B. Puoi quindi sparare con un mitragliatore pesante mentre cammini tra un riparo e l\'altro.)', 1, 9, 111, 'personale', 'passivo', 0, 0, 0, NULL),
(114, 'militare', 'Tempesta di metallo', 'Il personaggio, se sta già sparando con un\'arma di classe Mitragliatore Pesante, può dichiarare la prossima chiamata base dell\'arma aggiungendo IN QUEST\'AREA!.', 1, 9, NULL, 'Area 10 metri', 'attivo', 0, 0, 0, NULL),
(115, 'militare', 'Fuoco difensivo', 'Il personaggio se sta usando un\'arma di classe Mitragliatore pesante, dopo aver sparato ininterrottamente sullo stesso bersaglio ostile per 10 secondi, subisce BONUS! + 4 PUNTI SHIELD!<br><br>(N.b. Non è possibile cambiare bersaglio, ma è possibile sospendere il conteggio per cambiare caricatore, riprendendo quindi a sparare sullo stesso bersaglio)', 1, 9, 114, 'personale', 'passivo', 0, 0, 0, NULL),
(116, 'militare', 'Ricarica scudo d\'emergenza', 'Quando il personaggio arriva a 0 punti Shield può subire la chiamata BONUS! +8 PUNTI SHIELD.', 1, 9, 102, 'personale', 'attivo', 0, 0, 0, NULL),
(117, 'militare', 'Feel no pain', 'Se il personaggio subisce la chiamata MUTILAZIONE! ad un arto ignora la chiamata ARTEFATTO COMA! associata; l\'arto è comunque da sostituire e deve simulare il dolore estremo.', 1, 9, 112, 'personale', 'passivo', 0, 0, 0, NULL),
(118, 'militare', 'Barricata', 'Il personaggio può imbracciare uno scudo di dimensione minima 140x80 e massima 200x100; se il personaggio poggia lo scudo e un ginocchio a terra, questo scudo permette di parare chiamate di danno fino a CRASH! compreso; qualora intercetti chiamate superiori, lo scudo subisce DISINTEGRAZIONE! ma la chiamata non viene comunque subita.<br>Qualora il personaggio non sia posizionato, funziona come un normale scudo. ', 1, 9, 108, 'personale', 'passivo', 0, 0, 0, NULL),
(119, 'militare', 'Fortezza della solitudine', 'Il massimale base del valore di Shield del personaggio non è mai inferiore a 3 punti quando indossa una tuta da combattimento corazzata, neanche a seguito di oggetti equipaggiati.', 1, 9, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(120, 'militare', 'Interfacce protesiche avanzate', 'Se il personaggio viene colpito ad una locazione sintetica dalle chiamate COMA! o CREPA! può, subendo BLOCCO! alla batteria ed alla protesi interessata dal colpo, declassare la chiamata COMA! ad ARTEFATTO! A ZERO! oppure può declassare la chiamata CREPA! ad ARTEFATTO! MUTILAZIONE!.<br>Questa abilità non può essere utilizzata con una protesi d\'emergenza.<br><br>(NOTA: le chiamate sostitutive si ritengono da applicarsi SEMPRE alla locazione originale dell\'impatto, non possono essere deviate o rilocate su un\'altra parte del corpo o su un altro bersaglio.)', 1, 9, 117, 'personale', 'passivo', 0, 0, 0, NULL),
(121, 'militare', 'Ultima parola', 'Il personaggio, dopo aver subito la chiamata CREPA! (non è sufficiente entrare in status Morto per conteggio) può rialzarsi con 50 Punti Ferita alocazionali, ma il suo Shield e la sua Batteria subiscono la chiamata BLOCCO! CONTINUO! Questo stato dura 1 minuto, durante i quali subisce tutte le chiamate di danno fino a QUADRUPLO come 1 singolo danno, le altre chiamate come 5 danni eccetto CREPA! e DISINTEGRAZIONE! che subisce normalmente. Passato il minuto o esauriti i Punti Ferita subisce la chiamata ARTEFATTO CREPA! e non può più utilizzare questa abilità.', 1, 9, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(122, 'militare', 'Yippie kay yay', 'Il personaggio dopo avere subito per almeno 10 secondi la chiamata DOLORE (senza quindi aver dichiarato IMMUNE o aver subito NEUTRALIZZA) può alzare di due la prossima chiamata di danno secondo la normale scala, fino ad A ZERO!', 1, 9, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(123, 'militare', 'Last man standing', 'Il personaggio per 1 minuto può dichiarare IMMUNE! a PARALISI! - PAURA! - CONFUSIONE! - SHOCK! - DISARMO! - DOLORE!, i suoi punti Shield vengono raddoppiati, i suoi Punti Ferita vengono raddoppiati e i suoi talenti attivi non avviano il Cooldown. Passato il minuto il personaggio subisce ARTEFATTO COMA!; una volta curato, subisce tutte le chiamate di status per il doppio del tempo e i suoi punti ferita sono dimezzati (arrotondati per difetto) fino alla fine della giornata di gioco.<br><br>Nota: se un personaggio con questi malus arriva ad avere Punti Ferita pari o inferiori a 0 (calcolo effettuato in base ai punti ferita standard, non quelli temporanei dovuti all\'abilità) il personaggio si considera aver avuto un collasso multiorgano e subisce immediatamente la chiamata ARTEFATTO CREPA!', 1, 9, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(124, 'militare', 'Batteria aumentata', 'Il personaggio può utilizzare un massimo di 2 abilità Attive contemporaneamente invece di 1 sola per ogni attivazione. Così facendo somma i tempi di Cooldown.<br><br>NOTA: si può applicare questa abilità solo ai talenti da Assaltatore (sia Base che Avanzato)', 1, 10, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(125, 'militare', 'Tuta da combattimento MK2', 'Il punteggio di Shield totale garantito dalla tuta da combattimento equipaggiata aumenta di 1, se la tuta fornisce al personaggio almeno un punto Shield Base.', 1, 10, NULL, 'personale', 'passivo', 0, 1, 0, NULL),
(126, 'militare', 'Pistolero', 'Il personaggio se combatte impugnando contemporaneamente due armi di classe Pistola può sostituire il danno base dell\'arma con la chiamata SINGOLO! CONFUSIONE! Al prossimo colpo sparato (o solo CONFUSIONE! Nel caso il danno base dell\'arma fosse già SINGOLO!).', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(127, 'militare', 'Hotshot', 'Il personaggio utilizza la sua batteria per sovraccaricare la pistola sparando un colpo molto più potente.<br>Il personaggio può aumentare di 2 il danno del suo prossimo colpo (fino a COMA! compreso). L\'abilità è utilizzabile solo con pistole ad energia. Dopo aver sparato, la Batteria e la pistola subiscono la chiamata BLOCCO! CONTINUO!.', 1, 10, 126, 'personale', 'attivo', 0, 0, 0, NULL),
(128, 'militare', 'Ambidestria', 'Il personaggio può impugnare un\'arma a una mano (pistola, arma da mischia corta se può utilizzarla) per mano e combattere utilizzando la mano secondaria.', 1, 10, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(129, 'militare', 'Addestramento fisico', 'I Punti Ferita del personaggio aumentano permanentemente di 1.', 1, 10, NULL, 'personale', 'passivo', 1, 0, 0, NULL),
(130, 'militare', 'Tiratore scelto', 'Il personaggio con le armi di classe Fucile di Precisione può aumentare di 1 il danno del prossimo colpo sparato. L\'abilità viene \"spesa\" anche se il colpo manca il bersaglio.<br><br>(NOTA: i potenziamenti seguono la normale scala di danno:<br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!)', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(131, 'militare', 'Non a me, a lui!', 'Il personaggio se subisce PAURA! Può considerare qualunque personaggio cosciente e consenziente come riparo fisso per gli effetti della chiamata.', 1, 10, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(132, 'militare', 'Colpo perforante', 'Il personaggio, utilizzando un Fucile di Precisione, deve dichiarare CRASH! con il suo prossimo colpo.', 1, 10, 138, 'personale', 'attivo', 0, 0, 0, NULL),
(133, 'militare', 'Braccia robuste', 'Il Personaggio può sparare con Shotgun e Fucili d\'Assalto impugnandoli con una sola mano.', 1, 10, 129, 'personale', 'passivo', 0, 0, 0, NULL),
(134, 'militare', 'Proiettili incendiari', 'Il personaggio se utilizza un Fucile di Precisione può aggiungere la chiamata FUOCO! al prossimo colpo sparato.', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(135, 'militare', 'Fuoco a terra', 'Il personaggio, se utilizza un Fucile di Precisione od uno Shotgun, può dichiarare per il prossimo colpo SPINTA X! al posto del danno dell\'arma, dove X corrisponde al danno causato (se il danno è superiore a QUADRUPLO! X assume come valore 7).', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(136, 'militare', 'Colpo non letale', 'Il personaggio può utilizzare la chiamata SHOCK! sparando con uno Shotgun con il prossimo colpo.', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(137, 'militare', 'Disarmare', 'Il personaggio può sostituire il danno effettuato con la chiamata DISARMO! con ogni arma da fuoco nella quale è competente. Il DISARMO! Si applica al prossimo colpo sparato.', 1, 10, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(138, 'militare', 'Mirare', 'Il personaggio, utilizzando un Fucile di Precisione, può dichiarare il prossimo colpo a dito su un bersaglio entro i 10 metri dopo aver simulato di mirare il suo obiettivo per 10 secondi.', 1, 10, -2, '10 metri', 'passivo', 0, 0, 0, NULL),
(139, 'militare', 'Colpo sanguinante', 'Il personaggio può abbinare l\'effetto CONTINUO! al prossimo colpo.<br><br>(N.B. il tempo di Cooldown di questa abilità è 60 secondi e NON 30 secondi)', 1, 10, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(140, 'militare', 'Arma selezionata', 'Il personaggio deve scegliere una tipologia di arma tra quelle in cui è addestrato. <br>Può aumentare di 1 il danno fatto con l\'arma prescelta secondo la scala <br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!.<br>NOTA 1: non sono comprese nelle armi selezionabili le Granate.<br>NOTA 2: questo bonus è sommabile a qualunque altro bonus ai danni, eventualmente disponibile per il giocatore con l\'arma selezionata.', 1, 11, -6, 'personale', 'passivo', 0, 0, 0, NULL),
(141, 'militare', 'Pistola e coltello', 'Se il personaggio impugna un\'Arma da mischia corta e una Pistola, può dichiarare CONFUSIONE! con l\'arma da mischia ed aumentare di 1 le chiamate di danno effettuate con la pistola sul bersaglio confuso.<br><br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!)', 1, 11, 128, 'personale', 'attivo', 0, 0, 0, NULL),
(142, 'militare', 'Scarica accecante', 'Il personaggio può, utilizzando uno Shotgun, sostituire la sua prossima chiamata di danno con CONFUSIONE! IN QUEST\'AREA 3!.<br><br>(NOTA: l\'angolo formato dalle braccia per determinare l\'area d\'effetto DEVE essere 90°.)', 1, 11, 136, '3 metri', 'attivo', 0, 0, 0, NULL),
(143, 'militare', 'Gestione tattica', 'Quando il personaggio ha lo Shield ridotto a zero aumenta di 1 le chiamate fatte con le Armi da mischia.<br><br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!)', 1, 11, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(144, 'militare', 'Resistere alla paura', 'Il personaggio può dichiarare IMMUNE! Alla chiamata PAURA!.', 1, 11, 148, 'personale', 'attivo', 0, 0, 0, NULL),
(145, 'militare', 'Granate modificate', 'Il personaggio può aggiungere la chiamata CONFUSIONE! alla prossima granata lanciata.', 1, 11, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(146, 'militare', 'Bombe gemelle', 'Il personaggio può attaccare il cartellino Granata a una Granata che ne sia già fornita purché i cartellini delle due Granate siano identici, aumentando di 1 il danno base e aggiungendo 2 metri al raggio.', 1, 11, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(147, 'militare', 'Colpo di striscio', 'Dopo aver sparato un colpo con il fucile di precisione ad un bersaglio oltre i 10 metri, se il colpo è andato a vuoto, il personaggio potrà dichiarare a dito, su un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo la scala:<br><br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO! - COMA!', 1, 11, 138, 'personale', 'attivo', 0, 0, 0, NULL),
(148, 'militare', 'I morti non parlano', 'Se il personaggio ha subito almeno una ferita (Punti Ferita ridotti di almeno 1 punto a causa di danni) alla locazione vitale, può fingersi morto subendo CRASH! e BLOCCO! allo Shield. Se analizzato dichiara il suo status come CREPA!; tuttavia, se subisce una chiamata di danno, deve reagire muovendosi e rivelandosi.<br><br>(Nota Bene: Il Cooldown parte quando il personaggio si alza o compie altre azioni.)', 1, 11, 152, 'personale', 'attivo', 0, 0, 0, NULL),
(149, 'militare', 'Colpo di mano', 'Il personaggio può dichiarare DISARMO! Con un colpo utilizzando un\'arma da mischia.', 1, 11, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(150, 'militare', 'Apriscatola', 'Il personaggio può aggiungere il descrittore DIRETTO! al prossimo colpo che sferrerà con un\'Arma da Mischia.', 1, 11, 153, 'personale', 'attivo', 0, 0, 0, NULL),
(151, 'militare', 'Bomba adesiva', 'Il personaggio colpendo direttamente un Bersaglio con una granata può dichiarare la normale chiamata della granata, escludendo \"GRANATA!\" e \"RAGGIO X\". Se si manca fisicamente il bersaglio la granata è sprecata.', 1, 11, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(152, 'militare', 'Movimento occultato', 'Il personaggio è equipaggiato e addestrato all\'utilizzo di rifrattori ottici che gli permettono di restare invisibile per poco tempo. Quando attiva l\'abilità il personaggio può dichiarare su se stesso ATTENUAZIONE! Quante volte desidera per i prossimi 10 secondi. ', 1, 11, 143, 'personale', 'attivo', 0, 0, 0, NULL),
(153, 'militare', 'Tempesta di lame', 'Il personaggio è un maestro nell\'uso di due lame in combattimento. Può utilizzare con il talento AMBIDESTRIA armi da mischia ad una mano di dimensione massime 130 cm.', 1, 11, 128, 'personale', 'passivo', 0, 0, 0, NULL),
(154, 'militare', 'Bomba in buca', 'Il personaggio ha affinato il suo istinto di sopravvivenza: prima di essere colpito dagli effetti di GRANATA! può dichiarare IMMUNE! mimando di buttarsi a terra o dietro un riparo solido.', 1, 11, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(155, 'militare', 'Gloria o morte', 'Il personaggio può attivare questa abilità urlando \"GLORIA O MORTE!\".<br>Da questo momento si considera avere punti ferita alocazionali pari ai punti ferita attuali della locazione vitale moltiplicati x 10 (fino ad un massimo di 40 punti ferita) e considera tutte le chiamate di danno come ARTEFATTO! TRIPLO! ad eccezione di CREPA! DISINTEGRAZIONE! E MUTILAZIONE! che subisce normalmente.<br>Il suo Shield, se presente, funziona normalmente.<br>Il personaggio deve lanciarsi in combattimento in mischia contro il più vicino bersaglio ostile.<br>Se tutti i bersagli ostili in vista sono morti prima di aver concluso i punti ferita il personaggio sviene e subisce ARTEFATTO COMA!; se viene abbattuto prima di aver terminato i bersagli ostili, o se non termina i bersagli entro 5 minuti, subisce invece ARTEFATTO! CREPA!<br><br><br>Ogni volta che utilizza questa abilità riduce il suo massimale di punti ferita di 1 per tutto l\'evento.', 1, 11, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(156, 'militare', 'Opportunista', 'Quando il personaggio dichiara BONUS! su un bersaglio diverso da se stesso, può decidere di subire lo<br>stesso BONUS! a sua volta.', 1, 12, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(157, 'militare', 'Batteria ausiliare Medipack', 'Quando il personaggio utilizza un talento del Medipack, se il bersaglio dichiara IMMUNE! non fa partire il<br>Cooldown.', 1, 12, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(158, 'militare', 'Tuta da combattimento MK2', 'Il valore base dei punti Shield garantiti dalle locazioni equipaggiate con una tuta da combattimento<br>corazzata (come indicato a pag. 17) è moltiplicato per 1,5.', 1, 12, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(159, 'militare', 'Shield MK2', 'Se il personaggio ha almeno un Punto Shield base, guadagna +2 punti al suo valore globale.', 1, 12, NULL, 'personale', 'passivo', 0, 2, 0, NULL),
(160, 'militare', 'Controllo dello stress sul campo', 'Il personaggio può dichiarare NEUTRALIZZA! DOLORE! o NEUTRALIZZA! CONFUSIONE! su un bersaglio.', 1, 12, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(161, 'militare', 'Intervento d\'emergenza', 'Il personaggio può dichiarare RIMARGINAZIONE 1! su un bersaglio ferito dopo 30 secondi di interazione.', 1, 12, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(162, 'militare', 'Smuovere', 'Il personaggio può dichiarare NEUTRALIZZA SHOCK! Oppure NEUTRALIZZA PARALISI! toccando il<br>bersaglio.', 1, 12, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(163, 'militare', 'Medipack-Prime cure', 'Il personaggio può dichiarare BONUS! +3 PUNTI FERITA! toccando il bersaglio.', 1, 12, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(164, 'militare', 'Medipack-Antidolorifici ad alto spettro', 'Il valore di BONUS! Conferito con il Medipack è aumentato permanentemente di 1.', 1, 12, 163, 'personale', 'passivo', 0, 0, 0, NULL),
(165, 'militare', 'Medipack-Nanochirurghi integrati', 'Il personaggio può dichiarare NEUTRALIZZA! MUTILAZIONE! Dopo 30 secondi di intervento simulato sul<br>bersaglio toccato.<br>(N.b. La locazione non ricresce miracolosamente: il bersaglio però potrà essere guarito anche se<br>necessita comunque di un innesto se vuole tornare ad usare la locazione colpita da mutilazione)', 1, 12, 163, 'Tocco', 'attivo', 0, 0, 0, NULL),
(166, 'militare', 'Soccorritore di linea', 'Il personaggio, se sta impugnando solo una pistola e niente nell\'altra mano, può aumentare di 1 il danno<br>secondo la scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO!.<br>(NOTA: il bonus è sommabile a qualunque altro bonus disponibile per il giocatore con le pistole.)', 1, 12, -3, 'personale', 'passivo', 0, 0, 0, NULL),
(167, 'militare', 'Medipack-Resettare', 'Il personaggio può dichiarare NEUTRALIZZA! BONUS! ad un bersaglio non ostile.<br>Tempo Hacking: 10 secondi.', 1, 12, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(168, 'militare', 'Controller-Reinizializzazione dispositivi elettronici', 'Il personaggio può dichiarare NEUTRALIZZA! BLOCCO! su un qualunque impianto cibernetico (arto o<br>locazione vitale) che sta toccando.<br>Tempo Hacking: 10 secondi.', 1, 12, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(169, 'militare', 'Controller-Modifica frequenza shield', 'Il personaggio può dichiarare BONUS! +5 SHIELD! su un bersaglio equipaggiato con una Tuta da<br>Combattimento.<br>Tempo Hacking: 10 secondi.', 1, 12, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(170, 'militare', 'Controller-Miglioramento firmware innesti', 'Il personaggio può dichiarare BONUS! DIFESA MENTALE +1! Su un bersaglio.<br>Tempo Hacking: 10 secondi.<br>NOTA: se il bersaglio è privo di un qualunque tipo di innesto cerebrale DEVE dichiarare IMMUNE! Al<br>bonus sopra descritto.', 1, 12, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(171, 'militare', 'Controller-Campo difensivo', 'Il Personaggio può dichiarare BONUS! SHIELD +X! (dove X è il punteggio di Shield del personaggio)<br>RAGGIO 10!.<br>Tempo Hacking: 10 secondi.<br>Al termine, il personaggio subisce BLOCCO! CONTINUO! TEMPO 1 ORA! al proprio Controller.', 1, 12, -1, 'Raggio 10 metri', 'attivo', 0, 0, 0, NULL),
(172, 'militare', 'Protezione firmware avanzata', 'Il personaggio aumenta permanentemente di 1 il suo punteggio di Difesa Mentale.', 1, 13, NULL, 'personale', 'passivo', 0, 0, 1, NULL),
(173, 'militare', 'Schermatura celebrale', 'Il personaggio aumenta permanentemente di 2 il suo punteggio di Difesa Mentale (quest\'abilità va a<br>sostituire \"Protezione Firmware Avanzata\").', 1, 13, 172, 'personale', 'passivo', 0, 0, 2, NULL),
(174, 'militare', 'Tuta corazzata \"\"Redentore\"\"', 'Il personaggio se equipaggiato con una tuta da combattimento corazzata aumenta di 2 il punteggio di<br>Shield ottenuto dalla suddetta tuta.<br>Una volta per giornata di gioco il personaggio, quando entra in status di Coma, può subire GUARIGIONE<br>5! Subendo quindi BLOCCO! CONTINUO! allo Shield.', 1, 13, NULL, 'personale', 'passivo', 0, 2, 0, NULL),
(175, 'militare', 'Angelo custode', 'Il personaggio, quando equipaggiato con uno Scudo e lo sta imbracciando, può dichiarare IMMUNE! Ad<br>una chiamata di danno su un bersaglio entro 1 metro da lui e subire quella chiamata sul suo Scudo.', 1, 13, NULL, '1 metro', 'attivo', 0, 0, 0, NULL),
(176, 'militare', 'Non fa male! Non fa male!', 'Il personaggio quando armato con un Fucile d\'assalto può dichiarare DOLORE! in sostituzione al normale<br>danno portato dal colpo successivo.', 1, 13, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(177, 'militare', 'Controller-Stimolanti da battaglia', 'Il personaggio può dichiarare BONUS! DANNI +1!<br>Tempo Hacking: 10 secondi.', 1, 13, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(178, 'militare', 'Medico da battaglia', 'Il personaggio mentre è impegnato a prestare soccorso non può essere distratto da nessuno stimolo<br>inferiore ad una lesione fisica. Mentre sta utilizzando il Medipack per curare un bersaglio può dichiarare<br>IMMUNE! ai seguenti effetti: DOLORE! - PARALISI! - CONFUSIONE! - SHOCK! - DISARMO! - SPINTA!', 1, 13, 179, 'personale', 'passivo', 0, 0, 0, NULL),
(179, 'militare', 'Mente razionale', 'Il personaggio può dichiarare IMMUNE! alla chiamata PAURA! su se stesso o NEUTRALIZZA PAURA!<br>toccando un altro bersaglio.', 1, 13, NULL, 'personale/tocco', 'attivo', 0, 0, 0, NULL);
INSERT INTO `abilita` (`id_abilita`, `tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`, `abilitacol`) VALUES
(180, 'militare', 'Deviare energia', 'Il personaggio può spendere 6 Punti Shield per terminare un Cooldown attivo.', 1, 13, 174, 'personale', 'passivo', 0, 0, 0, NULL),
(181, 'militare', 'Controller-Trasferimento energetico', 'Il personaggio può dichiarare BONUS! X SHIELD! (dove X sono i suoi punti Shield che vuole trasferire).<br>Tempo Hacking: 10 secondi.<br>NOTA: Il personaggio deve avere almeno 1 punto Shield attivo per poter effettuare il trasferimento.', 1, 13, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(182, 'militare', 'Controller-Potenziamento nanoriparatori', 'Il personaggio può dichiarare BONUS! +5 SHIELD! IMMUNE! a CRASH! su un qualunque bersaglio<br>equipaggiato con una tuta da combattimento.<br>Tempo Hacking: 10 secondi.', 1, 13, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(183, 'militare', 'Ultimo riparo', 'Il personaggio, se impugna uno scudo grande può dichiarare IMMUNE! ad una chiamata ad area o a<br>raggio; lo scudo impugnato subisce DISINTEGRAZIONE!', 1, 13, 175, 'personale', 'passivo', 0, 0, 0, NULL),
(184, 'militare', 'Medipack-Vettore curativo aerodisperso', 'Il personaggio può, dopo 10 secondi di utilizzo del Medipack, dichiarare BONUS! +2 PUNTI FERITA!<br>RAGGIO 10!. Subisce quindi la dichiarazione BLOCCO! CONTINUO! TEMPO 5 MINUTI! al Medipack.', 1, 13, NULL, 'Raggio 10 metri', 'attivo', 0, 0, 0, NULL),
(185, 'militare', 'Medipack-Interfaccia biomeccanica di manutenzione e cura', 'Il personaggio può dichiarare BONUS! +2 PUNTI FERITA! e RIPARAZIONE 2! ad un bersaglio.<br>Tempo Hacking: 10 secondi.', 1, 13, NULL, 'Tocco', 'attivo', 0, 0, 0, NULL),
(186, 'militare', 'Medipack-Dispositivo di cura automatico d\'emergenza', 'Il personaggio, se cade in stato di Coma, può prima di cadere dichiarare BONUS! +1 PUNTO FERITA!<br>Raggio 10!. E subire BLOCCO! Al Medipack.', 1, 13, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(187, 'militare', 'Inganno della nera signora', 'Il personaggio può sostituire il danno della sua arma con la chiamata GUARIGIONE 2! VELENO! BONUS!<br>+ X PUNTI FERITA! Dove X è il danno che avrebbe causato, con un massimale di 4.<br>(N.B. il tempo di Cooldown di questa abilità è 60 secondi e NON 30 secondi)', 1, 13, -1, 'personale', 'attivo', 0, 0, 0, NULL),
(188, 'militare', 'Batteria schermata', 'Quando utilizzi un talento collegato al controller, se il bersaglio dichiara IMMUNE! ad ELETTRO!, il<br>Cooldown non viene attivato.', 1, 14, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(189, 'militare', 'Non a me, a lui!', 'Quando il personaggio subisce una chiamata di natura ELETTRO! può dichiarare IMMUNE! ma DEVE<br>ripetere la stessa chiamata (priva della natura ELETTRO!) su un bersaglio entro 10 metri a lui NON<br>ostile.', 1, 14, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(190, 'militare', 'Tuta da combattimento MK2', 'Il punteggio di Shield garantito da una tuta da combattimento equipaggiata aumenta di 1, se la tuta<br>fornisce al personaggio almeno un punto Shield Base.', 1, 14, NULL, 'personale', 'passivo', 0, 1, 0, NULL),
(191, 'militare', 'Shield MK2', 'Se il personaggio ha almeno un Punto Shield base, guadagna +2 punti al suo valore globale.', 1, 14, NULL, 'personale', 'passivo', 0, 2, 0, NULL),
(192, 'militare', 'Tempesta di piombo', 'Il personaggio può aggiungere PAURA! al prossimo colpo sparato con un mitragliatore pesante.', 1, 14, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(193, 'militare', 'Perfezionamento tattich d\'intrusione', 'Il personaggio ha + 1 permanente alle sue dichiarazioni di Hacking.', 1, 14, 194, 'personale', 'passivo', 0, 0, 0, NULL),
(194, 'militare', 'Brute force', 'Il personaggio può ripetere il lancio di un programma di Hacking: per ogni lancio così effettuato può<br>aumentare di + 1 il valore di lancio del programma, fino a quando il bersaglio non ha subito la chiamata<br>lanciata o se il personaggio compie altre azioni.<br>Se un bersaglio dichiara immune a ELETTRO! L\'abilità si interrompe immediatamente.<br>(Esempio: Thug Sta lanciando il potere di distrazione su Erebron. Attende 10 secondi e poi dichiara<br>\"ELETTRO 1! CONFUSIONE!\" ad Erebron, il quale dichiara IMMUNE! e prosegue in quello che sta<br>facendo. Thug continua il conteggio dei 10 secondi successivi, per poi dichiarare \"ELETTRO 2!<br>CONFUSIONE!\" ad Erebron, il quale risponde ancora IMMUNE! e prosegue nelle sue azioni. Thug<br>continua il conteggio dei 10 secondi successivi, per poi dichiarare \"ELETTRO 3! CONFUSIONE!\" ad<br>Erebron, il quale questa volta subisce la chiamata. Il Cooldown di Thug inzierà ora, e lui potrà fare<br>nuove azioni.)', 1, 14, -4, 'personale', 'passivo', 0, 0, 0, NULL),
(195, 'militare', 'Farsi scudo', 'Se il personaggio impugna un Mitragliatore Pesante può dichiarare IMMUNE! ad un colpo subito ma<br>l\'arma subisce l\'effetto BLOCCO! Eccezioni sono le chiamate DISINTEGRAZIONE! (applicata comunque al<br>bersaglio) e le chiamate MUTILAZIONE! o CREPA! che infliggono all\'arma utilizzata la chiamata<br>DISINTEGRAZIONE! invece di BLOCCO!.', 1, 14, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(196, 'militare', 'Controller-Distrazione', 'Il personaggio può dichiarare ELETTRO 1! CONFUSIONE!<br>Tempo Hacking: 10 secondi.', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(197, 'militare', 'Controller-Disarmare', 'Il personaggio può dichiarare ELETTRO 1! DISARMO !<br>Tempo Hacking: 10 secondi.', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(198, 'militare', 'Controller-Dolore', 'Il personaggio può dichiarare ELETTRO 1! DOLORE!<br>Tempo Hacking: 10 secondi.', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(199, 'militare', 'Controller-Rottura', 'Il personaggio può dichiarare ELETTRO 1! CRASH! Shield.<br>Tempo Hacking: 10 secondi.<br>(N.b. Questa abilità ha effetto solo sullo Shield)', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(200, 'militare', 'Controller-Erosione', 'Il personaggio può dichiarare ELETTRO 1! SINGOLO! Su un bersaglio. Dopo averlo effettuato può<br>decidere di rimandare il cool-down standard e, dopo altri 10 secondi, può ripetere la chiamata sullo<br>stesso bersaglio. Può ripetere la stessa dichiarazione, sempre sullo stesso bersaglio e sempre ad<br>intervalli di 10 secondi, un numero di volte illimitato. Quando decide di interrompere la catena parte il<br>cool-down standard dell\'abilità. L\'abilità si considera interrotta se il personaggio è in status incapacitato.<br>Tempo Hacking: 10 secondi.', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(201, 'militare', 'Controller-Paralisi', 'Il personaggio può dichiarare ELETTRO 1! PARALISI!<br>Tempo Hacking : 10 secondi.', 1, 14, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(202, 'militare', 'Schermatura celebrale', 'Il valore di Difesa mentale del personaggio aumenta di 1.', 1, 14, NULL, 'personale', 'passivo', 0, 0, 1, NULL),
(203, 'militare', 'Hacking ad area', 'Il personaggio può, aumentando di 30 secondi il tempo di Hacking, aggiungere IN QUEST\'AREA! al<br>talento di Hacking che sta effettuando, alzando il valore di ELETTRO! a 4.<br>Dopo la dichiarazione subisce CRASH! e BLOCCO! CONTINUO! Alla Batteria.<br>(NOTA: l\'angolo formato dalle braccia per determinare l\'area d\'effetto DEVE essere massimo 90°.)<br>(N.B. Non può mai essere utilizzata con in combinazione con Brute-Force).', 1, 14, -1, 'personale', 'passivo', 0, 0, 0, NULL),
(204, 'militare', 'Parassita elettrico', 'Il personaggio mentre è in fase di cool-down può, toccando un bersaglio consenziente e non già sotto<br>BLOCCO!, dichiarare BLOCCO! Batteria! TEMPO 1 minuto! E abbreviare il suo cool-down attualmente<br>attivo di 30 secondi fino ad arrivare a minimo 0 secondi.', 1, 15, NULL, 'Contatto', 'passivo', 0, 0, 0, NULL),
(205, 'militare', 'Amplificazione dell\'area', 'Il personaggio quando usa una granata può aumentare di 2 metri il raggio della granata.', 1, 15, NULL, 'personale', 'passivo', 0, 0, 0, NULL),
(206, 'militare', 'Schermatura celebrale avanzata', 'Il valore di Difesa mentale del personaggio aumenta di 2. (Sostituisce il bonus dato da Schermatura Cerebrale)', 1, 15, 173, 'personale', 'passivo', 0, 0, 2, NULL),
(207, 'militare', 'Controller-Sovraccarico elettromagnetico', 'Il personaggio può dichiarare ELETTRO 1! TRIPLO! su fino a 3 bersagli differenti.<br>Tempo Hacking : 10 secondi.<br>(N.B. Non può mai essere utilizzata con Hacking ad area)', 1, 15, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(208, 'militare', 'Controller-Smorzamento neurale', 'Il personaggio può dichiarare ELETTRO 1! BONUS! MENO -1 DANNI!<br>Tempo Hacking : 10 secondi.', 1, 15, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(209, 'militare', 'Granata congelante', 'Il personaggio può aggiungere la chiamata GELO! Al prossimo colpo con il lanciagranate.', 1, 15, 205, 'personale', 'attivo', 0, 0, 0, NULL),
(210, 'militare', 'Fuoco di copertura', 'Il personaggio può dichiarare PAURA! IN QUEST\'AREA! Se impugna un mitragliatore pesante e sta già<br>sparando nella stessa direzione. Il personaggio dovrà continuare a sparare nella direzione generica in<br>cui ha effettuato la dichiarazione, fermandosi solo quando avrà terminato il caricatore o sarà in qualche<br>modo incapacitato.<br>(NOTA: l\'angolo formato dalle braccia per determinare l\'area d\'effetto DEVE essere massimo 90°.)', 1, 15, NULL, 'personale', 'attivo', 0, 0, 0, NULL),
(211, 'militare', 'Colpo di sponda', 'Dopo aver sparato un colpo con il lanciagranate, se il colpo manca il bersaglio il personaggio potrà<br>dichiarare a dito, su un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo<br>la scala:<br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - A ZERO! - COMA!', 1, 15, 209, 'personale', 'attivo', 0, 0, 0, NULL),
(212, 'militare', 'Confettone', 'Il personaggio può, strappando il cartellino di una granata da lancio, effettuare la stessa chiamata<br>(senza dichiarare GRANATA! RAGGIO X!) con il prossimo colpo sparato con il lanciagranate.', 1, 15, 209, 'personale', 'attivo', 0, 0, 0, NULL),
(213, 'militare', 'Controller-Alterare percezioni', 'Il personaggio può dichiarare ELETTRO 1! COMANDO! UCCIDILO!<br>Tempo Hacking : 10 secondi.<br>(N.B. Non può essere utilizzata con Hacking ad area)', 1, 15, NULL, '10 metri', 'attivo', 0, 0, 0, NULL),
(214, 'militare', 'Controller-Svanire dalla mente', 'Il personaggio può dichiarare ELETTRO 1! COMANDO! IGNORAMI!<br>Tempo Hacking : 10 secondi.', 1, 15, 213, '10 metri', 'attivo', 0, 0, 0, NULL),
(215, 'militare', 'Controller-Fotografia', 'Il personaggio può dichiarare ELETTRO 1! PARALISI! TEMPO 1 Minuto!<br>Tempo Hacking : 10 secondi.', 1, 15, 214, '10 metri', 'attivo', 0, 0, 0, NULL),
(216, 'militare', 'Controller-Blocco totale', 'Il personaggio può dichiarare ELETTRO1! CRASH! BLOCCO!<br>Tempo Hacking : 10 secondi.<br>(N.B. Non può mai essere utilizzata con Hacking ad area)<br>(N.B. il tempo di Cooldown di questa abilità è 60 secondi e NON 30 secondi)', 1, 15, -7, '10 metri', 'attivo', 0, 0, 0, NULL),
(217, 'militare', 'Controller-Cortocircuito', 'Il personaggio può dichiarare ELETTRO 1! NEUTRALIZZA BONUS!<br>Tempo Hacking : 10 secondi.', 1, 15, 214, '10 metri', 'attivo', 0, 0, 0, NULL),
(218, 'militare', 'Saturare l\'area', 'Il personaggio può aggiungere la chiamata IN QUEST\'AREA! al danno base della sua arma se impugna un mitragliatore pesante. Fino a quando continua a sparare può ripetere la dichiarazione IN QUEST\'AREA! Una volta ogni cinque secondi finchè non si muove o viene incapacitato.<br><br>(NOTA: l\'angolo formato dalle braccia per determinare l\'area d\'effetto DEVE essere massimo 90°.)', 1, 15, 210, 'personale', 'attivo', 0, 0, 0, NULL),
(219, 'militare', 'Front toward enemy', 'Il personaggio, subendo la chiamata CRASH!, può strappare un cartellino Granata e fare la dichiarazione della granata sostituendo la chiamata GRANATA! RAGGIO X! con la chiamata IN QUEST\'AREA!<br><br>(NOTA: l\'angolo formato dalle braccia per determinare l\'area d\'effetto DEVE obbligatoriamente essere compreso tra 90° e 180°.)', 1, 15, -1, 'personale', 'attivo', 0, 0, 0, NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `cartellini`
--

CREATE TABLE `cartellini` (
  `id_cartellino` int(11) NOT NULL,
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
  `creatore_cartellino` varchar(255) NOT NULL DEFAULT 'rebootlivebg@gmail.com'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `cartellino_has_etichette`
--

CREATE TABLE `cartellino_has_etichette` (
  `cartellini_id_cartellino` int(11) NOT NULL,
  `etichetta` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struttura della tabella `classi`
--

CREATE TABLE `classi` (
  `id_classe` int(255) NOT NULL,
  `tipo_classe` set('civile','militare') COLLATE utf8_unicode_ci NOT NULL,
  `nome_classe` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `mente_base_classe` int(5) NOT NULL DEFAULT '0',
  `shield_max_base_classe` int(5) NOT NULL DEFAULT '0',
  `prerequisito_classe` int(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `classi`
--

INSERT INTO `classi` (`id_classe`, `tipo_classe`, `nome_classe`, `mente_base_classe`, `shield_max_base_classe`, `prerequisito_classe`) VALUES
(1, 'civile', 'Sportivo', 0, 0, NULL),
(2, 'civile', 'Giornalista', 0, 0, NULL),
(3, 'civile', 'Netrunner', 0, 0, NULL),
(4, 'civile', 'Tecnico', 0, 0, NULL),
(5, 'civile', 'Biomedico', 0, 0, NULL),
(6, 'civile', 'Guardia di Sicurezza', 0, 0, NULL),
(7, 'civile', 'Sciacallo', 0, 0, NULL),
(8, 'militare', 'Guardiano Base', 1, 6, NULL),
(9, 'militare', 'Guardiano Avanzata', 0, 0, 8),
(10, 'militare', 'Assaltatore Base', 0, 3, NULL),
(11, 'militare', 'Assaltatore Avanzata', 0, 0, 10),
(12, 'militare', 'Supporto Base', 1, 6, NULL),
(13, 'militare', 'Supporto Avanzata', 0, 0, 12),
(14, 'militare', 'Guastatore Base', 2, 3, NULL),
(15, 'militare', 'Guastatore Avanzata', 0, 0, 14);

-- --------------------------------------------------------

--
-- Struttura della tabella `componenti_acquistati`
--

CREATE TABLE `componenti_acquistati` (
  `id_acquisto` int(11) NOT NULL,
  `cliente_acquisto` int(11) NOT NULL,
  `id_componente_acquisto` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `importo_acquisto` int(11) NOT NULL,
  `data_acquisto` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `componenti_crafting`
--

--
-- Struttura della tabella `componenti_crafting`
--

CREATE TABLE `componenti_crafting` (
  `id_componente` varchar(255) NOT NULL,
  `nome_componente` varchar(255) NOT NULL,
  `tipo_crafting_componente` set('tecnico','programmazione','chimico') NOT NULL,
  `tipo_componente` set('parametro_x','parametro_y','parametro_z','struttura','batteria','applicativo','supporto','cerotto','fiala','solido','sostanza') NOT NULL,
  `costo_attuale_componente` int(255) DEFAULT NULL,
  `costo_vecchio_componente` int(255) DEFAULT NULL,
  `fcc_componente` int(11) DEFAULT NULL,
  `valore_param_componente` int(11) DEFAULT NULL,
  `volume_componente` int(11) DEFAULT NULL,
  `energia_componente` int(11) DEFAULT NULL,
  `fattore_legame_componente` varchar(255) DEFAULT NULL,
  `curativo_primario_componente` varchar(255) DEFAULT NULL,
  `tossico_primario_componente` varchar(255) DEFAULT NULL,
  `psicotropo_primario_componente` varchar(255) DEFAULT NULL,
  `curativo_secondario_componente` varchar(255) DEFAULT NULL,
  `tossico_secondario_componente` varchar(255) DEFAULT NULL,
  `psicotropo_secondario_componente` varchar(255) DEFAULT NULL,
  `possibilita_dipendeza_componente` varchar(255) DEFAULT NULL,
  `effetto_sicuro_componente` varchar(255) DEFAULT NULL,
  `descrizione_componente` text,
  `tipo_applicativo_componente` varchar(255) DEFAULT NULL,
  `visibile_ravshop_componente` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `componenti_crafting`
--

INSERT INTO `componenti_crafting` (`id_componente`, `nome_componente`, `tipo_crafting_componente`, `tipo_componente`, `costo_attuale_componente`, `costo_vecchio_componente`, `fcc_componente`, `valore_param_componente`, `volume_componente`, `energia_componente`, `fattore_legame_componente`, `curativo_primario_componente`, `tossico_primario_componente`, `psicotropo_primario_componente`, `curativo_secondario_componente`, `tossico_secondario_componente`, `psicotropo_secondario_componente`, `possibilita_dipendeza_componente`, `effetto_sicuro_componente`, `descrizione_componente`, `tipo_applicativo_componente`, `visibile_ravshop_componente`) VALUES
('A002', 'Emettitore laser mk2', 'tecnico', 'applicativo', 70, 81, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'gadget', '1'),
('A003', 'Emettitore laser mk3', 'tecnico', 'applicativo', 90, 115, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'gadget', '1'),
('A004', 'Emettitore plasma mk1', 'tecnico', 'applicativo', 600, 60, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di bassa qualità', 'gadget', '1'),
('A005', 'Emettitore plasma mk2', 'tecnico', 'applicativo', 900, 90, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma standard', 'gadget', '1'),
('A006', 'Emettitore plasma mk3', 'tecnico', 'applicativo', 1200, 120, 1, NULL, -1, -45, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di alta qualità', 'gadget', '1'),
('A008', 'Emettitore  fusore mk2', 'tecnico', 'applicativo', 2600, 200, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare QUADRUPLO!', 'Emettitore fusore standard', 'gadget', '1'),
('A009', 'Emettitore  fusore mk3', 'tecnico', 'applicativo', 3250, 250, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare QUADRUPLO!', 'Emettitore fusore di alta qualità', 'gadget', '1'),
('A010', 'Emettitore laser per pistola mk1', 'tecnico', 'applicativo', 25, 21, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di bassa qualità', 'pistola', '1'),
('A011', 'Emettitore laser per pistola mk2', 'tecnico', 'applicativo', 20, 15, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'pistola', '1'),
('A012', 'Emettitore laser per pistola mk3', 'tecnico', 'applicativo', 15, 10, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'pistola', '1'),
('A013', 'Emettitore laser per fucile d\'assalto mk1', 'tecnico', 'applicativo', 30, 26, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di bassa qualità', 'fucile d\'assalto', '1'),
('A014', 'Emettitore laser per fucile d\'assalto mk2', 'tecnico', 'applicativo', 35, 31, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'fucile d\'assalto', '1'),
('A015', 'Emettitore laser per fucile d\'assalto mk3', 'tecnico', 'applicativo', 40, 44, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'fucile d\'assalto', '1'),
('A016', 'Emettitore laser per shotgun mk1', 'tecnico', 'applicativo', 30, 33, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di bassa qualità', 'shotgun', '1'),
('A017', 'Emettitore laser per shotgun mk2', 'tecnico', 'applicativo', 35, 33, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'shotgun', '1'),
('A018', 'Emettitore laser per shotgun mk3', 'tecnico', 'applicativo', 40, 45, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'shotgun', '1'),
('A019', 'Emettitore laser per mitragliatore mk1', 'tecnico', 'applicativo', 30, 29, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di bassa qualità', 'mitragliatore', '1'),
('A020', 'Emettitore laser per mitragliatore mk2', 'tecnico', 'applicativo', 35, 32, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'mitragliatore', '1'),
('A021', 'Emettitore laser per mitragliatore mk3', 'tecnico', 'applicativo', 40, 52, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'mitragliatore', '1'),
('A022', 'Emettitore laser per fucile di precisione mk1', 'tecnico', 'applicativo', 30, 29, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di bassa qualità', 'fucile di precisione', '1'),
('A023', 'Emettitore laser per fucile di precisione mk2', 'tecnico', 'applicativo', 35, 35, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser standard', 'fucile di precisione', '1'),
('A024', 'Emettitore laser per fucile di precisione mk3', 'tecnico', 'applicativo', 40, 51, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare DOPPIO!', 'Emettitore laser di alta qualità', 'fucile di precisione', '1'),
('A025', 'Emettitore plasma per pistola mk1', 'tecnico', 'applicativo', 360, 40, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di bassa qualità', 'pistola', '1'),
('A026', 'Emettitore plasma per pistola mk2', 'tecnico', 'applicativo', 400, 45, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma standard', 'pistola', '1'),
('A027', 'Emettitore plasma per pistola mk3', 'tecnico', 'applicativo', 450, 50, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di alta qualità', 'pistola', '1'),
('A028', 'Emettitore plasma per fucile d\'assalto mk1', 'tecnico', 'applicativo', 350, 40, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di bassa qualità', 'fucile d\'assalto', '1'),
('A029', 'Emettitore plasma per fucile d\'assalto mk2', 'tecnico', 'applicativo', 400, 45, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma standard', 'fucile d\'assalto', '1'),
('A030', 'Emettitore plasma per fucile d\'assalto mk3', 'tecnico', 'applicativo', 450, 50, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di alta qualità', 'fucile d\'assalto', '1'),
('A031', 'Emettitore plasma per shotgun mk1', 'tecnico', 'applicativo', 350, 40, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di bassa qualità', 'shotgun', '1'),
('A032', 'Emettitore plasma per shotgun mk2', 'tecnico', 'applicativo', 400, 45, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma standard', 'shotgun', '1'),
('A033', 'Emettitore plasma per shotgun mk3', 'tecnico', 'applicativo', 450, 50, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di alta qualità', 'shotgun', '1'),
('A034', 'Emettitore plasma per fucile di precisione mk1', 'tecnico', 'applicativo', 350, 40, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di bassa qualità', 'fucile di precisione', '1'),
('A035', 'Emettitore plasma per fucile di precisione mk2', 'tecnico', 'applicativo', 400, 45, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma standard', 'fucile di precisione', '1'),
('A036', 'Emettitore plasma per fucile di precisione mk3', 'tecnico', 'applicativo', 450, 50, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO!', 'Emettitore plasma di alta qualità', 'fucile di precisione', '1'),
('A037', 'Emettitore instabile plasma mk1', 'tecnico', 'applicativo', 400, 40, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'gadget', '1'),
('A038', 'Emettitore instabile plasma mk2', 'tecnico', 'applicativo', 500, 50, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'gadget', '1'),
('A039', 'Emettitore instabile fusore mk1', 'tecnico', 'applicativo', 700, 70, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare QUADRUPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'gadget', '1'),
('A040', 'Emettitore instabile fusore mk2', 'tecnico', 'applicativo', 650, 65, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare QUADRUPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'gadget', '1'),
('A041', 'Emettitore instabile plasma per pistola mk1', 'tecnico', 'applicativo', 300, 30, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'pistola', '1'),
('A042', 'Emettitore instabile plasma per pistola mk2', 'tecnico', 'applicativo', 350, 35, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'pistola', '1'),
('A043', 'Emettitore instabile plasma per fucile d\'assalto mk1', 'tecnico', 'applicativo', 400, 40, 1, NULL, -1, -50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'fucile d\'assalto', '1'),
('A044', 'Emettitore instabile plasma per fucile d\'assalto mk2', 'tecnico', 'applicativo', 450, 45, 1, NULL, -1, -45, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'fucile d\'assalto', '1'),
('A045', 'Emettitore instabile plasma per shotgun mk1', 'tecnico', 'applicativo', 500, 50, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'shotgun', '1'),
('A046', 'Emettitore instabile plasma per shotgun mk2', 'tecnico', 'applicativo', 550, 55, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'shotgun', '1'),
('A047', 'Emettitore instabile plasma per fucile di precisione mk1', 'tecnico', 'applicativo', 600, 60, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'fucile di precisione', '1'),
('A048', 'Emettitore instabile plasma per fucile di precisione mk2', 'tecnico', 'applicativo', 650, 65, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare TRIPLO! Tra un colpo e il successivo è necessario attendere 30 secondi durante i quali può comunque sparare ma DEVE dichiarare DOPPIO!', 'Emettitore che necessita di raffreddamento', 'fucile di precisione', '1'),
('A049', 'Emettitore sovralimentato adattivo mk1', 'tecnico', 'applicativo', 7000, 8680, 1, NULL, -3, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'gadget', '1'),
('A050', 'Emettitore sovralimentato adattivo mk2', 'tecnico', 'applicativo', 8000, 9440, 1, NULL, -3, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'gadget', '1'),
('A051', 'Emettitore sovralimentato per pistola mk1', 'tecnico', 'applicativo', 5000, 4400, 1, NULL, -2, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'pistola', '1'),
('A052', 'Emettitore sovralimentato per pistola mk2', 'tecnico', 'applicativo', 6000, 6000, 1, NULL, -2, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'pistola', '1'),
('A053', 'Emettitore sovralimentato per fucile d\'assalto mk1', 'tecnico', 'applicativo', 5000, 4250, 1, NULL, -3, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'fucile d\'assalto', '1'),
('A054', 'Emettitore sovralimentato per fucile d\'assalto mk2', 'tecnico', 'applicativo', 6000, 7020, 1, NULL, -3, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'fucile d\'assalto', '1'),
('A055', 'Emettitore sovralimentato per shotgun mk1', 'tecnico', 'applicativo', 5000, 4900, 1, NULL, -3, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'shotgun', '1'),
('A056', 'Emettitore sovralimentato per shotgun mk2', 'tecnico', 'applicativo', 6000, 6000, 1, NULL, -3, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'shotgun', '1'),
('A057', 'Emettitore sovralimentato per mitragliatore mk1', 'tecnico', 'applicativo', 5000, 5850, 1, NULL, -3, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'mitragliatore', '1'),
('A058', 'Emettitore sovralimentato per mitragliatore mk2', 'tecnico', 'applicativo', 6000, 4260, 1, NULL, -3, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'mitragliatore', '1'),
('A059', 'Emettitore sovralimentato per fucile di precisione mk1', 'tecnico', 'applicativo', 5000, 4600, 1, NULL, -3, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'fucile di precisione', '1'),
('A060', 'Emettitore sovralimentato per fucile di precisione mk2', 'tecnico', 'applicativo', 6000, 5340, 1, NULL, -3, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma aggiunge + 1 alle chiamate fino al massimo di COMA!', 'Emettitore estremamente potente', 'fucile di precisione', '1'),
('A061', 'Alimentazione secondaria a gas', 'tecnico', 'applicativo', 400, 336, 0, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Questo pezzo permette di alimentare  a gas tubi di lancio', 'fucile d\'assalto', '1'),
('A062', 'Tubo di lancio piccolo', 'tecnico', 'applicativo', 400, 352, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Questo pezzo permette di lanciare capsule di piccole dimensioni ma va alimentato a gas', 'fucile di precisione', '1'),
('A063', 'Tubo di lancio grosso', 'tecnico', 'applicativo', 400, 292, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Può essere adoperato come lanciagrante senza necessità della relativa competenza', 'Questo pezzo permette di lanciare capsule di grosse dimensioni ma va alimentato a gas', 'fucile d\'assalto', '1'),
('A064', 'Generatore di campo portatile', 'tecnico', 'applicativo', 3000, 3780, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'oggetto genera 1 punto shield', 'Questo componente genera un piccolo campo shield', 'scudo', '1'),
('A065', 'Generatore di campo portatile  migliorato', 'tecnico', 'applicativo', 5000, 3550, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'oggetto genera 2 punti shield', 'Questo componente genera un piccolo campo shield', 'scudo', '1'),
('A066', 'Dissipatore di energia', 'tecnico', 'applicativo', 7000, 5180, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma può dichiarare DOLORE!in sostituzione al danno, ma dopo deve attendere 30 secondi prima di poter riutilizzare questo effetto', 'questo componente, se applicato a un\'arma, causa colpi molto dolorosi', 'pistola,shotgun,mitragliatore,fucile di precisione,fucile d\'assalto', '1'),
('A067', 'Igniter', 'tecnico', 'applicativo', 9000, 8730, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma può dichiarare FUOCO! Ma dopo deve attendere 30 secondi prima di poter riutilizzare questo effetto', 'permette alle armi di causare colpi incendiari', 'pistola,shotgun,mitragliatore,fucile di precisione,fucile d\'assalto', '1'),
('A068', 'Cooler', 'tecnico', 'applicativo', 9000, 9990, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma può dichiarare GELO! Ma dopo deve attendere 30 secondi prima di poter riutilizzare questo effetto', 'permette alle armi di causare colpi congelanti', 'pistola,shotgun,mitragliatore,fucile di precisione,fucile d\'assalto', '1'),
('A069', 'Stasis', 'tecnico', 'applicativo', 7000, 7070, 1, NULL, -2, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma può dichiarare PARALISI! Ma dopo deve attendere 30 secondi prima di poter riutilizzare questo effetto', 'permette di bloccare temporaneamente il nemico', 'gadget', '1'),
('A070', 'Camera di combustione per proiettili solidi da pistola', 'tecnico', 'applicativo', 15000, 17850, 1, NULL, -2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare SINGOLO! DIRETTO! , non è possibile in alcun modo adoperare abilità attive con quest\'arma , necessita di munizionamento specifico. E\' immune a BLOCCO!', 'permette a una pistola di sparare proiettili solidi', 'pistola', '1'),
('A071', 'Camera di combustione per proiettili solidi da fucile d\'assalto', 'tecnico', 'applicativo', 30000, 32700, 1, NULL, -4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare SINGOLO! DIRETTO! , non è possibile in alcun modo adoperare abilità attive con quest\'arma , necessita di munizionamento specifico. E\' immune a BLOCCO!', 'permette a un fucile d\'assalto di sparare proiettili solidi', 'fucile d\'assalto', '1'),
('A072', 'Camera di combustione per proiettili solidi da fucile di precisione', 'tecnico', 'applicativo', 20000, 15200, 1, NULL, -4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare SINGOLO! DIRETTO! , non è possibile in alcun modo adoperare abilità attive con quest\'arma , necessita di munizionamento specifico. E\' immune a BLOCCO!', 'permette a un fucile di precisione di sparare proiettili solidi', 'fucile di precisione', '1'),
('A073', 'Camera di combustione per proiettili solidi da shotgun', 'tecnico', 'applicativo', 20000, 16200, 1, NULL, -4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare SINGOLO! DIRETTO! , non è possibile in alcun modo adoperare abilità attive con quest\'arma , necessita di munizionamento specifico. E\' immune a BLOCCO!', 'permette a uno shotgun di sparare proiettili solidi', 'shotgun', '1'),
('A074', 'Camera di combustione per proiettili solidi da mitragliatore', 'tecnico', 'applicativo', 30000, 23700, 1, NULL, -4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'arma DEVE dichiarare SINGOLO! DIRETTO! , non è possibile in alcun modo adoperare abilità attive con quest\'arma , necessita di munizionamento specifico. E\' immune a BLOCCO!', 'permette a un mitragliatore di sparare proiettili solidi', 'mitragliatore', '1'),
('A075', 'Attuatore cinetico di bassa qualità per braccio', 'tecnico', 'applicativo', 200, 206, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non possono essere aggiunti potenziamenti al pezzo, è necessaria un\'operazione chirurgica per montarlo', 'arto artificiale di base non migliorabile', 'protesi_braccio', '1'),
('A076', 'Attuatore cinetico di media qualità per braccio', 'tecnico', 'applicativo', 400, 388, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non possono essere aggiunti potenziamenti al pezzo, è necessaria un\'operazione chirurgica per montarlo', 'arto artificiale di base non migliorabile', 'protesi_braccio', '1'),
('A077', 'Attuatore cinetico di alta qualità per braccio', 'tecnico', 'applicativo', 1000, 1010, 0, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'E\' necessaria un\'operazione chirurgica per montarlo deve essere migliorato ', 'arto artificiale da implementare con sistemi ausiliari', 'protesi_braccio', '1'),
('A078', 'Attuatore cinetico di bassa qualità per gamba', 'tecnico', 'applicativo', 200, 140, 1, NULL, -1, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non possono essere aggiunti potenziamenti al pezzo, è necessaria un\'operazione chirurgica per montarlo', 'arto artificiale di base non migliorabile', 'protesi_gamba', '1'),
('A079', 'Attuatore cinetico di media qualità per gamba', 'tecnico', 'applicativo', 400, 360, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Non possono essere aggiunti potenziamenti al pezzo, è necessaria un\'operazione chirurgica per montarlo', 'arto artificiale di base non migliorabile', 'protesi_gamba', '1'),
('A080', 'Attuatore cinetico di alta qualità per gamba', 'tecnico', 'applicativo', 1000, 900, 0, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'E\' necessaria un\'operazione chirurgica per montarlo deve essere migliorato ', 'arto artificiale da implementare con sistemi ausiliari', 'protesi_gamba', '1'),
('A081', 'Rifrattore cinetico leggero per scudo', 'tecnico', 'applicativo', 700, 588, 0, NULL, -2, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Invece che subire DISINTEGRAZIONE ! Con la chiamata QUADRUPLO si considera in BLOCCO!, l\'oggetto viene disintegrato con le chiamate superiori a QUADRUPLO!', 'Montabile solo su uno scudo', 'scudo', '1'),
('A082', 'Rifrattore cinetico pesante per scudo', 'tecnico', 'applicativo', 600, 756, 0, NULL, -2, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Invece che subire DISINTEGRAZIONE ! Con la chiamata QUADRUPLO si considera in BLOCCO!, l\'oggetto viene disintegrato con le chiamate superiori a QUADRUPLO!', 'Montabile solo su uno scudo', 'scudo', '1'),
('A083', 'Moltiplicatore cinetico', 'tecnico', 'applicativo', 7000, 7910, 1, NULL, -2, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio aggiunge+1 alle proprie chiamate fatte con armi da mischia fino al massimo di A ZERO!', 'aumenta la forza fisica', 'esoscheletro', '1'),
('A084', 'Moltiplicatore cinetico potenziato', 'tecnico', 'applicativo', 15000, 5000, 1, NULL, -2, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio aggiunge+1 alle proprie chiamate fatte con armi da mischia fino al massimo di A ZERO! O +2 ma con il proprio cooldown', 'aumenta la forza fisica', 'esoscheletro', '1'),
('A085', 'Stabilizzatore giroscopico', 'tecnico', 'applicativo', 7000, 9100, 1, NULL, -2, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio può camminare mentre utilizza un oggetto con la regola Posizionamento se non stra utilizzando abilità attive', 'Garantisce maggiore stabilità in movimento', 'esoscheletro', '1'),
('A086', 'Stabilizzatore inerziale', 'tecnico', 'applicativo', 5000, 4500, 1, NULL, -2, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Se il personaggio subisce la chiamata SPINTA  può ridurre di 2 il suo valore fino a un minimo di 0', 'Garantisce al suo utilizzatore un equilibrio eccezionale', 'esoscheletro', '1'),
('A087', 'Filtro per polveri e inquinanti', 'tecnico', 'applicativo', 200, 234, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio subisce le chiamate VELENO! Dopo 30 secondi anziché dopo 10', 'il filtro riduce la potenza delle sostanze tossiche', 'gadget', '1'),
('A088', 'Filtro elettromagnetico per inquinanti', 'tecnico', 'applicativo', 700, 581, 1, NULL, -1, -20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio è immune alla chiamata VELENO! Fino a 3 volte al giorno', 'Il filtro protegge da inquinanti', 'gadget', '1'),
('A089', 'Memoria di massa da 1 T', 'tecnico', 'applicativo', 30, 30, 1, NULL, -1, -10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 1 programma / 10 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A090', 'Memoria di massa da 2 T', 'tecnico', 'applicativo', 50, 36, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 2 programmi / 20 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A091', 'Memoria di massa da 3 T', 'tecnico', 'applicativo', 70, 88, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 3 programmi / 30 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A092', 'Memoria di massa da 4 T', 'tecnico', 'applicativo', 90, 109, 1, NULL, -1, -10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 4 programmi / 40 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A093', 'Memoria di massa da 5 T', 'tecnico', 'applicativo', 100, 77, 1, NULL, -1, -10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 5 programmi / 50 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A094', 'Memoria di massa da 6 T', 'tecnico', 'applicativo', 120, 127, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 6 programmi / 60 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A095', 'Memoria di massa da 7 T', 'tecnico', 'applicativo', 150, 121, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il personaggio può conservare in questo oggetto 7 programmi / 70 stringhe di codice inutilizzate', 'Memoria di massa per programmi', 'gadget', '1'),
('A096', 'Pelle artificiale', 'tecnico', 'applicativo', 400, 320, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Tessuto sintetico che simula la pelle umana', 'protesi_generico,protesi_gamba,protesi_braccio', '1'),
('A097', 'Indicatore GPS', 'tecnico', 'applicativo', 50, 48, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Permette di rintracciare la posizione dell\'oggetto', 'Connettore per geo localizzazione', 'gadget', '1'),
('A098', 'Sistema di comunicazione  a lunga gittata', 'tecnico', 'applicativo', 50, 61, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Permette di chiamare tramite apparecchi in remoto altri apparecchi', 'gadget', '1'),
('A100', 'Diffusore di particelle da  campo', 'tecnico', 'applicativo', 500, 595, 1, NULL, -4, -60, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'oggetto permette di dichiarare RAGGIO 10! in base alle sostanze caricate nel serbatoio', 'Questo apparecchio diffonde sostanze nell\'aria', 'gadget', '1'),
('A101', 'Analizzatore meccanico', 'tecnico', 'applicativo', 500, 540, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio può chiedere allo staff le condizioni di un oggetto danneggiato', 'Analizza le condizioni di un oggetto meccanico', 'gadget', '1'),
('A102', 'Analizzatore biometrico', 'tecnico', 'applicativo', 500, 510, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio può chiedere a un giocatore le sue condizioni mediche ( o allo staff in caso di PNG)', 'Analizza le condizioni di un corpo organico', 'gadget', '1'),
('A103', 'Meccanismo di cucitura organica', 'tecnico', 'applicativo', 200, 202, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Utile per usare abilità di cura, non da però bonus', 'Permette di curare le persone', 'gadget', '1'),
('A104', 'Meccanismo di riparazione', 'tecnico', 'applicativo', 200, 158, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Utile per usare abilità di riparazione, non da però bonus', 'Permette di riparare le cose', 'gadget', '1'),
('A105', 'Ripetitore di segnale di rete', 'tecnico', 'applicativo', 100, 73, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'necessario in un controller', 'Permette di collegarsi a segnali di connessione', 'gadget', '1'),
('A106', 'Placche rinforzate leggere', 'tecnico', 'applicativo', 1500, 1560, 1, NULL, -2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '+1 PF locazionale', 'Placche di rinforzo leggere', 'esoscheletro,protesi_generico,protesi_gamba,protesi_braccio', '1'),
('A107', 'Placche rinforzate pesanti', 'tecnico', 'applicativo', 2500, 2175, 1, NULL, -4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '+2 PF Locazionale', 'Placche di rinforzo pesanti', 'esoscheletro,protesi_generico,protesi_gamba,protesi_braccio', '1'),
('A108', 'Generatore elettromagnetico da detonazione limitata', 'tecnico', 'applicativo', 50, 48, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Granata DOPPIO! RAGGIO 5', 'Genera un impulso che fa detonare il contenitore', 'granata_mischia', '1'),
('A109', 'Generatore elettromagnetico da detonazione ', 'tecnico', 'applicativo', 90, 113, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Granata TRIPLO! RAGGIO 5', 'Genera un impulso che fa detonare il contenitore', 'granata_mischia', '1'),
('A110', 'Generatore magnetico da dispersione a microonde', 'tecnico', 'applicativo', 90, 102, 1, NULL, -1, -10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Da includere una sostanza chimica liquida poi dichiara GRANATA [ effetto del liquido] RAGGIO 5!', 'Causa la vaporizzazione del liquido contenuto', 'gadget', '1'),
('A111', 'Generatore a a carica residua', 'tecnico', 'applicativo', 1500, 1275, 1, NULL, -3, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'L\'oggetto se alimentato con una batteria ricaricabile, genera 1000 unità di corrente per 24 ore, al termine delle quali si considera aver bruciato la batteria che può essere sostituita', 'Generatore da campo che brucia batterie ricaricabili', 'gadget', '1'),
('A112', 'Accumulatore energetico per torcia plasma', 'tecnico', 'applicativo', 1000, 770, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Garantisce  +1 al valore di scassinare', 'Torcia plasma da taglio', 'gadget', '1'),
('A113', 'Analizzatore biologico migliorato', 'tecnico', 'applicativo', 500, 575, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Aumenta di 1 il valore di CURA', 'Permette di curare con maggiore precisione', 'gadget', '1'),
('A114', 'Analizzatore meccanico migliorato', 'tecnico', 'applicativo', 500, 530, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Aumenta di 1 il valore di RIPARAZIONE!', 'Permette di eseguire riparazioni con maggiore precisione', 'gadget', '1'),
('A115', 'Meccanismo di sutura veloce', 'tecnico', 'applicativo', 1000, 810, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Riduce di 30 secondi il tempo di CURA fino a un minimo di 30 secondi', 'Permette di curare in tempi più brevi', 'gadget', '1'),
('A116', 'Meccanismo di saldatura rapida', 'tecnico', 'applicativo', 1000, 730, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Riduce di 30 secondi il tempo di RIPARAZIONE  fino a un minimo di 30 secondi', 'Permette di riparare in tempi più brevi', 'gadget', '1'),
('A117', 'Sistema ottico per videocamere notturne', 'tecnico', 'applicativo', 200, 172, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Permette di adoperare un visore notturno reale', 'Visore notturno', 'gadget', '1'),
('A118', 'Sisetema di ottiche avanzate da telecomunicazioni', 'tecnico', 'applicativo', 200, 226, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Permette di registrare video', 'Visore per videocamere', 'gadget', '1'),
('A119', 'Sistema di ottiche schermate da sovraesposizione luminosa', 'tecnico', 'applicativo', 2000, 2200, 1, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Se impiantato su gadget indossati, elmi o protesi-occhi permette di dichiarare IMMUNE ! Alla chiamata CONFUSIONE!', 'Immunità a confusione su protesi a occhi', 'protesi_generico', '1'),
('A120', 'Labirinto elettronico', 'tecnico', 'applicativo', 10000, 9500, 2, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio aggiunge +1 al proprio valore di difesa mentale se impiantato in una protesi testa', 'Rende difficile le intrusioni elettroniche mentali', 'gadget', '1'),
('A121', 'Dedalo Elettronico', 'tecnico', 'applicativo', 20000, 22400, 2, NULL, -1, -15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio aggiunge +2 al proprio valore di difesa mentale se impiantato in una protesi testa', 'Rende molto difficile le intrusioni elettroniche mentali', 'gadget', '1'),
('A122', 'Schermatura nervosa', 'tecnico', 'applicativo', 1000, 1070, 1, NULL, -2, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio subisce DOLORE! Come CONFUSIONE!', 'Da montare in protesi o corazze riduce la percezione del dolore', 'protesi_generico,protesi_gamba,protesi_braccio,esoscheletro', '1'),
('A123', 'Inibitore nervoso', 'tecnico', 'applicativo', 2000, 1620, 1, NULL, -1, -25, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio DEVE dichiarare IMMUNE a DOLORE!', 'Inibitore del sistema nervoso ( solo protesi)', 'protesi_generico,protesi_gamba,protesi_braccio', '1'),
('A124', 'Serraggio elettromagnetico', 'tecnico', 'applicativo', 500, 370, 1, NULL, -2, -35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il personaggio può dichiarare Immune alla chiamata DISARMO! Se la subisce all\'arto equipaggiatto di questo oggetto', 'Sistema di serraggio elettromagnetico a morsa', 'gadget', '1'),
('A125', 'Placche rinforzate in Carbonio alterato', 'tecnico', 'applicativo', 2000, 1500, 1, NULL, -2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '+3 pf solo eseoscheletro o protesi', 'Sistema di placche corazzate simili quelle montate sugli esoscheletri', 'esoscheletro', '1'),
('A126', 'Protezione Ignifuga', 'tecnico', 'applicativo', 5000, 6150, 2, NULL, -2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Immunità a FUOCO! , conta come 2 upgrade se montato su una armatura, non funziona sulle armi', 'Il materiale con cui è fatto l\'oggetto viene reso ignifugo', NULL, '1'),
('A127', 'Protezione termica', 'tecnico', 'applicativo', 5000, 6350, 2, NULL, -2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Immunità a GELO!, conta come 2 upgrade se montato su una armatura, non funziona sulle armi', 'Il materiale con cui è fatto l\'oggetto viene reso refrattario al freddo', NULL, '1'),
('A128', 'Perforatore a frammentazione per coltelli da lancio', 'tecnico', 'applicativo', 20, 22, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il coltello da lancio dichiara  DOPPIO!', 'Solo per coltelli, li frantuma all\'impatto', 'granata_mischia', '1'),
('A129', 'Perforatore a dispersione per coltelli da lancio', 'tecnico', 'applicativo', 50, 56, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il coltello può essere riempito con una sostanza chimica. In quel caso dichiara VELENO! E la chiamata associata al liquido utilizzato', 'Capsula da dispersione di liquidi per coltelli da lancio', 'granata_mischia', '1'),
('A130', 'Condesatore da soravvarico per coltelli', 'tecnico', 'applicativo', 2500, 1000, 1, NULL, -1, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Il coltello sostituisce la sua chiamata con BLOCCO!', 'Condensatore elettromagnetico per coltelli da lancio', 'granata_mischia', '1'),
('A131', 'Generatore di campo per corazze', 'tecnico', 'applicativo', 100, 93, 1, NULL, -1, -30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'aggiunge+ 1 al valore di shield ma DEVE essere montato su una tuta da combattimento, o una tuta corazzata o un esoscheletro', 'Garantisce uno Shield a una corazza', 'esoscheletro', '1'),
('A132', 'Generatore elettromagnetico da detonazione potenziato', 'tecnico', 'applicativo', 200, 166, 1, NULL, -1, -5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Garanata QUADRUPLO! RAGGIO 5!', 'Genera un impulso che fa detonare il contenitore', 'granata_mischia', '1'),
('A133', 'Generatore di campo per corazze Potenziato', 'tecnico', 'applicativo', 400, 364, 1, NULL, -1, -40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'aggiunge+ 2 al valore di shield ma DEVE essere montato su un esoscheletro', 'Garantisce uno Shield a una corazza', 'esoscheletro', '1'),
('A134', 'Generatore di campo per corazze Maggiorato', 'tecnico', 'applicativo', 800, 936, 1, NULL, -1, -50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'aggiunge+ 3 al valore di shield ma DEVE essere montato su un esoscheletro', 'Garantisce uno Shield a una corazza', 'esoscheletro', '1'),
('B001', 'Batteria NRG  type A - 1', 'tecnico', 'batteria', 10, 7, 0, NULL, -1, 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile economica', NULL, '1'),
('B002', 'Batteria NRG  type A - 2', 'tecnico', 'batteria', 15, 19, 0, NULL, -1, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile economica', NULL, '1'),
('B003', 'Batteria NRG  type A - 3', 'tecnico', 'batteria', 20, 24, 0, NULL, -2, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile economica', NULL, '1'),
('B004', 'Batteria NRG  type A - 4', 'tecnico', 'batteria', 40, 49, 0, NULL, -2, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile economica', NULL, '1'),
('B005', 'Batteria NRG  type A - 5', 'tecnico', 'batteria', 60, 44, 0, NULL, -3, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile economica', NULL, '1'),
('B006', 'Batteria Max Power 1', 'tecnico', 'batteria', 200, 162, 0, NULL, -1, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile potente', NULL, '1'),
('B007', 'Batteria Max power 2', 'tecnico', 'batteria', 450, 549, 0, NULL, -1, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile potente', NULL, '1'),
('B008', 'Batteria Max Power 5', 'tecnico', 'batteria', 1600, 1424, 0, NULL, -2, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile potente', NULL, '1'),
('B009', 'Batteria Max Power  10', 'tecnico', 'batteria', 3000, 300, 0, NULL, -3, 300, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Batteria ricaricabile potente', NULL, '1'),
('B010', 'Batteria monouso A -1', 'tecnico', 'batteria', 5, 6, 0, NULL, -1, 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dotato di 1 carica', 'Batteria da  1 carica usa e getta', NULL, '1'),
('B011', 'Batteria monouso A -2', 'tecnico', 'batteria', 7, 8, 0, NULL, -1, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dotato di 1 carica', 'Batteria da 1 carica usa e getta', NULL, '1'),
('B012', 'Batteria monouso A -3', 'tecnico', 'batteria', 10, 8, 0, NULL, -2, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dotato di 2 cariche', 'Batteria da  2 cariche usa e getta', NULL, '1'),
('B013', 'Batteria monouso A -4', 'tecnico', 'batteria', 20, 15, 0, NULL, -3, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dotato di 2 cariche', 'Batteria da 2 cariche usa e getta', NULL, '1'),
('B014', 'Batteria monouso A -5', 'tecnico', 'batteria', 30, 33, 0, NULL, -3, 30, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'dotato di 3 cariche', 'Batteria da 3 cariche usa e getta', NULL, '1'),
('B015', 'Batteria Hotshot  B-1', 'tecnico', 'batteria', 7, 8, 0, NULL, -1, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Dotato di 2 cariche. Il giocatore può adoperare una carica aggiuntiva per alzare la chiamata di danno di +1 fino a un massimo di Crash!', 'Batteria da 2 cariche sovralimentata', NULL, '1'),
('B016', 'Batteria Hotshot  B-2', 'tecnico', 'batteria', 11, 12, 0, NULL, -1, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Dotato di 3 cariche. Il giocatore può adoperare una carica aggiuntiva per alzare la chiamata di danno di +1 fino a un massimo di Crash!', 'Batteria da 3 cariche sovralimentata', NULL, '1'),
('B017', 'Batteria Hotshot  B-3', 'tecnico', 'batteria', 15, 18, 0, NULL, -2, 35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Dotato di 2 cariche. Il giocatore può adoperare una carica aggiuntiva per alzare la chiamata di danno di +1 fino a un massimo di Crash!', 'Batteria da 2 cariche sovralimentata', NULL, '1'),
('B018', 'Batteria Hotshot  B-4', 'tecnico', 'batteria', 30, 27, 0, NULL, -3, 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Dotato di 3 cariche. Il giocatore può adoperare una carica aggiuntiva per alzare la chiamata di danno di +1 fino a un massimo di Crash!', 'Batteria da 3 cariche sovralimentata', NULL, '1'),
('B019', 'Alimentazione a rete', 'tecnico', 'batteria', 10, 10, 0, NULL, -3, 10000, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'E\' utilizzabile se attaccato a una rete di alimentazione fissa', 'alimentazione a rete da collegare con cavo', NULL, '1'),
('B020', 'Nessuna Batteria', 'tecnico', 'batteria', 0, 0, 0, NULL, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('D001', 'f - x 001', 'chimico', 'fiala', 10, 9, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', NULL, 'liquido per fiala', NULL, '1'),
('D002', 'f - x 002', 'chimico', 'fiala', 400, 428, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', 'Aggiungi alla chiamata CONTINUO!', 'liquido per fiala ad assorbimento lento', NULL, '1'),
('D003', 'p - d 001', 'chimico', 'solido', 10, 13, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', NULL, 'polvere  per composti ', NULL, '1'),
('D004', 'p - d 002', 'chimico', 'solido', 50, 45, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', 'Ripeti la chiamata 2 volte', 'polvere ad assorbimento veloce', NULL, '1'),
('D005', 'gl - 001', 'chimico', 'cerotto', 10, 11, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', NULL, 'emulsione', NULL, '1'),
('D006', 'gl - 002', 'chimico', 'cerotto', 1200, 1176, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', 'Ripeti 2 volte la chiamata e subisci CONTINUO!', 'emulsione massiccia e potente', NULL, '1'),
('S001', 'parti in plastica  -  S', 'tecnico', 'struttura', 100, 104, 0, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Cassa di dimensione piccola standard', NULL, '1'),
('S002', 'parti in plastica -  M', 'tecnico', 'struttura', 150, 147, 0, NULL, 4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Cassa di dimensione media standard', NULL, '1'),
('S003', 'parti in plastica -  L', 'tecnico', 'struttura', 250, 252, 0, NULL, 6, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Cassa di dimensione grande standard', NULL, '1'),
('S004', 'parti in metallo  - S', 'tecnico', 'struttura', 500, 435, 0, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il primo colpo subito sull\'oggetto viene ignorato ( tranne DISINTEGRAZIONE!  e MUTILAZIONE!), la capacità torna usabile quando viene viene riparato.', 'Cassa di dimensione piccola robusta', NULL, '1'),
('S005', 'parti in metallo  - M', 'tecnico', 'struttura', 750, 637, 0, NULL, 4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il primo colpo subito sull\'oggetto viene ignorato ( tranne DISINTEGRAZIONE!  e MUTILAZIONE!), la capacità torna usabile quando viene viene riparato.', 'Cassa di dimensione media robusta', NULL, '1'),
('S006', 'parti in metallo  - L', 'tecnico', 'struttura', 1250, 1550, 0, NULL, 6, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'il primo colpo subito sull\'oggetto viene ignorato ( tranne DISINTEGRAZIONE!  e MUTILAZIONE!), la capacità torna usabile quando viene viene riparato.', 'Cassa di dimensione grande robusta', NULL, '1'),
('S007', 'parti in resina - S', 'tecnico', 'struttura', 50, 50, 0, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto subisce COMA! come DISINTEGRAZIONE OGGETTO!', 'Cassa di dimensione piccola fragile', NULL, '1'),
('S008', 'parti in resina - M', 'tecnico', 'struttura', 75, 57, 0, NULL, 4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto subisce COMA! come DISINTEGRAZIONE OGGETTO!', 'Cassa di dimensione media fragile', NULL, '1'),
('S009', 'parti in resina - L', 'tecnico', 'struttura', 125, 122, 0, NULL, 6, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto subisce COMA! come DISINTEGRAZIONE OGGETTO!', 'Cassa di dimensione grande fragile', NULL, '1'),
('S010', 'parti di recupero -S', 'tecnico', 'struttura', 10, 12, 0, NULL, 2, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto ha la seguente scadenza', 'Cassa di dimensione piccola di recupero', NULL, '1'),
('S011', 'parti di recupero – M', 'tecnico', 'struttura', 15, 18, 0, NULL, 4, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto ha la seguente scadenza', 'Cassa di dimensione media di recupero', NULL, '1'),
('S012', 'parti di recupero – L', 'tecnico', 'struttura', 25, 32, 0, NULL, 6, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto ha la seguente scadenza', 'Cassa di dimensione grande di recupero', NULL, '1'),
('S013', 'parti in Elettrolite – S', 'tecnico', 'struttura', 2000, 1880, 0, NULL, 2, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto genera corrente spontaneamente', 'Cassa di dimensione piccola in Elettrolite', NULL, '1'),
('S014', 'parti in Elettrolite  -M', 'tecnico', 'struttura', 3000, 3180, 0, NULL, 4, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto genera corrente spontaneamente', 'Cassa di dimensione media in Elettrolite', NULL, '1'),
('S015', 'parti in elettrolite – L', 'tecnico', 'struttura', 5000, 5400, 0, NULL, 6, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'l\'oggetto genera corrente spontaneamente', 'Cassa di dimensione grande di Elettrolite', NULL, '1'),
('SS001', 'DX - 01', 'chimico', 'sostanza', 20, 25, NULL, NULL, NULL, NULL, NULL, '2', '7', '7', '0,3', '0,1', '0,9', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS002', 'DX - 02', 'chimico', 'sostanza', 60, 70, NULL, NULL, NULL, NULL, NULL, '6', '9', '1', '1', '0,4', '0,8', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS003', 'DX - 03', 'chimico', 'sostanza', 20, 18, NULL, NULL, NULL, NULL, NULL, '2', '3', '7', '1,3', '0,6', '0,9', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS004', 'DX - 04', 'chimico', 'sostanza', 100, 120, NULL, NULL, NULL, NULL, NULL, '18', '3', '2', '0,7', '0,3', '0,7', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS005', 'DX- 05', 'chimico', 'sostanza', 60, 47, NULL, NULL, NULL, NULL, NULL, '12', '4', '7', '0,1', '0,6', '0,8', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS006', 'DX - 06', 'chimico', 'sostanza', 20, 24, NULL, NULL, NULL, NULL, NULL, '5', '8', '5', '0,6', '0,2', '0,5', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS007', 'DX - 07', 'chimico', 'sostanza', 80, 64, NULL, NULL, NULL, NULL, NULL, '8', '4', '3', '0,8', '1', '0,6', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS008', 'DX - 08', 'chimico', 'sostanza', 60, 57, NULL, NULL, NULL, NULL, NULL, '15', '2', '1', '0,4', '0,4', '0,1', '3', NULL, 'molecola curativa ', NULL, '1'),
('SS009', 'DX - 09', 'chimico', 'sostanza', 60, 72, NULL, NULL, NULL, NULL, NULL, '7', '8', '4', '0,6', '1', '0,1', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS010', 'DX - 10', 'chimico', 'sostanza', 20, 16, NULL, NULL, NULL, NULL, NULL, '8', '9', '3', '0,5', '0,2', '0,2', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS011', 'DX - 11', 'chimico', 'sostanza', 100, 100, NULL, NULL, NULL, NULL, NULL, '15', '4', '1', '0,6', '1', '0,3', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS012', 'DX - 12', 'chimico', 'sostanza', 80, 88, NULL, NULL, NULL, NULL, NULL, '20', '9', '3', '0,4', '0,1', '0,4', '2', NULL, 'molecola curativa ', NULL, '1');
INSERT INTO `componenti_crafting` (`id_componente`, `nome_componente`, `tipo_crafting_componente`, `tipo_componente`, `costo_attuale_componente`, `costo_vecchio_componente`, `fcc_componente`, `valore_param_componente`, `volume_componente`, `energia_componente`, `fattore_legame_componente`, `curativo_primario_componente`, `tossico_primario_componente`, `psicotropo_primario_componente`, `curativo_secondario_componente`, `tossico_secondario_componente`, `psicotropo_secondario_componente`, `possibilita_dipendeza_componente`, `effetto_sicuro_componente`, `descrizione_componente`, `tipo_applicativo_componente`, `visibile_ravshop_componente`) VALUES
('SS013', 'DX - 13', 'chimico', 'sostanza', 80, 68, NULL, NULL, NULL, NULL, NULL, '11', '10', '5', '0,5', '0,9', '0,2', '0', NULL, 'molecola curativa ', NULL, '1'),
('SS014', 'DX - 14', 'chimico', 'sostanza', 60, 57, NULL, NULL, NULL, NULL, NULL, '7', '10', '4', '0,5', '0,5', '0,5', '2', NULL, 'molecola curativa ', NULL, '1'),
('SS015', 'DX - 15', 'chimico', 'sostanza', 30, 27, NULL, NULL, NULL, NULL, NULL, '4', '8', '5', '0,5', '1', '0,1', '3', NULL, 'molecola curativa ', NULL, '1'),
('SS016', 'DX - 16', 'chimico', 'sostanza', 80, 68, NULL, NULL, NULL, NULL, NULL, '7', '9', '1', '0,5', '1', '0,5', '1', NULL, 'molecola curativa ', NULL, '1'),
('SS017', 'DX - 17', 'chimico', 'sostanza', 80, 87, NULL, NULL, NULL, NULL, NULL, '11', '8', '4', '0,9', '0,2', '0,5', '3', NULL, 'molecola curativa ', NULL, '1'),
('SS018', 'DX - 18', 'chimico', 'sostanza', 20, 22, NULL, NULL, NULL, NULL, NULL, '1', '6', '6', '0,8', '1', '1', '0', NULL, 'molecola curativa ', NULL, '1'),
('SS019', 'DX - 19', 'chimico', 'sostanza', 20, 23, NULL, NULL, NULL, NULL, NULL, '5', '3', '2', '0,1', '0,1', '0,4', '3', NULL, 'molecola curativa ', NULL, '1'),
('SS020', 'DX - 20', 'chimico', 'sostanza', 20, 15, NULL, NULL, NULL, NULL, NULL, '4', '6', '2', '0,2', '0,4', '0,8', '0', NULL, 'molecola curativa ', NULL, '1'),
('SS021', 'AX5 - 01', 'chimico', 'sostanza', 70, 58, NULL, NULL, NULL, NULL, NULL, '1', '1', '6', '0,6', '0,2', '0,7', '2', NULL, 'molecola tossica ', NULL, '1'),
('SS022', 'AX5 - 02', 'chimico', 'sostanza', 100, 127, NULL, NULL, NULL, NULL, NULL, '4', '17', '2', '0,1', '0,4', '0,2', '1', NULL, 'molecola tossica', NULL, '1'),
('SS023', 'AX5 - 03', 'chimico', 'sostanza', 70, 74, NULL, NULL, NULL, NULL, NULL, '1', '2', '2', '0,2', '0,6', '0,5', '3', NULL, 'molecola tossica ', NULL, '1'),
('SS024', 'AX5 - 04', 'chimico', 'sostanza', 300, 384, NULL, NULL, NULL, NULL, NULL, '4', '15', '7', '0,8', '0,3', '0,2', '1', NULL, 'molecola tossica', NULL, '1'),
('SS025', 'AX5 - 05', 'chimico', 'sostanza', 100, 86, NULL, NULL, NULL, NULL, NULL, '2', '6', '1', '1', '0,1', '0,1', '3', NULL, 'molecola tossica ', NULL, '1'),
('SS026', 'AX5 - 06', 'chimico', 'sostanza', 300, 375, NULL, NULL, NULL, NULL, NULL, '2', '13', '5', '0,6', '0,7', '0,5', '1', NULL, 'molecola tossica', NULL, '1'),
('SS027', 'AX5 - 07', 'chimico', 'sostanza', 100, 73, NULL, NULL, NULL, NULL, NULL, '2', '20', '1', '0,2', '0,1', '0,2', '0', NULL, 'molecola tossica ', NULL, '1'),
('SS028', 'AX5 - 08', 'chimico', 'sostanza', 250, 252, NULL, NULL, NULL, NULL, NULL, '9', '17', '3', '0,2', '0,7', '0,4', '3', NULL, 'molecola tossica', NULL, '1'),
('SS029', 'AX5 - 09', 'chimico', 'sostanza', 150, 156, NULL, NULL, NULL, NULL, NULL, '6', '9', '2', '0,3', '0,5', '0,7', '0', NULL, 'molecola tossica ', NULL, '1'),
('SS030', 'AX5 - 10', 'chimico', 'sostanza', 300, 324, NULL, NULL, NULL, NULL, NULL, '1', '14', '4', '1', '0,7', '0,1', '1', NULL, 'molecola tossica', NULL, '1'),
('SS031', 'AX5 - 11', 'chimico', 'sostanza', 300, 222, NULL, NULL, NULL, NULL, NULL, '8', '16', '5', '0,6', '0,6', '0,2', '1', NULL, 'molecola tossica ', NULL, '1'),
('SS032', 'AX5 - 12', 'chimico', 'sostanza', 300, 387, NULL, NULL, NULL, NULL, NULL, '7', '12', '4', '0,8', '0,3', '0,5', '2', NULL, 'molecola tossica', NULL, '1'),
('SS033', 'AX5 - 13', 'chimico', 'sostanza', 600, 636, NULL, NULL, NULL, NULL, NULL, '1', '20', '3', '0,9', '0,2', '0,8', '3', NULL, 'molecola tossica ', NULL, '1'),
('SS034', 'AX5 - 14', 'chimico', 'sostanza', 300, 243, NULL, NULL, NULL, NULL, NULL, '7', '8', '5', '0,5', '1', '0,3', '2', NULL, 'molecola tossica', NULL, '1'),
('SS035', 'AX5 - 15', 'chimico', 'sostanza', 300, 315, NULL, NULL, NULL, NULL, NULL, '4', '12', '6', '0,5', '0,3', '0,6', '3', NULL, 'molecola tossica ', NULL, '1'),
('SS036', 'AX5 - 16', 'chimico', 'sostanza', 100, 74, NULL, NULL, NULL, NULL, NULL, '1', '5', '3', '0,9', '0,2', '0,7', '1', NULL, 'molecola tossica', NULL, '1'),
('SS037', 'AX5 - 17', 'chimico', 'sostanza', 100, 70, NULL, NULL, NULL, NULL, NULL, '6', '1', '4', '0,4', '0,1', '0,9', '1', NULL, 'molecola tossica ', NULL, '1'),
('SS038', 'AX5 - 18', 'chimico', 'sostanza', 500, 395, NULL, NULL, NULL, NULL, NULL, '2', '12', '2', '1', '0,9', '0,5', '0', NULL, 'molecola tossica', NULL, '1'),
('SS039', 'AX5 - 19', 'chimico', 'sostanza', 300, 285, NULL, NULL, NULL, NULL, NULL, '1', '17', '4', '0,1', '0,2', '0,9', '3', NULL, 'molecola tossica ', NULL, '1'),
('SS040', 'AX5 - 20', 'chimico', 'sostanza', 100, 75, NULL, NULL, NULL, NULL, NULL, '7', '2', '3', '1', '0,9', '0,4', '1', NULL, 'molecola tossica', NULL, '1'),
('SS041', 'FW - 01', 'chimico', 'sostanza', 1500, 1845, NULL, NULL, NULL, NULL, NULL, '9', '20', '3', '0,9', '0,9', '0,9', '1', NULL, 'molecola psicotropa', NULL, '1'),
('SS042', 'FW - 02', 'chimico', 'sostanza', 250, 265, NULL, NULL, NULL, NULL, NULL, '3', '11', '8', '0,1', '0,6', '0,8', '2', NULL, 'molecola psicotropa', NULL, '1'),
('SS043', 'FW - 03', 'chimico', 'sostanza', 700, 700, NULL, NULL, NULL, NULL, NULL, '4', '16', '4', '0,4', '0,8', '0,7', '1', NULL, 'molecola psicotropa', NULL, '1'),
('SS044', 'FW - 04', 'chimico', 'sostanza', 300, 378, NULL, NULL, NULL, NULL, NULL, '3', '15', '2', '0,5', '0,9', '0,1', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS045', 'FW - 05', 'chimico', 'sostanza', 300, 387, NULL, NULL, NULL, NULL, NULL, '3', '13', '9', '0,7', '0,4', '0,5', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS046', 'FW - 06', 'chimico', 'sostanza', 300, 330, NULL, NULL, NULL, NULL, NULL, '7', '12', '8', '0,6', '0,9', '0,3', '2', NULL, 'molecola psicotropa', NULL, '1'),
('SS047', 'FW - 07', 'chimico', 'sostanza', 300, 315, NULL, NULL, NULL, NULL, NULL, '4', '9', '6', '0,9', '0,7', '1', '2', NULL, 'molecola psicotropa', NULL, '1'),
('SS048', 'FW - 08', 'chimico', 'sostanza', 250, 212, NULL, NULL, NULL, NULL, NULL, '8', '7', '3', '0,7', '0,1', '0,8', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS049', 'FW - 09', 'chimico', 'sostanza', 200, 232, NULL, NULL, NULL, NULL, NULL, '3', '9', '8', '0,1', '0,1', '0,2', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS050', 'FW - 10', 'chimico', 'sostanza', 250, 305, NULL, NULL, NULL, NULL, NULL, '6', '14', '2', '0,6', '0,3', '0,3', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS051', 'FW - 11', 'chimico', 'sostanza', 250, 217, NULL, NULL, NULL, NULL, NULL, '3', '6', '2', '0,6', '0,8', '0,9', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS052', 'FW - 12', 'chimico', 'sostanza', 300, 231, NULL, NULL, NULL, NULL, NULL, '1', '15', '7', '0,4', '0,3', '0,9', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS053', 'FW - 13', 'chimico', 'sostanza', 800, 656, NULL, NULL, NULL, NULL, NULL, '3', '19', '10', '0,5', '1', '0,8', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS054', 'FW - 14', 'chimico', 'sostanza', 250, 232, NULL, NULL, NULL, NULL, NULL, '8', '7', '6', '0,7', '0,5', '0,7', '3', NULL, 'molecola psicotropa', NULL, '1'),
('SS055', 'FW - 15', 'chimico', 'sostanza', 250, 287, NULL, NULL, NULL, NULL, NULL, '4', '7', '1', '0,2', '0,5', '0,3', '2', NULL, 'molecola psicotropa', NULL, '1'),
('SS056', 'FW - 16', 'chimico', 'sostanza', 300, 351, NULL, NULL, NULL, NULL, NULL, '9', '12', '3', '0,5', '0,4', '0,5', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS057', 'FW - 17', 'chimico', 'sostanza', 600, 756, NULL, NULL, NULL, NULL, NULL, '8', '20', '1', '1', '0,2', '0,2', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS058', 'FW - 18', 'chimico', 'sostanza', 250, 257, NULL, NULL, NULL, NULL, NULL, '1', '3', '2', '0,2', '0,4', '1', '0', NULL, 'molecola psicotropa', NULL, '1'),
('SS059', 'FW - 19', 'chimico', 'sostanza', 900, 1026, NULL, NULL, NULL, NULL, NULL, '5', '19', '3', '1', '0,6', '0,4', '2', NULL, 'molecola psicotropa', NULL, '1'),
('SS060', 'FW - 20', 'chimico', 'sostanza', 350, 448, NULL, NULL, NULL, NULL, NULL, '8', '11', '5', '1', '0,5', '0,7', '3', NULL, 'molecola psicotropa', NULL, '1'),
('X=0', 'X=0', 'programmazione', 'parametro_x', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=1', 'X=1', 'programmazione', 'parametro_x', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=2', 'X=2', 'programmazione', 'parametro_x', NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=3', 'X=3', 'programmazione', 'parametro_x', NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=4', 'X=4', 'programmazione', 'parametro_x', NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=5', 'X=5', 'programmazione', 'parametro_x', NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=6', 'X=6', 'programmazione', 'parametro_x', NULL, NULL, NULL, 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=7', 'X=7', 'programmazione', 'parametro_x', NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=8', 'X=8', 'programmazione', 'parametro_x', NULL, NULL, NULL, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('X=9', 'X=9', 'programmazione', 'parametro_x', NULL, NULL, NULL, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=0', 'Y=0', 'programmazione', 'parametro_y', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=1', 'Y=1', 'programmazione', 'parametro_y', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=2', 'Y=2', 'programmazione', 'parametro_y', NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=3', 'Y=3', 'programmazione', 'parametro_y', NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=4', 'Y=4', 'programmazione', 'parametro_y', NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=5', 'Y=5', 'programmazione', 'parametro_y', NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=6', 'Y=6', 'programmazione', 'parametro_y', NULL, NULL, NULL, 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=7', 'Y=7', 'programmazione', 'parametro_y', NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=8', 'Y=8', 'programmazione', 'parametro_y', NULL, NULL, NULL, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Y=9', 'Y=9', 'programmazione', 'parametro_y', NULL, NULL, NULL, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=0', 'Z=0', 'programmazione', 'parametro_z', NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=1', 'Z=1', 'programmazione', 'parametro_z', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=2', 'Z=2', 'programmazione', 'parametro_z', NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=3', 'Z=3', 'programmazione', 'parametro_z', NULL, NULL, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=4', 'Z=4', 'programmazione', 'parametro_z', NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=5', 'Z=5', 'programmazione', 'parametro_z', NULL, NULL, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=6', 'Z=6', 'programmazione', 'parametro_z', NULL, NULL, NULL, 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=7', 'Z=7', 'programmazione', 'parametro_z', NULL, NULL, NULL, 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=8', 'Z=8', 'programmazione', 'parametro_z', NULL, NULL, NULL, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1'),
('Z=9', 'Z=9', 'programmazione', 'parametro_z', NULL, NULL, NULL, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1');

-- --------------------------------------------------------

--
-- Struttura della tabella `componenti_ricetta`
--

CREATE TABLE `componenti_ricetta` (
  `id_componenti_ricetta` int(11) NOT NULL,
  `componenti_crafting_id_componente` varchar(255) NOT NULL,
  `ricette_id_ricetta` int(11) NOT NULL,
  `ordine_crafting` int(11) DEFAULT '0',
  `ruolo_componente_ricetta` set('Principio Attivo','Sostanza Satellite','Base') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `crafting_chimico`
--

CREATE TABLE `crafting_chimico` (
  `id_crafting_chimico` int(2) NOT NULL,
  `min_chimico` int(255) NOT NULL DEFAULT '0',
  `max_chimico` int(255) NOT NULL DEFAULT '0',
  `curativo_crafting_chimico` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `tossico_crafting_chimico` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL,
  `psicotropo_crafting_chimico` varchar(100) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `crafting_chimico`
--

INSERT INTO `crafting_chimico` (`id_crafting_chimico`, `min_chimico`, `max_chimico`, `curativo_crafting_chimico`, `tossico_crafting_chimico`, `psicotropo_crafting_chimico`) VALUES
(1, 77, 80, NULL, NULL, NULL),
(2, 73, 76, 'NEUTRALIZZA MUTILAZIONE', 'COMA', 'SINCERITÀ 1 DOMANDA'),
(3, 69, 72, NULL, 'SINGOLO! DIRETTO!', 'COMANDO PRIMA FRASE IMPERATIVA'),
(4, 65, 68, 'GUARIGIONE 10', 'TRIPLO! DIRETTO!', 'PARALISI! TEMPO 30 SECONDI!'),
(5, 61, 64, 'GUARIGIONE 7', 'A ZERO', NULL),
(6, 57, 60, 'GUARIGIONE 5', 'A ZERO', 'DISARMO! TEMPO 30 SECONDI!'),
(7, 53, 56, 'GUARIGIONE 3', NULL, 'PAURA'),
(8, 49, 52, 'GUARIGIONE 1', 'QUADRUPLO! DIRETTO!', 'CONFUSIONE! TEMPO 30 SECONDI!'),
(9, 45, 48, 'NEUTRALIZZA VELENO', 'CRASH! DIRETTO!', 'SPINTA 0'),
(10, 41, 44, 'NEUTRALLIZZA SONNO', 'SINGOLO! DIRETTO!', 'DOLORE! TEMPO 30 SECONDI!'),
(11, 37, 40, 'NEUTRALLIZZA SHOK', 'QUADRUPLO! DIRETTO!', 'SHOCK! TEMPO 30 SECONDI!'),
(12, 33, 36, 'NEUTRALIZZA CONTINUO', 'CRASH! DIRETTO!', 'SINCERITÀ! 1 DOMANDA'),
(13, 29, 32, 'NEUTRALIZZA DOLORE', NULL, 'SHOCK'),
(14, 25, 28, 'NEUTRALLIZZA PARALISI', 'TRIPLO! DIRETTO!', NULL),
(15, 21, 24, 'RIMARGINAZIONE 5', 'TRIPLO! DIRETTO!', 'CONFUSIONE'),
(16, 17, 20, 'RIMARGINAZIONE 4', 'DOPPIO! DIRETTO', 'DOLORE'),
(17, 13, 16, 'RIMARGINAZIONE 3', 'DOPPIO! DIRETTO', 'SPINTA 0'),
(18, 9, 12, 'RIMARGINAZIONE 2', 'SINGOLO! DIRETTO!', 'DISARMO'),
(19, 5, 8, 'RIMARGINAZIONE 1', 'SINGOLO! DIRETTO!', 'PARALISI'),
(20, 1, 4, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `crafting_programmazione`
--

CREATE TABLE `crafting_programmazione` (
  `parametro_crafting` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `valore_parametro_crafting` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `effetto_valore_crafting` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `parametro_collegato_crafting` varchar(45) COLLATE utf8_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `crafting_programmazione`
--

INSERT INTO `crafting_programmazione` (`parametro_crafting`, `valore_parametro_crafting`, `effetto_valore_crafting`, `parametro_collegato_crafting`) VALUES
('X1', '0', 'ATTACCO', 'Y1'),
('X1', '1', 'ATTACCO', 'Y1'),
('X1', '2', 'DIFESA', 'Y1'),
('X1', '3', 'DIFESA', 'Y1'),
('X1', '4', 'ABILITA\'', 'Y2'),
('X1', '5', 'ABILITA\'', 'Y2'),
('X1', '6', 'ATTACCO', 'Y1'),
('X1', '7', 'DIFESA', 'Y1'),
('X1', '8', 'ABILITA\'', 'Y2'),
('X1', '9', 'ATTACCO', 'Y1'),
('Y1', '0', 'danno', 'Z1'),
('Y1', '1', 'status', 'Z2'),
('Y1', '2', 'danno', 'Z1'),
('Y1', '3', 'status', 'Z2'),
('Y1', '4', 'danno', 'Z1'),
('Y1', '5', 'status', 'Z2'),
('Y1', '6', 'danno', 'Z1'),
('Y1', '7', 'status', 'Z2'),
('Y1', '8', 'danno', 'Z1'),
('Y1', '9', 'status', 'Z2'),
('Y2', '0', '1 uso', 'Z3'),
('Y2', '1', '2 usi', 'Z3'),
('Y2', '2', '1 uso', 'Z3'),
('Y2', '3', '2 usi', 'Z3'),
('Y2', '4', '3 usi', 'Z3'),
('Y2', '5', '1 uso', 'Z3'),
('Y2', '6', '2 usi', 'Z3'),
('Y2', '7', '3 usi', 'Z3'),
('Y2', '8', '4 usi ', 'Z3'),
('Y2', '9', '1 uso', 'Z3'),
('Z1', '0', 'SINGOLO', NULL),
('Z1', '1', 'DOPPIO', NULL),
('Z1', '2', 'TRIPLO', NULL),
('Z1', '3', 'QUADRUPLO', NULL),
('Z1', '4', 'A ZERO', NULL),
('Z1', '5', 'DOPPIO', NULL),
('Z1', '6', 'TRIPLO', NULL),
('Z1', '7', 'QUADRUPLO', NULL),
('Z1', '8', 'DOPPIO', NULL),
('Z1', '9', 'TRIPLO', NULL),
('Z2', '0', 'DISARMO!', NULL),
('Z2', '1', 'CONFUSIONE!', NULL),
('Z2', '2', 'PARALISI!', NULL),
('Z2', '3', 'SPINTA 5 !', NULL),
('Z2', '4', 'SHOCK!', NULL),
('Z2', '5', 'DISARMO!', NULL),
('Z2', '6', 'CONFUSIONE!', NULL),
('Z2', '7', 'SPINTA 5 !', NULL),
('Z2', '8', 'SHOCK!', NULL),
('Z2', '9', 'PARALISI!', NULL),
('Z3', '0', 'COMANDO!', NULL),
('Z3', '1', 'SINCERITA\'!', NULL),
('Z3', '2', 'GUARIGIONE 5!', NULL),
('Z3', '3', 'RIPARARAZIONE 5!', NULL),
('Z3', '4', 'ATTENUAZIONE!', NULL),
('Z3', '5', 'COMANDO ! IGNORAMI', NULL),
('Z3', '6', 'VELENO!  GUARIGIONE 1! TEMPO 1 MINUTO', NULL),
('Z3', '7', 'RIFLESSO! ', NULL),
('Z3', '8', 'BONUS ! ATTENUAZIONE! RAGGIO 2 TEMPO 1 MINUTO', NULL),
('Z3', '9', 'NEUTRALIZZA ( associabile a qualsiasi effetto', NULL);

-- --------------------------------------------------------

--
-- Struttura della tabella `eventi`
--

CREATE TABLE `eventi` (
  `id_evento` int(255) NOT NULL,
  `titolo_evento` varchar(255) NOT NULL,
  `data_inizio_evento` date NOT NULL,
  `ora_inizio_evento` time NOT NULL,
  `data_fine_evento` date NOT NULL,
  `ora_fine_evento` time NOT NULL,
  `luogo_evento` varchar(255) NOT NULL,
  `costo_evento` decimal(7,2) NOT NULL,
  `costo_maggiorato_evento` decimal(7,2) NOT NULL,
  `pubblico_evento` tinyint(1) NOT NULL DEFAULT '0',
  `punti_assegnati_evento` tinyint(1) NOT NULL DEFAULT '0',
  `creatore_evento` varchar(255) DEFAULT NULL,
  `note_evento` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `giocatori`
--

CREATE TABLE `giocatori` (
  `email_giocatore` varchar(255) NOT NULL,
  `password_giocatore` varchar(255) NOT NULL,
  `nome_giocatore` varchar(255) NOT NULL,
  `cognome_giocatore` varchar(255) NOT NULL,
  `data_registrazione_giocatore` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `eliminato_giocatore` tinyint(1) NOT NULL DEFAULT '0',
  `ruoli_nome_ruolo` varchar(255) NOT NULL DEFAULT 'giocatore',
  `default_pg_giocatore` int(11) DEFAULT NULL,
  `note_giocatore` text,
  `note_staff_giocatore` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `giocatori`
--

INSERT INTO `giocatori` (`email_giocatore`, `password_giocatore`, `nome_giocatore`, `cognome_giocatore`, `data_registrazione_giocatore`, `eliminato_giocatore`, `ruoli_nome_ruolo`, `default_pg_giocatore`, `note_giocatore`, `note_staff_giocatore`) VALUES
('andrea.silvestri87@yahoo.it', '1e4e888ac66f8dd41e00c5a7ac36a32a9950d271', 'Giocatore', 'Test', '2021-11-04 22:07:11', 0, 'giocatore', NULL, '', NULL),
('miroku_87@yahoo.it', '1e4e888ac66f8dd41e00c5a7ac36a32a9950d271', 'Andrea', 'Admin', '2018-03-15 01:07:38', 0, 'admin', 2, NULL, ''),
('staffer@gmail.it', '1e4e888ac66f8dd41e00c5a7ac36a32a9950d271', 'Staffer', 'Test', '2021-11-04 22:13:21', 0, 'staff', NULL, '', '');

--
-- Trigger `giocatori`
--
DELIMITER $$
CREATE TRIGGER `giocatori_BEFORE_INSERT` BEFORE INSERT ON `giocatori` FOR EACH ROW BEGIN
	IF
		( SELECT COUNT(*) FROM giocatori WHERE email_giocatore = NEW.email_giocatore ) > 0
    THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Esiste gi&agrave; un giocatore con questa email. Per favore controllare.';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `grants`
--

CREATE TABLE `grants` (
  `nome_grant` varchar(255) CHARACTER SET utf8 NOT NULL,
  `descrizione_grant` varchar(255) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `grants`
--

INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES
('aggiungiAbilitaAlPG_altri', 'L\'utente può assegnare nuove abilità a personaggi non suoi.'),
('aggiungiAbilitaAlPG_proprio', 'L\'utente può assegnare nuove abilità a un proprio personaggio.'),
('aggiungiClassiAlPG_altri', 'L\'utente può assegnare nuove classi a personaggi non suoi.'),
('aggiungiClassiAlPG_proprio', 'L\'utente può assegnare nuove classi a un proprio personaggio.'),
('aggiungiOpzioniAbilita_altri', 'L\'utente può aggiungere opzioni alle abilità di altri.'),
('aggiungiOpzioniAbilita_proprio', 'L\'utente può aggiungere opzioni alle proprie abilità.'),
('approvaCartellino', 'L\'utente può approvare cartellini creati'),
('associaPermessi', 'L\'utente può associare il permesso di compiere un\'azione ad un dato ruolo.'),
('associazioneCartellinoEtichette', 'L\'utente può associare cartellini alle etichette'),
('associazioneCartellinoTrama', 'L\'utente può associare cartellini alle trame'),
('compraComponenti', 'L\'utente può comprare componenti dallo shop.'),
('compraOggetti', 'L\'utente può comprare gli oggetti craftati venudti nel ravshop'),
('creaCartellino', 'L\'utente può creare cartellini'),
('creaEvento', 'L\'utente può creare eventi di gioco.'),
('creaNotizia', 'L\'utente può creare nuove notizie'),
('creaPG', 'L\'utente può creare un nuovo personaggio.'),
('creaPNG', 'L\'utente può creare personaggi non giocanti'),
('creaRuolo', 'L\'utente può creare un nuovo ruolo.'),
('disiscriviPG_altri', 'L\'utente può disicrivere un personaggio non suo.'),
('disiscriviPG_proprio', 'L\'utente può disiscrivere un suo personaggio.'),
('eliminaCartellino', 'L\'utente può eliminare cartellini'),
('eliminaComponente', 'L\'utente può eliminare un componente dal database'),
('eliminaEvento', 'L\'utente può eliminare un evento precedentemente creato.'),
('eliminaGiocatore', 'L\'utente può eliminare altri giocatori.'),
('eliminaPG_altri', 'L\'utente può eliminare un personaggio di altri.'),
('eliminaPG_proprio', 'L\'utente può eliminare un proprio personaggio.'),
('eliminaRuolo', 'L\'utente può eliminare un ruolo già esistente.'),
('inserisciComponente', 'L\'utente può inserire nuovi componenti'),
('inserisciTransazione', 'L\'utente può compiere una transazione monetaria.'),
('inviaMessaggio', 'L\'utente può inviare messaggi.'),
('inviaMessaggioPiuDestinatari', 'L\'utente può inserire diversi destinatari all\'interno del campo del destinatario nell\'invio dei messaggi privati.'),
('iscriviPg_altri', 'L\'utente può iscrivere pg di altri a un evento live.'),
('iscriviPg_proprio', 'L\'utente può iscrivere il proprio pg a un evento live.'),
('loginPG_altri', 'L\'utente può loggarsi con il pg di altri utenti.'),
('loginPG_proprio', 'L\'utente può loggarsi con un proprio pg.'),
('login_durante_chiusura', 'L\'utente può entrare nell\'interfaccia nonostante sia ufficialmente chiusa al pubblico.'),
('modificaCartellino', 'L\'utente può modificare cartellini'),
('modificaComponente', 'L\'utente può modificare le caratteristiche dei componenti del crafting'),
('modificaEvento', 'L\'utente può modificare i dati di un evento già esistente.'),
('modificaIscrizionePG_ha_partecipato_iscrizione_altri', 'L\'utente può modificare lo stato di partecipazione di un altro utente per un evento passato.'),
('modificaIscrizionePG_ha_partecipato_iscrizione_proprio', 'L\'utente può modificare lo stato di partecipazione del suo utente per un evento passato.'),
('modificaIscrizionePG_note_iscrizione_altri', 'L\'utene può modificare le note dell\'\'iscrizione ad un evento di un pg di altri.'),
('modificaIscrizionePG_note_iscrizione_proprio', 'L\'utene può modificare le note dell\'\'iscrizione ad un evento di un suo pg.'),
('modificaIscrizionePG_pagato_iscrizione_altri', 'L\'utente può modificare lo stato di pagato di un pg altrui per l\'iscrizione a un evento.'),
('modificaIscrizionePG_pagato_iscrizione_proprio', 'L\'utente può modificare lo stato di pagato di un suo pg per l\'iscrizione a un evento.'),
('modificaNotizia', 'L\'utente può modificare notizie esistenti'),
('modificaPG_anno_nascita_personaggio_altri', 'L\'utente può modificare l\'anno di nascita di un pg altrui.'),
('modificaPG_anno_nascita_personaggio_proprio', 'L\'utente può modificare l\'anno di nascita di un proprio pg.'),
('modificaPG_background_personaggio_altri', 'L\'utente può modificare il background di un personaggio qualsiasi.'),
('modificaPG_background_personaggio_proprio', 'L\'utente può modificare il proprio background.'),
('modificaPG_contattabile_personaggio_altri', 'L\'utente può rendere un utente non suo contattabile o meno.'),
('modificaPG_contattabile_personaggio_proprio', 'L\'utente può rendere un utente suo contattabile o meno.'),
('modificaPG_credito_personaggio_altri', 'L\'utente può modificare il credito degli altri personaggi come succede durante una transazione bancaria.'),
('modificaPG_credito_personaggio_proprio', 'L\'utente può modificare il credito del proprio personaggio.'),
('modificaPG_motivazioni_olocausto_inserite_personaggio_altri', 'L\'utente può modificare il flag che indica se ha scritto le motivazioni per l\'olocausto degli innocenti degli altri pg.'),
('modificaPG_motivazioni_olocausto_inserite_personaggio_proprio', 'L\'utente può modificare il flag che indica se ha scritto le motivazioni per l\'olocausto degli innocenti del proprio pg.'),
('modificaPG_nome_personaggio_altri', 'L\'utente può modificare il nome degli altri personaggi.'),
('modificaPG_nome_personaggio_proprio', 'L\'utente può modificare il nome del proprio personaggio.'),
('modificaPG_note_cartellino_personaggio_altri', 'L\'utente può modificare le note da stampare sul cartellino dei pg di altri giocatori.'),
('modificaPG_note_cartellino_personaggio_proprio', 'L\'utente può modificare le note da stampare sul cartellino dei propri pg.'),
('modificaPG_note_master_personaggio_altri', 'L\'utente può inserire delle note master.'),
('modificaPG_note_master_personaggio_proprio', 'L\'utente può inserire delle note master ai propri pg'),
('modificaPG_pc_personaggio_altri', 'L\'utente può modificare i punti combattimento di altri PG.'),
('modificaPG_pc_personaggio_proprio', 'L\'utente può modificare i propri punti combattimento.'),
('modificaPG_px_personaggio_altri', 'L\'utente può modificare i punti esperienza di altri PG.'),
('modificaPG_px_personaggio_proprio', 'L\'utente può modificare i propri punti esperienza.'),
('modificaRicetta', 'L\'utente può modificare una ricetta creata.'),
('modificaUtente_cognome_giocatore_altri', 'L\'utente può modificare il cognome di un altro utente.'),
('modificaUtente_cognome_giocatore_proprio', 'L\'utente può modificare il proprio cognome.'),
('modificaUtente_default_pg_giocatore_altri', 'L\'utente può modificare il PG di default di un altro utente'),
('modificaUtente_default_pg_giocatore_proprio', 'L\'utente può modificare il proprio PG di default '),
('modificaUtente_email_giocatore_altri', 'L\'utente può modificare l\'email di un altro giocatore.'),
('modificaUtente_email_giocatore_proprio', 'L\'utente può modificare la propria email.'),
('modificaUtente_nome_giocatore_altri', 'L\'utente può modificare il nome di un altro utente.'),
('modificaUtente_nome_giocatore_proprio', 'L\'utente può modificare il proprio nome.'),
('modificaUtente_note_giocatore_altri', 'L\'utente può modificare le note di altri utenti.'),
('modificaUtente_note_giocatore_proprio', 'L\'utente può modificare le proprie note.'),
('modificaUtente_note_staff_giocatore_altri', 'L\'utente può modificare le note Staff di altri utenti.'),
('modificaUtente_note_staff_giocatore_proprio', 'L\'utente può modificare le proprie note Staff.'),
('modificaUtente_password_giocatore_altri', 'L\'utente può modificare la password di altri utenti.'),
('modificaUtente_password_giocatore_proprio', 'L\'utente può modificare la propria password.'),
('modificaUtente_ruoli_nome_ruolo_altri', 'L\'utente può modificare il ruolo di altri.'),
('modificaUtente_ruoli_nome_ruolo_proprio', 'L\'utente può modificare il proprio ruolo.'),
('mostraPersonaggi_altri', 'L\'utente potrà visualizzare i personaggi creati dagli altri utenti.'),
('mostraPersonaggi_proprio', 'L\'utente potrà visualizzare la pagina dei suoi personaggi.'),
('pubblicaEvento', 'L\'utente può rendere pubblico a tutti i giocatori un evento creato in precedenza.'),
('pubblicaNotizia', 'L\'utente può pubblicare una notizia già creata'),
('recuperaComponentiAvanzata', 'L\'utente può vedere tutti i dati riguardanti i componenti'),
('recuperaComponentiAvanzato', 'L\'utente può vedere tutti i campi della tabella dei componenti'),
('recuperaComponentiBase', 'L\'utente può vedere la lista dei componenti durante i crafting e nel mercato'),
('recuperaConversazione_altri', 'L\'utente può visualizzare il testo di un messaggio di altri.'),
('recuperaConversazione_proprio', 'L\'utente può visualizzare il testo di un proprio messaggio.'),
('recuperaEventi', 'L\'utente può leggere gli eventi inseriti a database.'),
('recuperaInfoBanca_altri', 'L\'utente può recuperare le informazioni sul credito di pg non suoi.'),
('recuperaInfoBanca_proprio', 'L\'utente può recuperare le informazioni sul credito dei propri pg.'),
('recuperaListaEventi', 'L\'utente può vedere tutti gli eventi inseriti nel database.'),
('recuperaListaGiocatori', 'L\'utente può visualizzare una lista di tutti i giocatori iscritti.'),
('recuperaListaIscrittiAvanzato', 'L\'utente può vedere le informazioni base e di pagamento dei pg iscritit all\'evento live.'),
('recuperaListaIscrittiBase', 'L\'utente può vedere le informaizoni base dei pg iscritti all\'evento live.'),
('recuperaListaPermessi', 'L\'utente può scaricare dal database la lista di permessi presenti.'),
('recuperaMessaggi', 'L\'utente può recuperare i propri messaggi e quelli del pg loggato.'),
('recuperaMessaggi_altri', 'L\'utente può visualizzare i messaggi degli altri giocatori.'),
('recuperaMessaggi_proprio', 'L\'utente può visualizzare i propri messaggi.'),
('recuperaModelli', 'L\'utente può listare i modelli per creare i cartellini'),
('recuperaMovimenti_altri', 'L\'utente può recuperare le informazioni sui movimenti dei pg di altri giocatori'),
('recuperaMovimenti_proprio', 'L\'utente può recuperare le informazioni sui movimenti dei propri pg.'),
('recuperaNoteCartellino_altri', 'L\'utente può leggere gli extra che verranno stampati sul cartellino di un PG non suo.'),
('recuperaNoteCartellino_proprio', 'L\'utente può guardare le note extra che verranno stampate sul cartellino di un proprio pg.'),
('recuperaNoteMaster_altri', 'L\'utente può visualizzare le note master degli altri giocatori.'),
('recuperaNoteMaster_proprio', 'L\'utente può visualizzare le proprie note master.'),
('recuperaNoteUtente_altri', 'L\'utente può leggere le note di altri utenti.'),
('recuperaNoteUtente_proprio', 'L\'utente può leggere le proprie note.'),
('recuperaNotizie', 'L\'utente può recuperare tutte le notizie create'),
('recuperaNotiziePubbliche', 'L\'utente può recuperare le notizie pubblicate'),
('recuperaOpzioniAbilita', 'L\'utente può recuperare dal db le opzioni extra di varie abilità.'),
('recuperaPermessiDeiRuoli', 'L\'utente può scaricare da database i permessi associati ad ogni ruolo.'),
('recuperaRicettePerRavshop', 'L\'utente può recuperare gli oggetti craftati venudti nel ravshop'),
('recuperaRicette_altri', 'L\'utente può recuperare le ricette create da chiunque.'),
('recuperaRicette_proprio', 'L\'utente può recuperare le ricette create da un suo personaggio.'),
('recuperaRuoli', 'L\'utente può recuperare una lista di tutti i ruoli esistenti.'),
('recuperaStatisticheAbilita', 'L\'utente può accedere alle statistiche sulle abilità'),
('recuperaStatisticheAbilitaPerProfessione', 'L\'utente può accedere alle statistiche sulle quantità di abilità conosciute dai pg'),
('recuperaStatisticheAcquistiRavShop', 'L\'utente può accedere alle statistiche sulla popolarità dei componenti del RavShop'),
('recuperaStatisticheArmiStampate', 'L\'utente può accedere alle statistiche sulle armi craftate dai PG'),
('recuperaStatisticheClassi', 'L\'utente può accedere alle statistiche sulle classi'),
('recuperaStatisticheCrediti', 'L\'utente può accedere alle statistiche sui crediti'),
('recuperaStatistichePG', 'L\'utente può accedere alle statistiche sui PG'),
('recuperaStatistichePunteggi', 'L\'utente può accedere alle statistiche sui punteggi dei PG'),
('recuperaStatisticheQtaRavShop', 'L\'utente può accedere alle statistiche sulle qta di acquisto '),
('recuperaStorico_altri', 'L\'utente può guardare tutte le azioni compiute sui personaggi degli altri.'),
('recuperaStorico_proprio', 'L\'utente può guardare tutte le azioni compiute sul personaggio selezionato.'),
('recuperaTagsUnici', 'L\'utente può recuperare tutti i tag precedentemente inseriti'),
('recuperaUtentiStaffer', 'L\'utente può ricevere dal DB la lista degli staffer'),
('rimuoviAbilitaPG_altri', 'L\'utente può eliminare una abilità di un personaggio non suo.'),
('rimuoviAbilitaPG_proprio', 'L\'utente può eliminare una abilità di un proprio personaggio.'),
('rimuoviClassePG_altri', 'L\'utente può eliminare la classe di un personaggio non suo.'),
('rimuoviClassePG_proprio', 'L\'utente può eliminare la classe di un proprio personaggio.'),
('rispondiPerPNG', 'L\'utente può rispondere a nome di ogni PNG a database invece che soltanto per i propri.'),
('ritiraEvento', 'L\'utente può ritrare un evento pubblicato.'),
('ritiraNotizia', 'L\'utente può ritirare un articolo pubblicato.'),
('stampaCartelliniPG', 'L\'utente può stampare i cartellini dei personaggi.'),
('stampaListaIscritti', 'L\'utente può stampare la lista degli iscritti a un evento con tutte le loro informazioni.'),
('visualizza_pagina_banca', 'L\'utente può accedere alla pagina delle transazioni bancarie.'),
('visualizza_pagina_crea_evento', 'L\'utente può accedere alla pagina che permette di creare un evento.'),
('visualizza_pagina_crea_pg', 'L\'utente può visualizzare la pagina per creare un personaggio.'),
('visualizza_pagina_eventi', 'L\'utente può entrare nella sezione per la gestione degli eventi.'),
('visualizza_pagina_gestione_cartellini', 'L\'utente può accedere alla pagina di gestione dei cartellini'),
('visualizza_pagina_gestione_componenti', 'L\'utente può visualizzare la pagina di gestione dei componenti'),
('visualizza_pagina_gestione_giocatori', 'L\'utente può entrare nella sezione per la modifica dei dati dei giocatori.'),
('visualizza_pagina_gestione_oggetti_ingioco', 'L\'utente può entrare nella sezione per la creazione, modifica e stampa degli oggetti in gioco.'),
('visualizza_pagina_gestione_permessi', 'L\'utente può entrare nella sezione per la creazione e modifica dei ruoli e dei permessi ad essi associati.'),
('visualizza_pagina_gestione_ricette', 'L\'utente può vedere la pagina di gestione delle ricette.'),
('visualizza_pagina_lista_pg', 'L\'utente può visualizzare la pagina con la lista dei personaggi.'),
('visualizza_pagina_main', 'L\'utente può visualizzare la pagina principale del sito con la lista dei pg creati.'),
('visualizza_pagina_mercato', 'L\'utente può vedere la pagina che permette l\'acaquisto dei componenti.'),
('visualizza_pagina_mercato_oggetti', 'L\'utente può accedere alla pagina del Ravshop Oggetti'),
('visualizza_pagina_messaggi', 'L\'utente può accedere alla sezione messaggi.'),
('visualizza_pagina_negozio_abilita', 'L\'utente può acquistare abilità'),
('visualizza_pagina_notizie', 'L\'utente può accedere alla pagina delle notizie'),
('visualizza_pagina_profilo', 'L\'utente può visualizzare la pagina del proprio profilo.'),
('visualizza_pagina_scheda_pg', 'L\'utente può visualizzare la pagina con i dettagli di un personaggio.'),
('visualizza_pagina_stampa', 'L\'utente può accedere alla pagina di stampa dei cartellini.'),
('visualizza_pagina_stampa_cartellini', 'L\'utente può visualizzare la pagina di stampa dei cartellini'),
('visualizza_pagina_stampa_ricetta', 'L\'utente può accedere alla pagina con i cartellini da stampare'),
('visualizza_pagina_stampa_tabella_iscritti', 'L\'utente può accedere alla pagina di stampa della tabella degli iscritti a un evento.'),
('visualizza_pagina_statistiche', 'L\'utente può accedere alla pagina delle statistiche di gioco');

-- --------------------------------------------------------

--
-- Struttura della tabella `iscrizione_personaggi`
--

CREATE TABLE `iscrizione_personaggi` (
  `eventi_id_evento` int(255) NOT NULL,
  `personaggi_id_personaggio` int(11) NOT NULL,
  `pagato_iscrizione` tinyint(1) NOT NULL,
  `tipo_pagamento_iscrizione` set('Location','Manuale','PayPal','PostePay','Bonifico') NOT NULL,
  `ha_partecipato_iscrizione` tinyint(1) NOT NULL DEFAULT '1',
  `note_iscrizione` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `messaggi_fuorigioco`
--

CREATE TABLE `messaggi_fuorigioco` (
  `id_messaggio` int(255) NOT NULL,
  `mittente_messaggio` varchar(255) NOT NULL,
  `destinatario_messaggio` varchar(255) NOT NULL,
  `oggetto_messaggio` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `testo_messaggio` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `letto_messaggio` tinyint(1) NOT NULL DEFAULT '0',
  `data_messaggio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `risposta_a_messaggio` int(255) DEFAULT NULL,
  `id_conversazione` int(255) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `messaggi_fuorigioco`
--

INSERT INTO `messaggi_fuorigioco` (`id_messaggio`, `mittente_messaggio`, `destinatario_messaggio`, `oggetto_messaggio`, `testo_messaggio`, `letto_messaggio`, `data_messaggio`, `risposta_a_messaggio`, `id_conversazione`) VALUES
(1, 'staffer@gmail.it', 'andrea.silvestri87@yahoo.it', 'importante', 'iscriviti!', 1, '2021-11-04 22:49:36', NULL, 1),
(2, 'andrea.silvestri87@yahoo.it', 'staffer@gmail.it', '%20Re%3A%20importante', 'anche%20no!', 0, '2021-11-04 22:50:04', 1, 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `messaggi_ingioco`
--

CREATE TABLE `messaggi_ingioco` (
  `id_messaggio` int(255) NOT NULL,
  `mittente_messaggio` int(255) NOT NULL,
  `destinatario_messaggio` int(255) NOT NULL,
  `oggetto_messaggio` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `testo_messaggio` text COLLATE utf8_unicode_ci NOT NULL,
  `letto_messaggio` tinyint(1) NOT NULL DEFAULT '0',
  `data_messaggio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `risposta_a_messaggio` int(255) DEFAULT NULL,
  `id_conversazione` int(255) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `messaggi_ingioco`
--

INSERT INTO `messaggi_ingioco` (`id_messaggio`, `mittente_messaggio`, `destinatario_messaggio`, `oggetto_messaggio`, `testo_messaggio`, `letto_messaggio`, `data_messaggio`, `risposta_a_messaggio`, `id_conversazione`) VALUES
(1, 4, 3, 'Bel%20test', 'Questo%20%C3%A8%20un%20testoneeeeeee!!!', 1, '2021-11-04 22:34:35', NULL, 1),
(2, 4, 3, '%20Re%3A%20Bel%20test', 'Ah%20no%20scusa%2C%20%C3%A8%20un%20testino!', 1, '2021-11-04 22:35:00', 1, 1),
(3, 3, 4, '%20Re%3A%20Bel%20test', 'Non%20preoccuparti!%20%0APosso%20capire%20la%20confusione%20%3D)', 0, '2021-11-04 22:35:51', 2, 1),
(5, 3, 4, '%20Re%3A%20Bel%20test', 'E%20comunque%20sei%20pirla!', 0, '2021-11-04 22:48:38', 3, 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `notifiche`
--

CREATE TABLE `notifiche` (
  `giocatori_email_giocatore` varchar(255) NOT NULL,
  `storico_azioni_id_azione` int(255) NOT NULL,
  `notifica_letta` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `notizie`
--

CREATE TABLE `notizie` (
  `id_notizia` int(11) NOT NULL,
  `tipo_notizia` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `titolo_notizia` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `autore_notizia` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data_ig_notizia` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '271',
  `data_pubblicazione_notizia` datetime DEFAULT NULL,
  `pubblica_notizia` datetime NOT NULL,
  `testo_notizia` text COLLATE utf8_unicode_ci NOT NULL,
  `data_creazione_notizia` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `creatore_notizia` varchar(255) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `notizie`
--

INSERT INTO `notizie` (`id_notizia`, `tipo_notizia`, `titolo_notizia`, `autore_notizia`, `data_ig_notizia`, `data_pubblicazione_notizia`, `pubblica_notizia`, `testo_notizia`, `data_creazione_notizia`, `creatore_notizia`) VALUES
(3, 'Informazioni Commerciali', 'Nuovo gioco in playtest', 'Microprose', '21/4', '2018-04-21 12:31:00', '0000-00-00 00:00:00', '<p>Questa sera verr&agrave; rilasciata per alcuni utenti selezionatissimi una prima demo del gioco Fantasy World</p>\n', '2018-04-21 12:31:49', 'miroku_87@yahoo.it'),
(4, 'Contatti nell\'Ago', 'Situazione CPA', 'AGO', '18/4', '2018-04-21 12:33:00', '0000-00-00 00:00:00', '<p>Rilevate incongruenze tra cadaveri in entrata e in uscita in CPA 124</p>\n\n<p>Possibile presenza di un assassino tra il personale medico della struttura</p>\n', '2018-04-21 12:34:10', 'miroku_87@yahoo.it'),
(5, 'Contatti tra gli Sbirri', 'Situazione CPA', ' - NP', '20/4', '2018-04-21 12:34:00', '0000-00-00 00:00:00', '<p>Escono meno corpi di quelli che entrano&nbsp;</p>\n', '2018-04-21 12:35:07', 'miroku_87@yahoo.it'),
(6, 'Contatti nella Malavita', 'Situazione farmaci CPA', '- informatore 25 bis', '20/4', '2018-04-21 12:36:00', '0000-00-00 00:00:00', '<p>Il conto dai resoconti contabili dei farmaci presenti in loco &egrave; inferiore a quanto registrato</p>\n', '2018-04-21 12:37:23', 'miroku_87@yahoo.it'),
(7, 'Contatti nella Famiglia', 'Orecchie aperte', '- un amico', '21/4', '2018-04-21 12:38:00', '0000-00-00 00:00:00', '<p>Questa sera passa un amico che ha bisogno di medicine per la mamma malata</p>\n', '2018-04-21 12:38:31', 'miroku_87@yahoo.it'),
(8, 'Informazioni Commerciali', 'Cobalt', 'Luis Melth', 'Secondo del Sesto', '2018-05-31 23:15:42', '0000-00-00 00:00:00', '<p>Nonostante non ci sia un motivo apparente che giustifichi il rialzo le azioni della Cobalt stanno aumentando notevolmente di valore.</p>\n', '2018-05-31 22:55:27', 'Rebootlivebg@gmail.com'),
(9, 'Contatti nell\'Ago', 'Segnalazione Soggetto', 'AGO', 'Trentesimo del Quinto', '2018-05-31 23:15:42', '0000-00-00 00:00:00', '<p>Si ritiene che un soggetto altamente pericoloso sia stato assegnato al centro di riabilitazione 118. Il soggetto non rientra nel profilo dei criminali normalmente assegnati in quanto condannato per omicidio plurimo. Prestare massima attenzione.</p>\n', '2018-05-31 22:58:22', 'Rebootlivebg@gmail.com'),
(10, 'Contatti tra gli Sbirri', 'Voci di corridoio', 'Jo\' lo smilzo', 'Primo del Sesto', '2018-05-31 23:15:42', '0000-00-00 00:00:00', '<p>Pare che tra le mura del centro sia finito uno che non doveva. Magari pu&ograve; essere grato se la cosa si viene a sapere.</p>\n', '2018-05-31 23:00:42', 'Rebootlivebg@gmail.com'),
(11, 'Contatti nella Malavita', 'VIP', 'Informatore 25 Bis', 'Secondo del Sesto', '2018-05-31 23:15:42', '0000-00-00 00:00:00', '<p>Pare che uno dei carcerati sia legato ad una famiglia importante.&nbsp;</p>\n', '2018-05-31 23:02:24', 'Rebootlivebg@gmail.com'),
(12, 'Contatti nella Famiglia', 'Attenzione', 'Un Amico', 'Primo del Sesto', '2018-05-31 23:15:42', '0000-00-00 00:00:00', '<p>Uno degli ospiti del centro &egrave; molto legato ad una delle grandi famiglie, inoltre nel luogo &egrave; presente anche la scorta&nbsp;personale di un Famigliare, evitate cazzate.</p>\n', '2018-05-31 23:04:35', 'Rebootlivebg@gmail.com'),
(13, 'Contatti tra gli Sbirri', 'Segnalazioni sospetti', 'Ago', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>Circolano voci tra gli sbirri che ci siano membri del Branco a struttura 8.</p>\n\n<p>L&#39;Ago &egrave; sempre alla loro ricerca, ma gli agenti potrebbero essere troppo impegnati dalla situazione per cercarli attivamente.</p>\n', '2018-10-18 23:58:33', 'francesco.pelaccia@gmail.com'),
(14, 'Voci di Strada', 'Voci di strada', 'La strada', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>Tra le forze nemiche ci sono alcuni elementi, probabilmente mutanti o qualche supersoldato traditore, troppo forti per essere affrontati normalmente.</p>\n', '2018-10-19 00:02:38', 'francesco.pelaccia@gmail.com'),
(15, 'Contatti nell\'Ago', 'Sospettati in circolazione', 'Ago', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>Alcuni informatori parlano di figure di rilievo del Branco che si stanno recando a Struttura 8, probabilmente tra i membre delle spedizioni SGC dalle altre Strutture.</p>\n', '2018-10-19 00:13:09', 'francesco.pelaccia@gmail.com'),
(16, 'Contatti nella Malavita', 'Notizie Interessanti', 'Un amico', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>E&#39; possibile che alcune sedi corporative siano state attaccate e saccheggaite a Struttura 8, e che qualcuno sia interessato a mettere le mani su interessanti segreti corporativi.</p>\n', '2018-10-19 00:17:40', 'francesco.pelaccia@gmail.com'),
(17, 'Contatti nella Famiglia', 'Informazioni ed affari', 'Un amico', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>Gira voce che ci sia qualcuno particolarmente interessato a compare informazioni segrete relative alla Cobalt. Tieni gli occhi aperti, potrebbe essere un affare interessante.</p>\n', '2018-10-19 00:19:16', 'francesco.pelaccia@gmail.com'),
(18, 'Informazioni Commerciali', 'Nuova possibilità di investimenti', 'Un contatto nella finanza', 'Quindicesimo del Decimo', '2018-10-19 01:00:00', '0000-00-00 00:00:00', '<p>C&#39;&egrave; una nuova corporazione sul mercato del divertimento videoludico, la Realdreams; pare alcuni investitori si siano gi&agrave; fatti avanti con offerte e partecipazioni.</p>\n', '2018-10-19 00:22:43', 'francesco.pelaccia@gmail.com');

-- --------------------------------------------------------

--
-- Struttura della tabella `opzioni_abilita`
--

CREATE TABLE `opzioni_abilita` (
  `abilita_id_abilita` int(255) NOT NULL,
  `opzione` varchar(255) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `opzioni_abilita`
--

INSERT INTO `opzioni_abilita` (`abilita_id_abilita`, `opzione`) VALUES
(13, 'Contatto'),
(13, 'Droga'),
(17, 'Cronaca Nera'),
(17, 'Cronaca Rosa'),
(17, 'Economia'),
(17, 'Giornalismo Spazzatura'),
(17, 'Politica'),
(17, 'Sport'),
(18, 'Cronaca Nera'),
(18, 'Cronaca Rosa'),
(18, 'Economia'),
(18, 'Giornalismo Spazzatura'),
(18, 'Politica'),
(18, 'Sport'),
(19, 'Cronaca Nera'),
(19, 'Cronaca Rosa'),
(19, 'Economia'),
(19, 'Giornalismo Spazzatura'),
(19, 'Politica'),
(19, 'Sport'),
(20, 'Cronaca Nera'),
(20, 'Cronaca Rosa'),
(20, 'Economia'),
(20, 'Giornalismo Spazzatura'),
(20, 'Politica'),
(20, 'Sport'),
(89, 'Alcolismo'),
(89, 'Iniezione'),
(140, 'Armi da Mischia'),
(140, 'Fucile d\'Assalto'),
(140, 'Fucile di Precisione'),
(140, 'Pistola'),
(140, 'Shotgun');

-- --------------------------------------------------------

--
-- Struttura della tabella `personaggi`
--

CREATE TABLE `personaggi` (
  `id_personaggio` int(11) NOT NULL,
  `nome_personaggio` varchar(255) NOT NULL,
  `cognome_personaggio` varchar(255) DEFAULT NULL,
  `background_personaggio` longtext,
  `px_personaggio` int(11) NOT NULL DEFAULT '0',
  `pc_personaggio` int(11) NOT NULL DEFAULT '0',
  `credito_personaggio` bigint(255) NOT NULL DEFAULT '0',
  `anno_nascita_personaggio` int(11) NOT NULL DEFAULT '271',
  `data_creazione_personaggio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `contattabile_personaggio` tinyint(1) NOT NULL DEFAULT '1',
  `eliminato_personaggio` tinyint(1) NOT NULL DEFAULT '0',
  `giocatori_email_giocatore` varchar(255) NOT NULL,
  `motivazioni_olocausto_inserite_personaggio` tinyint(1) NOT NULL DEFAULT '0',
  `note_master_personaggio` text,
  `note_cartellino_personaggio` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `personaggi`
--

INSERT INTO `personaggi` (`id_personaggio`, `nome_personaggio`, `cognome_personaggio`, `background_personaggio`, `px_personaggio`, `pc_personaggio`, `credito_personaggio`, `anno_nascita_personaggio`, `data_creazione_personaggio`, `contattabile_personaggio`, `eliminato_personaggio`, `giocatori_email_giocatore`, `motivazioni_olocausto_inserite_personaggio`, `note_master_personaggio`, `note_cartellino_personaggio`) VALUES
(1, 'Banca di Struttura', NULL, NULL, 100, 4, 0, 0, '2018-10-19 23:17:15', 1, 0, 'miroku_87@yahoo.it', 0, NULL, NULL),
(2, 'Test Testerson', NULL, NULL, 1000100, 1000004, 0, 211, '2019-03-04 18:15:24', 1, 0, 'miroku_87@yahoo.it', 0, NULL, NULL),
(3, 'Png Testoso', NULL, NULL, 100, 4, 0, 259, '2021-11-04 22:16:05', 1, 0, 'staffer@gmail.it', 0, NULL, NULL),
(4, 'Troppo Figo', NULL, NULL, 100, 4, 0, 226, '2021-11-04 22:17:27', 1, 0, 'andrea.silvestri87@yahoo.it', 0, NULL, NULL);

--
-- Trigger `personaggi`
--
DELIMITER $$
CREATE TRIGGER `personaggi_BEFORE_UPDATE` BEFORE UPDATE ON `personaggi` FOR EACH ROW BEGIN
	IF NEW.pc_personaggio < 0 THEN
		SET NEW.pc_personaggio = 0;
	END IF;

	IF NEW.px_personaggio < 0 THEN
		SET NEW.px_personaggio = 0;
	END IF;

	IF NEW.credito_personaggio < 0 THEN
		SET NEW.credito_personaggio = 0;
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `personaggi_has_abilita`
--

CREATE TABLE `personaggi_has_abilita` (
  `personaggi_id_personaggio` int(255) NOT NULL,
  `abilita_id_abilita` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `personaggi_has_abilita`
--

INSERT INTO `personaggi_has_abilita` (`personaggi_id_personaggio`, `abilita_id_abilita`) VALUES
(2, 29),
(2, 30),
(2, 31),
(2, 44),
(2, 45),
(2, 48),
(2, 49),
(2, 50),
(2, 51),
(2, 52),
(2, 53),
(2, 64),
(2, 124),
(2, 125),
(3, 1),
(3, 2),
(3, 17),
(3, 92),
(3, 93),
(4, 44),
(4, 61),
(4, 62),
(4, 156),
(4, 157);

--
-- Trigger `personaggi_has_abilita`
--
DELIMITER $$
CREATE TRIGGER `personaggi_has_abilita_BEFORE_INSERT` BEFORE INSERT ON `personaggi_has_abilita` FOR EACH ROW BEGIN
	CALL controllaPrerequisitoAbilita( NEW.personaggi_id_personaggio, NEW.abilita_id_abilita );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `personaggi_has_abilita_BEFORE_UPDATE` BEFORE UPDATE ON `personaggi_has_abilita` FOR EACH ROW BEGIN
	CALL controllaPrerequisitoAbilita( NEW.personaggi_id_personaggio, NEW.abilita_id_abilita );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `personaggi_has_classi`
--

CREATE TABLE `personaggi_has_classi` (
  `personaggi_id_personaggio` int(255) NOT NULL,
  `classi_id_classe` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `personaggi_has_classi`
--

INSERT INTO `personaggi_has_classi` (`personaggi_id_personaggio`, `classi_id_classe`) VALUES
(2, 3),
(2, 4),
(2, 5),
(2, 10),
(2, 11),
(3, 1),
(3, 2),
(3, 8),
(3, 9),
(4, 4),
(4, 5),
(4, 12),
(4, 13);

--
-- Trigger `personaggi_has_classi`
--
DELIMITER $$
CREATE TRIGGER `personaggi_has_classi_BEFORE_INSERT` BEFORE INSERT ON `personaggi_has_classi` FOR EACH ROW BEGIN
	CALL controllaPrerequisitoClassi( NEW.personaggi_id_personaggio, NEW.classi_id_classe );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `personaggi_has_classi_BEFORE_UPDATE` BEFORE UPDATE ON `personaggi_has_classi` FOR EACH ROW BEGIN
	CALL controllaPrerequisitoClassi( NEW.personaggi_id_personaggio, NEW.classi_id_classe );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `personaggi_has_opzioni_abilita`
--

CREATE TABLE `personaggi_has_opzioni_abilita` (
  `personaggi_id_personaggio` int(11) NOT NULL,
  `abilita_id_abilita` int(11) NOT NULL,
  `opzioni_abilita_opzione` varchar(255) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dump dei dati per la tabella `personaggi_has_opzioni_abilita`
--

INSERT INTO `personaggi_has_opzioni_abilita` (`personaggi_id_personaggio`, `abilita_id_abilita`, `opzioni_abilita_opzione`) VALUES
(3, 17, 'Cronaca Rosa');

-- --------------------------------------------------------

--
-- Struttura della tabella `ricette`
--

CREATE TABLE `ricette` (
  `id_ricetta` int(11) NOT NULL,
  `personaggi_id_personaggio` int(11) NOT NULL,
  `data_inserimento_ricetta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_ricetta` set('Programmazione','Tecnico','Chimico') NOT NULL,
  `tipo_oggetto` set('Programma','Sostanza','Arma Mischia','Pistola','Fucile Assalto','Mitragliatore','Shotgun','Fucile Precisione','Gadget Normale','Gadget Avanzato','Protesi Generica','Protesi Braccio','Protesi Gamba','Esoscheletro') NOT NULL,
  `nome_ricetta` varchar(255) NOT NULL,
  `approvata_ricetta` tinyint(1) NOT NULL DEFAULT '0',
  `gia_stampata` tinyint(1) NOT NULL DEFAULT '0',
  `risultato_ricetta` varchar(255) DEFAULT NULL,
  `id_unico_risultato_ricetta` int(11) DEFAULT NULL,
  `note_ricetta` text,
  `note_pg_ricetta` text,
  `extra_cartellino_ricetta` text,
  `in_ravshop_ricetta` tinyint(1) NOT NULL DEFAULT '0',
  `disponibilita_ravshop_ricetta` int(255) DEFAULT '1',
  `costo_attuale_ricetta` int(255) DEFAULT NULL,
  `costo_vecchio_ricetta` int(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `ruoli`
--

CREATE TABLE `ruoli` (
  `nome_ruolo` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `ruoli`
--

INSERT INTO `ruoli` (`nome_ruolo`) VALUES
('admin'),
('giocatore'),
('ospite'),
('staff');

--
-- Trigger `ruoli`
--
DELIMITER $$
CREATE TRIGGER `ruoli_BEFORE_DELETE` BEFORE DELETE ON `ruoli` FOR EACH ROW BEGIN
	IF OLD.nome_ruolo = 'admin' THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '@@@Non puoi eliminare il ruolo admin.@@@';
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `ruoli_has_grants`
--

CREATE TABLE `ruoli_has_grants` (
  `ruoli_nome_ruolo` varchar(255) NOT NULL,
  `grants_nome_grant` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `ruoli_has_grants`
--

INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES
('admin', 'aggiungiAbilitaAlPG_altri'),
('admin', 'aggiungiAbilitaAlPG_proprio'),
('admin', 'aggiungiClassiAlPG_altri'),
('admin', 'aggiungiClassiAlPG_proprio'),
('admin', 'aggiungiOpzioniAbilita_altri'),
('admin', 'aggiungiOpzioniAbilita_proprio'),
('admin', 'associaPermessi'),
('admin', 'associazioneCartellinoEtichette'),
('admin', 'associazioneCartellinoTrama'),
('admin', 'compraComponenti'),
('admin', 'compraOggetti'),
('admin', 'creaCartellino'),
('admin', 'creaEvento'),
('admin', 'creaNotizia'),
('admin', 'creaPG'),
('admin', 'creaPNG'),
('admin', 'creaRuolo'),
('admin', 'disiscriviPG_altri'),
('admin', 'disiscriviPG_proprio'),
('admin', 'eliminaCartellino'),
('admin', 'eliminaComponente'),
('admin', 'eliminaEvento'),
('admin', 'eliminaGiocatore'),
('admin', 'eliminaPG_altri'),
('admin', 'eliminaPG_proprio'),
('admin', 'eliminaRuolo'),
('admin', 'inserisciComponente'),
('admin', 'inserisciTransazione'),
('admin', 'inviaMessaggio'),
('admin', 'inviaMessaggioPiuDestinatari'),
('admin', 'iscriviPg_altri'),
('admin', 'iscriviPg_proprio'),
('admin', 'loginPG_altri'),
('admin', 'loginPG_proprio'),
('admin', 'login_durante_chiusura'),
('admin', 'modificaCartellino'),
('admin', 'modificaComponente'),
('admin', 'modificaEvento'),
('admin', 'modificaIscrizionePG_ha_partecipato_iscrizione_altri'),
('admin', 'modificaIscrizionePG_ha_partecipato_iscrizione_proprio'),
('admin', 'modificaIscrizionePG_note_iscrizione_altri'),
('admin', 'modificaIscrizionePG_note_iscrizione_proprio'),
('admin', 'modificaIscrizionePG_pagato_iscrizione_altri'),
('admin', 'modificaIscrizionePG_pagato_iscrizione_proprio'),
('admin', 'modificaNotizia'),
('admin', 'modificaPG_anno_nascita_personaggio_altri'),
('admin', 'modificaPG_anno_nascita_personaggio_proprio'),
('admin', 'modificaPG_background_personaggio_altri'),
('admin', 'modificaPG_background_personaggio_proprio'),
('admin', 'modificaPG_contattabile_personaggio_altri'),
('admin', 'modificaPG_contattabile_personaggio_proprio'),
('admin', 'modificaPG_credito_personaggio_altri'),
('admin', 'modificaPG_credito_personaggio_proprio'),
('admin', 'modificaPG_motivazioni_olocausto_inserite_personaggio_altri'),
('admin', 'modificaPG_motivazioni_olocausto_inserite_personaggio_proprio'),
('admin', 'modificaPG_nome_personaggio_altri'),
('admin', 'modificaPG_nome_personaggio_proprio'),
('admin', 'modificaPG_note_cartellino_personaggio_altri'),
('admin', 'modificaPG_note_cartellino_personaggio_proprio'),
('admin', 'modificaPG_note_master_personaggio_altri'),
('admin', 'modificaPG_note_master_personaggio_proprio'),
('admin', 'modificaPG_pc_personaggio_altri'),
('admin', 'modificaPG_pc_personaggio_proprio'),
('admin', 'modificaPG_px_personaggio_altri'),
('admin', 'modificaPG_px_personaggio_proprio'),
('admin', 'modificaRicetta'),
('admin', 'modificaUtente_cognome_giocatore_altri'),
('admin', 'modificaUtente_cognome_giocatore_proprio'),
('admin', 'modificaUtente_default_pg_giocatore_altri'),
('admin', 'modificaUtente_default_pg_giocatore_proprio'),
('admin', 'modificaUtente_email_giocatore_altri'),
('admin', 'modificaUtente_email_giocatore_proprio'),
('admin', 'modificaUtente_nome_giocatore_altri'),
('admin', 'modificaUtente_nome_giocatore_proprio'),
('admin', 'modificaUtente_note_giocatore_altri'),
('admin', 'modificaUtente_note_giocatore_proprio'),
('admin', 'modificaUtente_note_staff_giocatore_altri'),
('admin', 'modificaUtente_note_staff_giocatore_proprio'),
('admin', 'modificaUtente_password_giocatore_altri'),
('admin', 'modificaUtente_password_giocatore_proprio'),
('admin', 'modificaUtente_ruoli_nome_ruolo_altri'),
('admin', 'modificaUtente_ruoli_nome_ruolo_proprio'),
('admin', 'mostraPersonaggi_altri'),
('admin', 'mostraPersonaggi_proprio'),
('admin', 'pubblicaEvento'),
('admin', 'pubblicaNotizia'),
('admin', 'recuperaComponentiAvanzata'),
('admin', 'recuperaComponentiAvanzato'),
('admin', 'recuperaComponentiBase'),
('admin', 'recuperaConversazione_altri'),
('admin', 'recuperaConversazione_proprio'),
('admin', 'recuperaEventi'),
('admin', 'recuperaInfoBanca_altri'),
('admin', 'recuperaInfoBanca_proprio'),
('admin', 'recuperaListaEventi'),
('admin', 'recuperaListaGiocatori'),
('admin', 'recuperaListaIscrittiAvanzato'),
('admin', 'recuperaListaIscrittiBase'),
('admin', 'recuperaListaPermessi'),
('admin', 'recuperaMessaggi'),
('admin', 'recuperaMessaggi_altri'),
('admin', 'recuperaMessaggi_proprio'),
('admin', 'recuperaModelli'),
('admin', 'recuperaMovimenti_altri'),
('admin', 'recuperaMovimenti_proprio'),
('admin', 'recuperaNoteCartellino_altri'),
('admin', 'recuperaNoteCartellino_proprio'),
('admin', 'recuperaNoteMaster_altri'),
('admin', 'recuperaNoteMaster_proprio'),
('admin', 'recuperaNoteUtente_altri'),
('admin', 'recuperaNoteUtente_proprio'),
('admin', 'recuperaNotizie'),
('admin', 'recuperaNotiziePubbliche'),
('admin', 'recuperaOpzioniAbilita'),
('admin', 'recuperaPermessiDeiRuoli'),
('admin', 'recuperaRicettePerRavshop'),
('admin', 'recuperaRicette_altri'),
('admin', 'recuperaRicette_proprio'),
('admin', 'recuperaRuoli'),
('admin', 'recuperaStatisticheAbilita'),
('admin', 'recuperaStatisticheAbilitaPerProfessione'),
('admin', 'recuperaStatisticheAcquistiRavShop'),
('admin', 'recuperaStatisticheArmiStampate'),
('admin', 'recuperaStatisticheClassi'),
('admin', 'recuperaStatisticheCrediti'),
('admin', 'recuperaStatistichePG'),
('admin', 'recuperaStatistichePunteggi'),
('admin', 'recuperaStatisticheQtaRavShop'),
('admin', 'recuperaStorico_altri'),
('admin', 'recuperaStorico_proprio'),
('admin', 'recuperaTagsUnici'),
('admin', 'recuperaUtentiStaffer'),
('admin', 'rimuoviAbilitaPG_altri'),
('admin', 'rimuoviAbilitaPG_proprio'),
('admin', 'rimuoviClassePG_altri'),
('admin', 'rimuoviClassePG_proprio'),
('admin', 'rispondiPerPNG'),
('admin', 'ritiraEvento'),
('admin', 'ritiraNotizia'),
('admin', 'stampaCartelliniPG'),
('admin', 'stampaListaIscritti'),
('admin', 'visualizza_pagina_banca'),
('admin', 'visualizza_pagina_crea_evento'),
('admin', 'visualizza_pagina_crea_pg'),
('admin', 'visualizza_pagina_eventi'),
('admin', 'visualizza_pagina_gestione_cartellini'),
('admin', 'visualizza_pagina_gestione_componenti'),
('admin', 'visualizza_pagina_gestione_giocatori'),
('admin', 'visualizza_pagina_gestione_oggetti_ingioco'),
('admin', 'visualizza_pagina_gestione_permessi'),
('admin', 'visualizza_pagina_gestione_ricette'),
('admin', 'visualizza_pagina_lista_pg'),
('admin', 'visualizza_pagina_main'),
('admin', 'visualizza_pagina_mercato'),
('admin', 'visualizza_pagina_mercato_oggetti'),
('admin', 'visualizza_pagina_messaggi'),
('admin', 'visualizza_pagina_negozio_abilita'),
('admin', 'visualizza_pagina_notizie'),
('admin', 'visualizza_pagina_profilo'),
('admin', 'visualizza_pagina_scheda_pg'),
('admin', 'visualizza_pagina_stampa'),
('admin', 'visualizza_pagina_stampa_cartellini'),
('admin', 'visualizza_pagina_stampa_ricetta'),
('admin', 'visualizza_pagina_stampa_tabella_iscritti'),
('admin', 'visualizza_pagina_statistiche'),
('giocatore', 'aggiungiAbilitaAlPG_proprio'),
('giocatore', 'aggiungiClassiAlPG_proprio'),
('giocatore', 'aggiungiOpzioniAbilita_proprio'),
('giocatore', 'compraComponenti'),
('giocatore', 'compraOggetti'),
('giocatore', 'creaPG'),
('giocatore', 'eliminaPG_proprio'),
('giocatore', 'inserisciTransazione'),
('giocatore', 'inviaMessaggio'),
('giocatore', 'iscriviPg_proprio'),
('giocatore', 'loginPG_proprio'),
('giocatore', 'modificaPG_anno_nascita_personaggio_proprio'),
('giocatore', 'modificaPG_background_personaggio_proprio'),
('giocatore', 'modificaPG_motivazioni_olocausto_inserite_personaggio_proprio'),
('giocatore', 'modificaRicetta'),
('giocatore', 'modificaUtente_default_pg_giocatore_proprio'),
('giocatore', 'modificaUtente_note_giocatore_proprio'),
('giocatore', 'modificaUtente_password_giocatore_proprio'),
('giocatore', 'mostraPersonaggi_proprio'),
('giocatore', 'recuperaComponentiBase'),
('giocatore', 'recuperaConversazione_proprio'),
('giocatore', 'recuperaEventi'),
('giocatore', 'recuperaInfoBanca_proprio'),
('giocatore', 'recuperaMessaggi'),
('giocatore', 'recuperaMessaggi_proprio'),
('giocatore', 'recuperaMovimenti_proprio'),
('giocatore', 'recuperaNoteUtente_proprio'),
('giocatore', 'recuperaNotiziePubbliche'),
('giocatore', 'recuperaOpzioniAbilita'),
('giocatore', 'recuperaRicettePerRavshop'),
('giocatore', 'recuperaRicette_proprio'),
('giocatore', 'visualizza_pagina_banca'),
('giocatore', 'visualizza_pagina_crea_pg'),
('giocatore', 'visualizza_pagina_eventi'),
('giocatore', 'visualizza_pagina_main'),
('giocatore', 'visualizza_pagina_mercato_oggetti'),
('giocatore', 'visualizza_pagina_messaggi'),
('giocatore', 'visualizza_pagina_negozio_abilita'),
('giocatore', 'visualizza_pagina_profilo'),
('giocatore', 'visualizza_pagina_scheda_pg'),
('giocatore', 'visualizza_pagina_stampa_ricetta'),
('staff', 'aggiungiAbilitaAlPG_altri'),
('staff', 'aggiungiAbilitaAlPG_proprio'),
('staff', 'aggiungiClassiAlPG_altri'),
('staff', 'aggiungiClassiAlPG_proprio'),
('staff', 'aggiungiOpzioniAbilita_altri'),
('staff', 'aggiungiOpzioniAbilita_proprio'),
('staff', 'associazioneCartellinoEtichette'),
('staff', 'associazioneCartellinoTrama'),
('staff', 'compraComponenti'),
('staff', 'compraOggetti'),
('staff', 'creaCartellino'),
('staff', 'creaNotizia'),
('staff', 'creaPG'),
('staff', 'creaPNG'),
('staff', 'disiscriviPG_altri'),
('staff', 'disiscriviPG_proprio'),
('staff', 'eliminaCartellino'),
('staff', 'eliminaPG_altri'),
('staff', 'eliminaPG_proprio'),
('staff', 'inserisciComponente'),
('staff', 'inserisciTransazione'),
('staff', 'inviaMessaggio'),
('staff', 'inviaMessaggioPiuDestinatari'),
('staff', 'iscriviPg_altri'),
('staff', 'iscriviPg_proprio'),
('staff', 'loginPG_altri'),
('staff', 'loginPG_proprio'),
('staff', 'modificaCartellino'),
('staff', 'modificaIscrizionePG_ha_partecipato_iscrizione_altri'),
('staff', 'modificaIscrizionePG_ha_partecipato_iscrizione_proprio'),
('staff', 'modificaIscrizionePG_note_iscrizione_altri'),
('staff', 'modificaIscrizionePG_note_iscrizione_proprio'),
('staff', 'modificaIscrizionePG_pagato_iscrizione_altri'),
('staff', 'modificaIscrizionePG_pagato_iscrizione_proprio'),
('staff', 'modificaNotizia'),
('staff', 'modificaPG_anno_nascita_personaggio_altri'),
('staff', 'modificaPG_anno_nascita_personaggio_proprio'),
('staff', 'modificaPG_background_personaggio_altri'),
('staff', 'modificaPG_background_personaggio_proprio'),
('staff', 'modificaPG_contattabile_personaggio_altri'),
('staff', 'modificaPG_contattabile_personaggio_proprio'),
('staff', 'modificaPG_credito_personaggio_altri'),
('staff', 'modificaPG_credito_personaggio_proprio'),
('staff', 'modificaPG_motivazioni_olocausto_inserite_personaggio_altri'),
('staff', 'modificaPG_motivazioni_olocausto_inserite_personaggio_proprio'),
('staff', 'modificaPG_nome_personaggio_altri'),
('staff', 'modificaPG_nome_personaggio_proprio'),
('staff', 'modificaPG_note_cartellino_personaggio_altri'),
('staff', 'modificaPG_note_cartellino_personaggio_proprio'),
('staff', 'modificaPG_note_master_personaggio_altri'),
('staff', 'modificaPG_note_master_personaggio_proprio'),
('staff', 'modificaPG_pc_personaggio_altri'),
('staff', 'modificaPG_pc_personaggio_proprio'),
('staff', 'modificaPG_px_personaggio_altri'),
('staff', 'modificaPG_px_personaggio_proprio'),
('staff', 'modificaRicetta'),
('staff', 'modificaUtente_default_pg_giocatore_altri'),
('staff', 'modificaUtente_default_pg_giocatore_proprio'),
('staff', 'modificaUtente_note_giocatore_altri'),
('staff', 'modificaUtente_note_giocatore_proprio'),
('staff', 'modificaUtente_note_staff_giocatore_altri'),
('staff', 'modificaUtente_note_staff_giocatore_proprio'),
('staff', 'modificaUtente_password_giocatore_altri'),
('staff', 'modificaUtente_password_giocatore_proprio'),
('staff', 'mostraPersonaggi_altri'),
('staff', 'mostraPersonaggi_proprio'),
('staff', 'pubblicaNotizia'),
('staff', 'recuperaComponentiAvanzata'),
('staff', 'recuperaComponentiAvanzato'),
('staff', 'recuperaComponentiBase'),
('staff', 'recuperaConversazione_altri'),
('staff', 'recuperaConversazione_proprio'),
('staff', 'recuperaEventi'),
('staff', 'recuperaInfoBanca_altri'),
('staff', 'recuperaInfoBanca_proprio'),
('staff', 'recuperaListaEventi'),
('staff', 'recuperaListaGiocatori'),
('staff', 'recuperaListaIscrittiAvanzato'),
('staff', 'recuperaListaIscrittiBase'),
('staff', 'recuperaMessaggi'),
('staff', 'recuperaMessaggi_altri'),
('staff', 'recuperaMessaggi_proprio'),
('staff', 'recuperaModelli'),
('staff', 'recuperaMovimenti_altri'),
('staff', 'recuperaMovimenti_proprio'),
('staff', 'recuperaNoteCartellino_altri'),
('staff', 'recuperaNoteCartellino_proprio'),
('staff', 'recuperaNoteMaster_altri'),
('staff', 'recuperaNoteMaster_proprio'),
('staff', 'recuperaNoteUtente_altri'),
('staff', 'recuperaNoteUtente_proprio'),
('staff', 'recuperaNotizie'),
('staff', 'recuperaNotiziePubbliche'),
('staff', 'recuperaOpzioniAbilita'),
('staff', 'recuperaRicettePerRavshop'),
('staff', 'recuperaRicette_altri'),
('staff', 'recuperaRicette_proprio'),
('staff', 'recuperaRuoli'),
('staff', 'recuperaStatisticheAbilita'),
('staff', 'recuperaStatisticheAbilitaPerProfessione'),
('staff', 'recuperaStatisticheAcquistiRavShop'),
('staff', 'recuperaStatisticheArmiStampate'),
('staff', 'recuperaStatisticheClassi'),
('staff', 'recuperaStatisticheCrediti'),
('staff', 'recuperaStatistichePG'),
('staff', 'recuperaStatistichePunteggi'),
('staff', 'recuperaStatisticheQtaRavShop'),
('staff', 'recuperaStorico_altri'),
('staff', 'recuperaStorico_proprio'),
('staff', 'recuperaTagsUnici'),
('staff', 'recuperaUtentiStaffer'),
('staff', 'rimuoviAbilitaPG_altri'),
('staff', 'rimuoviAbilitaPG_proprio'),
('staff', 'rimuoviClassePG_altri'),
('staff', 'rimuoviClassePG_proprio'),
('staff', 'rispondiPerPNG'),
('staff', 'ritiraNotizia'),
('staff', 'stampaCartelliniPG'),
('staff', 'stampaListaIscritti'),
('staff', 'visualizza_pagina_banca'),
('staff', 'visualizza_pagina_crea_pg'),
('staff', 'visualizza_pagina_eventi'),
('staff', 'visualizza_pagina_gestione_cartellini'),
('staff', 'visualizza_pagina_gestione_componenti'),
('staff', 'visualizza_pagina_gestione_giocatori'),
('staff', 'visualizza_pagina_gestione_oggetti_ingioco'),
('staff', 'visualizza_pagina_gestione_ricette'),
('staff', 'visualizza_pagina_lista_pg'),
('staff', 'visualizza_pagina_main'),
('staff', 'visualizza_pagina_mercato'),
('staff', 'visualizza_pagina_mercato_oggetti'),
('staff', 'visualizza_pagina_messaggi'),
('staff', 'visualizza_pagina_negozio_abilita'),
('staff', 'visualizza_pagina_notizie'),
('staff', 'visualizza_pagina_profilo'),
('staff', 'visualizza_pagina_scheda_pg'),
('staff', 'visualizza_pagina_stampa'),
('staff', 'visualizza_pagina_stampa_cartellini'),
('staff', 'visualizza_pagina_stampa_ricetta'),
('staff', 'visualizza_pagina_stampa_tabella_iscritti'),
('staff', 'visualizza_pagina_statistiche');

-- --------------------------------------------------------

--
-- Struttura della tabella `storico_azioni`
--

CREATE TABLE `storico_azioni` (
  `id_azione` int(255) NOT NULL,
  `id_personaggio_azione` int(255) NOT NULL,
  `giocatori_email_giocatore` varchar(255) NOT NULL,
  `data_azione` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tipo_azione` set('UPDATE','DELETE','INSERT') NOT NULL,
  `tabella_azione` varchar(255) NOT NULL,
  `campo_azione` varchar(255) NOT NULL,
  `valore_vecchio_azione` text,
  `valore_nuovo_azione` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `storico_azioni`
--

INSERT INTO `storico_azioni` (`id_azione`, `id_personaggio_azione`, `giocatori_email_giocatore`, `data_azione`, `tipo_azione`, `tabella_azione`, `campo_azione`, `valore_vecchio_azione`, `valore_nuovo_azione`) VALUES
(4342, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'personaggi', 'nome', NULL, 'Test Testerson'),
(4343, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'personaggi', 'PX', NULL, '100'),
(4344, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'personaggi', 'PC', NULL, '4'),
(4345, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'personaggi', 'email', NULL, 'miroku_87@yahoo.it'),
(4346, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Netrunner'),
(4347, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Tecnico'),
(4348, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Biomedico'),
(4349, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Assaltatore Base'),
(4350, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Assaltatore Avanzata'),
(4351, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Programmare'),
(4352, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Batteria aumentata'),
(4353, 2, 'miroku_87@yahoo.it', '2019-03-04 18:15:24', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Tuta da combattimento MK2'),
(4354, 2, 'miroku_87@yahoo.it', '2019-03-04 18:16:28', 'UPDATE', 'personaggi', 'pc_personaggio', '4', '1000004'),
(4355, 2, 'miroku_87@yahoo.it', '2019-03-04 18:16:28', 'UPDATE', 'personaggi', 'px_personaggio', '100', '1000100'),
(4356, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Riparare'),
(4357, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Sintesi e analisi chimica'),
(4358, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Programmazione avanzata'),
(4359, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Programmazione totale'),
(4360, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Riparazione veloce'),
(4361, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione-Armi'),
(4362, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione-Protesi'),
(4363, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione-Gadget e Shield'),
(4364, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione-Esoscheletri e scudi'),
(4365, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione avanzata-Gadget'),
(4366, 2, 'miroku_87@yahoo.it', '2019-03-04 18:18:35', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Specializzazione avanzata-Esoscheletri'),
(4367, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'personaggi', 'nome', NULL, 'Png Testoso'),
(4368, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'personaggi', 'PX', NULL, '100'),
(4369, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'personaggi', 'PC', NULL, '4'),
(4370, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'personaggi', 'email', NULL, 'staffer@gmail.it'),
(4371, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Sportivo'),
(4372, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Giornalista'),
(4373, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Guardiano Base'),
(4374, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Guardiano Avanzata'),
(4375, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Glitch'),
(4376, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Lag'),
(4377, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Campo di specializzazione 1'),
(4378, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Istinto omicida'),
(4379, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Istinto di sopravvivenza'),
(4380, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'opzioni_abilita', 'abilita - opzione', NULL, 'Campo di specializzazione 1 - Cronaca Rosa'),
(4381, 3, 'staffer@gmail.it', '2021-11-04 22:16:05', 'INSERT', 'opzioni_abilita', 'abilita - opzione', NULL, 'Campo di specializzazione 1 - Cronaca Rosa'),
(4382, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'personaggi', 'nome', NULL, 'Troppo Figo'),
(4383, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'personaggi', 'PX', NULL, '100'),
(4384, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'personaggi', 'PC', NULL, '4'),
(4385, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'personaggi', 'email', NULL, 'andrea.silvestri87@yahoo.it'),
(4386, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Tecnico'),
(4387, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Biomedico'),
(4388, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Supporto Base'),
(4389, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'classi_personaggio', 'classe', NULL, 'Supporto Avanzata'),
(4390, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Riparare'),
(4391, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Prime cure'),
(4392, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Cure intensive'),
(4393, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Opportunista'),
(4394, 4, 'andrea.silvestri87@yahoo.it', '2021-11-04 22:17:27', 'INSERT', 'abilita_personaggio', 'abilita', NULL, 'Batteria ausiliare Medipack');

-- --------------------------------------------------------

--
-- Struttura della tabella `tipi_ricetta`
--

CREATE TABLE `tipi_ricetta` (
  `id_tipo_ricetta` int(255) NOT NULL,
  `tipo_ricetta` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struttura della tabella `transazioni_bit`
--

CREATE TABLE `transazioni_bit` (
  `id_transazione` int(11) NOT NULL,
  `data_transazione` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `debitore_transazione` int(11) NOT NULL,
  `creditore_transazione` int(11) DEFAULT NULL,
  `importo_transazione` float NOT NULL DEFAULT '0',
  `note_transazione` text COLLATE utf8_unicode_ci,
  `id_acquisto_componente` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `abilita`
--
ALTER TABLE `abilita`
  ADD PRIMARY KEY (`id_abilita`),
  ADD KEY `fk_abilita_classi_idx` (`classi_id_classe`);

--
-- Indici per le tabelle `cartellini`
--
ALTER TABLE `cartellini`
  ADD PRIMARY KEY (`id_cartellino`);

--
-- Indici per le tabelle `cartellino_has_etichette`
--
ALTER TABLE `cartellino_has_etichette`
  ADD PRIMARY KEY (`cartellini_id_cartellino`,`etichetta`);

--
-- Indici per le tabelle `classi`
--
ALTER TABLE `classi`
  ADD PRIMARY KEY (`id_classe`),
  ADD KEY `fk_classi_prerequisiti_idx` (`prerequisito_classe`);

--
-- Indici per le tabelle `componenti_acquistati`
--
ALTER TABLE `componenti_acquistati`
  ADD PRIMARY KEY (`id_acquisto`),
  ADD KEY `fk_acquirente_idx` (`cliente_acquisto`),
  ADD KEY `fk_id_comp_acq_idx` (`id_componente_acquisto`);

--
-- Indici per le tabelle `componenti_crafting`
--
ALTER TABLE `componenti_crafting`
  ADD PRIMARY KEY (`id_componente`);

--
-- Indici per le tabelle `componenti_ricetta`
--
ALTER TABLE `componenti_ricetta`
  ADD PRIMARY KEY (`id_componenti_ricetta`),
  ADD KEY `fk_ricetta_id_ricetta_idx` (`ricette_id_ricetta`),
  ADD KEY `fk_componenti_id_componente_idx` (`componenti_crafting_id_componente`);

--
-- Indici per le tabelle `crafting_chimico`
--
ALTER TABLE `crafting_chimico`
  ADD PRIMARY KEY (`id_crafting_chimico`);

--
-- Indici per le tabelle `crafting_programmazione`
--
ALTER TABLE `crafting_programmazione`
  ADD PRIMARY KEY (`parametro_crafting`,`valore_parametro_crafting`);

--
-- Indici per le tabelle `eventi`
--
ALTER TABLE `eventi`
  ADD PRIMARY KEY (`id_evento`),
  ADD KEY `fk_creatori_evento_idx` (`creatore_evento`);

--
-- Indici per le tabelle `giocatori`
--
ALTER TABLE `giocatori`
  ADD PRIMARY KEY (`email_giocatore`),
  ADD KEY `fk_ruolo_idx` (`ruoli_nome_ruolo`),
  ADD KEY `fk_default_pg_idx` (`default_pg_giocatore`);

--
-- Indici per le tabelle `grants`
--
ALTER TABLE `grants`
  ADD PRIMARY KEY (`nome_grant`);

--
-- Indici per le tabelle `iscrizione_personaggi`
--
ALTER TABLE `iscrizione_personaggi`
  ADD PRIMARY KEY (`eventi_id_evento`,`personaggi_id_personaggio`),
  ADD KEY `fk_eventi_has_personaggi_personaggi1_idx` (`personaggi_id_personaggio`),
  ADD KEY `fk_eventi_has_personaggi_eventi1_idx` (`eventi_id_evento`);

--
-- Indici per le tabelle `messaggi_fuorigioco`
--
ALTER TABLE `messaggi_fuorigioco`
  ADD PRIMARY KEY (`id_messaggio`),
  ADD KEY `fk_mittente_fg_idx` (`mittente_messaggio`),
  ADD KEY `fk_destinatario_fg_idx` (`destinatario_messaggio`);

--
-- Indici per le tabelle `messaggi_ingioco`
--
ALTER TABLE `messaggi_ingioco`
  ADD PRIMARY KEY (`id_messaggio`),
  ADD KEY `fk_mittente_idx` (`mittente_messaggio`),
  ADD KEY `fk_destinatario_idx` (`destinatario_messaggio`);

--
-- Indici per le tabelle `notifiche`
--
ALTER TABLE `notifiche`
  ADD KEY `fk_giocatori_has_storico_azioni_storico_azioni1_idx` (`storico_azioni_id_azione`),
  ADD KEY `fk_giocatori_has_storico_azioni_giocatori1_idx` (`giocatori_email_giocatore`);

--
-- Indici per le tabelle `notizie`
--
ALTER TABLE `notizie`
  ADD PRIMARY KEY (`id_notizia`);

--
-- Indici per le tabelle `opzioni_abilita`
--
ALTER TABLE `opzioni_abilita`
  ADD PRIMARY KEY (`abilita_id_abilita`,`opzione`);

--
-- Indici per le tabelle `personaggi`
--
ALTER TABLE `personaggi`
  ADD PRIMARY KEY (`id_personaggio`),
  ADD KEY `fk_giocatore_personaggio_idx` (`giocatori_email_giocatore`);

--
-- Indici per le tabelle `personaggi_has_abilita`
--
ALTER TABLE `personaggi_has_abilita`
  ADD PRIMARY KEY (`personaggi_id_personaggio`,`abilita_id_abilita`),
  ADD KEY `fk_abilita_idx` (`abilita_id_abilita`);

--
-- Indici per le tabelle `personaggi_has_classi`
--
ALTER TABLE `personaggi_has_classi`
  ADD PRIMARY KEY (`personaggi_id_personaggio`,`classi_id_classe`),
  ADD KEY `fk_classe_idx` (`classi_id_classe`);

--
-- Indici per le tabelle `personaggi_has_opzioni_abilita`
--
ALTER TABLE `personaggi_has_opzioni_abilita`
  ADD PRIMARY KEY (`personaggi_id_personaggio`,`abilita_id_abilita`,`opzioni_abilita_opzione`),
  ADD KEY `fk_phoa_id_abilita_idx` (`abilita_id_abilita`),
  ADD KEY `fk_phoa_opzione_idx` (`opzioni_abilita_opzione`);

--
-- Indici per le tabelle `ricette`
--
ALTER TABLE `ricette`
  ADD PRIMARY KEY (`id_ricetta`),
  ADD KEY `fk_ricette_personaggi1_idx` (`personaggi_id_personaggio`);

--
-- Indici per le tabelle `ruoli`
--
ALTER TABLE `ruoli`
  ADD PRIMARY KEY (`nome_ruolo`);

--
-- Indici per le tabelle `ruoli_has_grants`
--
ALTER TABLE `ruoli_has_grants`
  ADD PRIMARY KEY (`ruoli_nome_ruolo`,`grants_nome_grant`),
  ADD KEY `fk_ruoli_has_grants_ruoli1_idx` (`ruoli_nome_ruolo`),
  ADD KEY `fk_nome_grant_idx` (`grants_nome_grant`);

--
-- Indici per le tabelle `storico_azioni`
--
ALTER TABLE `storico_azioni`
  ADD PRIMARY KEY (`id_azione`),
  ADD KEY `fk_esecutore_idx` (`giocatori_email_giocatore`),
  ADD KEY `fk_bersaglio_idx` (`id_personaggio_azione`);

--
-- Indici per le tabelle `tipi_ricetta`
--
ALTER TABLE `tipi_ricetta`
  ADD PRIMARY KEY (`id_tipo_ricetta`);

--
-- Indici per le tabelle `transazioni_bit`
--
ALTER TABLE `transazioni_bit`
  ADD PRIMARY KEY (`id_transazione`),
  ADD KEY `fk_debitore_idx` (`debitore_transazione`),
  ADD KEY `fk_creditore_idx` (`creditore_transazione`),
  ADD KEY `fk_acq_comp` (`id_acquisto_componente`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `abilita`
--
ALTER TABLE `abilita`
  MODIFY `id_abilita` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=220;

--
-- AUTO_INCREMENT per la tabella `cartellini`
--
ALTER TABLE `cartellini`
  MODIFY `id_cartellino` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `classi`
--
ALTER TABLE `classi`
  MODIFY `id_classe` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT per la tabella `componenti_acquistati`
--
ALTER TABLE `componenti_acquistati`
  MODIFY `id_acquisto` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `componenti_ricetta`
--
ALTER TABLE `componenti_ricetta`
  MODIFY `id_componenti_ricetta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `eventi`
--
ALTER TABLE `eventi`
  MODIFY `id_evento` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `messaggi_fuorigioco`
--
ALTER TABLE `messaggi_fuorigioco`
  MODIFY `id_messaggio` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT per la tabella `messaggi_ingioco`
--
ALTER TABLE `messaggi_ingioco`
  MODIFY `id_messaggio` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT per la tabella `notizie`
--
ALTER TABLE `notizie`
  MODIFY `id_notizia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT per la tabella `personaggi`
--
ALTER TABLE `personaggi`
  MODIFY `id_personaggio` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT per la tabella `ricette`
--
ALTER TABLE `ricette`
  MODIFY `id_ricetta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `storico_azioni`
--
ALTER TABLE `storico_azioni`
  MODIFY `id_azione` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4395;

--
-- AUTO_INCREMENT per la tabella `tipi_ricetta`
--
ALTER TABLE `tipi_ricetta`
  MODIFY `id_tipo_ricetta` int(255) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `transazioni_bit`
--
ALTER TABLE `transazioni_bit`
  MODIFY `id_transazione` int(11) NOT NULL AUTO_INCREMENT;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `abilita`
--
ALTER TABLE `abilita`
  ADD CONSTRAINT `fk_abilita_classi` FOREIGN KEY (`classi_id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `cartellino_has_etichette`
--
ALTER TABLE `cartellino_has_etichette`
  ADD CONSTRAINT `fk_cartellino` FOREIGN KEY (`cartellini_id_cartellino`) REFERENCES `cartellini` (`id_cartellino`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `classi`
--
ALTER TABLE `classi`
  ADD CONSTRAINT `fk_classi_prerequisiti` FOREIGN KEY (`prerequisito_classe`) REFERENCES `classi` (`id_classe`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `componenti_acquistati`
--
ALTER TABLE `componenti_acquistati`
  ADD CONSTRAINT `fk_acquirente` FOREIGN KEY (`cliente_acquisto`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_id_comp_acq` FOREIGN KEY (`id_componente_acquisto`) REFERENCES `componenti_crafting` (`id_componente`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limiti per la tabella `componenti_ricetta`
--
ALTER TABLE `componenti_ricetta`
  ADD CONSTRAINT `fk_componenti_id_componente` FOREIGN KEY (`componenti_crafting_id_componente`) REFERENCES `componenti_crafting` (`id_componente`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ricetta_id_ricetta` FOREIGN KEY (`ricette_id_ricetta`) REFERENCES `ricette` (`id_ricetta`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `eventi`
--
ALTER TABLE `eventi`
  ADD CONSTRAINT `fk_creatori_evento` FOREIGN KEY (`creatore_evento`) REFERENCES `giocatori` (`email_giocatore`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limiti per la tabella `giocatori`
--
ALTER TABLE `giocatori`
  ADD CONSTRAINT `fk_default_pg` FOREIGN KEY (`default_pg_giocatore`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ruolo` FOREIGN KEY (`ruoli_nome_ruolo`) REFERENCES `ruoli` (`nome_ruolo`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Limiti per la tabella `iscrizione_personaggi`
--
ALTER TABLE `iscrizione_personaggi`
  ADD CONSTRAINT `fk_eventi_has_personaggi_eventi1` FOREIGN KEY (`eventi_id_evento`) REFERENCES `eventi` (`id_evento`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_eventi_has_personaggi_personaggi1` FOREIGN KEY (`personaggi_id_personaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `messaggi_fuorigioco`
--
ALTER TABLE `messaggi_fuorigioco`
  ADD CONSTRAINT `fk_destinatario_fg` FOREIGN KEY (`destinatario_messaggio`) REFERENCES `giocatori` (`email_giocatore`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mittente_fg` FOREIGN KEY (`mittente_messaggio`) REFERENCES `giocatori` (`email_giocatore`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `messaggi_ingioco`
--
ALTER TABLE `messaggi_ingioco`
  ADD CONSTRAINT `fk_destinatario_ig` FOREIGN KEY (`destinatario_messaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mittente_ig` FOREIGN KEY (`mittente_messaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `notifiche`
--
ALTER TABLE `notifiche`
  ADD CONSTRAINT `fk_giocatori_has_storico_azioni_storico_azioni1` FOREIGN KEY (`storico_azioni_id_azione`) REFERENCES `storico_azioni` (`id_azione`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `opzioni_abilita`
--
ALTER TABLE `opzioni_abilita`
  ADD CONSTRAINT `fk_id_abilita` FOREIGN KEY (`abilita_id_abilita`) REFERENCES `abilita` (`id_abilita`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `personaggi`
--
ALTER TABLE `personaggi`
  ADD CONSTRAINT `fk_giocatore_pg` FOREIGN KEY (`giocatori_email_giocatore`) REFERENCES `giocatori` (`email_giocatore`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `personaggi_has_abilita`
--
ALTER TABLE `personaggi_has_abilita`
  ADD CONSTRAINT `fk_abilita` FOREIGN KEY (`abilita_id_abilita`) REFERENCES `abilita` (`id_abilita`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_personaggio` FOREIGN KEY (`personaggi_id_personaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `personaggi_has_classi`
--
ALTER TABLE `personaggi_has_classi`
  ADD CONSTRAINT `fk_classe` FOREIGN KEY (`classi_id_classe`) REFERENCES `classi` (`id_classe`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_personaggi` FOREIGN KEY (`personaggi_id_personaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `ricette`
--
ALTER TABLE `ricette`
  ADD CONSTRAINT `fk_ricette_personaggi1` FOREIGN KEY (`personaggi_id_personaggio`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `ruoli_has_grants`
--
ALTER TABLE `ruoli_has_grants`
  ADD CONSTRAINT `fk_nome_grant` FOREIGN KEY (`grants_nome_grant`) REFERENCES `grants` (`nome_grant`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_nome_ruolo` FOREIGN KEY (`ruoli_nome_ruolo`) REFERENCES `ruoli` (`nome_ruolo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `storico_azioni`
--
ALTER TABLE `storico_azioni`
  ADD CONSTRAINT `fk_bersaglio` FOREIGN KEY (`id_personaggio_azione`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_esecutore` FOREIGN KEY (`giocatori_email_giocatore`) REFERENCES `giocatori` (`email_giocatore`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limiti per la tabella `transazioni_bit`
--
ALTER TABLE `transazioni_bit`
  ADD CONSTRAINT `fk_acq_comp` FOREIGN KEY (`id_acquisto_componente`) REFERENCES `componenti_acquistati` (`id_acquisto`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_creditore` FOREIGN KEY (`creditore_transazione`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_debitore` FOREIGN KEY (`debitore_transazione`) REFERENCES `personaggi` (`id_personaggio`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
