UPDATE `abilita` SET `descrizione_abilita`='Se il personaggio è sotto l\'effetto di CONFUSIONE! può comunque attaccare colpendo col danno base<br>dell\'arma usata ridotto di 1 seguendo la normale catena:<br>COMA! - A ZERO! - CRITICO! - CRASH! - QUADRUPLO! - TRIPLO! - DOPPIO! - SINGOLO!.' WHERE id_abilita=92;
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può aumentare di 2 i danni causati col Fucile d\'Assalto per il prossimo colpo sparato in<br>base alla seguente scala: SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!.' WHERE (`id_abilita` = '104');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio con le armi di classe Fucile di Precisione può aumentare di 1 il danno del prossimo colpo sparato. L\'abilità viene \"spesa\" anche se il colpo manca il bersaglio.<br><br>(NOTA: i potenziamenti seguono la normale scala di danno:<br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!)' WHERE (`id_abilita` = '130');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio deve scegliere una tipologia di arma tra quelle in cui è addestrato. <br>Può aumentare di 1 il danno fatto con l\'arma prescelta secondo la scala <br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!.<br>NOTA 1: non sono comprese nelle armi selezionabili le Granate.<br>NOTA 2: questo bonus è sommabile a qualunque altro bonus ai danni, eventualmente disponibile per il giocatore con l\'arma selezionata.' WHERE (`id_abilita` = '140');
UPDATE `abilita` SET `descrizione_abilita` = 'Se il personaggio impugna un\'Arma da mischia corta e una Pistola, può dichiarare CONFUSIONE! con l\'arma da mischia ed aumentare di 1 le chiamate di danno effettuate con la pistola sul bersaglio confuso.<br><br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!)' WHERE (`id_abilita` = '141');
UPDATE `abilita` SET `descrizione_abilita` = 'Quando il personaggio ha lo Shield ridotto a zero aumenta di 1 le chiamate fatte con le Armi da mischia.<br><br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!)' WHERE (`id_abilita` = '143');
UPDATE `abilita` SET `descrizione_abilita` = 'Dopo aver sparato un colpo con il fucile di precisione ad un bersaglio oltre i 10 metri, se il colpo è andato a vuoto, il personaggio potrà dichiarare a dito, su un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo la scala:<br><br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO! - COMA!' WHERE (`id_abilita` = '147');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio, se sta impugnando solo una pistola e niente nell\'altra mano, può aumentare di 1 il danno<br>secondo la scala SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO!.<br>(NOTA: il bonus è sommabile a qualunque altro bonus disponibile per il giocatore con le pistole.)' WHERE (`id_abilita` = '166');
UPDATE `abilita` SET `descrizione_abilita` = 'Dopo aver sparato un colpo con il lanciagranate, se il colpo manca il bersaglio il personaggio potrà<br>dichiarare a dito, su un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo<br>la scala:<br>SINGOLO! - DOPPIO! - TRIPLO! - QUADRUPLO! - CRASH! - CRITICO! - A ZERO! - COMA!' WHERE (`id_abilita` = '211');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio se sta usando un\'arma di classe Mitragliatore pesante, dopo aver sparato ininterrottamente sullo stesso bersaglio ostile per 10 secondi, aumenta il suo punteggio\nattuale di shield di 4, se ha almeno 1 punto shield.\n<br><br>(N.b. Non è possibile cambiare bersaglio, ma è possibile sospendere il conteggio per cambiare caricatore, riprendendo quindi a sparare sullo stesso bersaglio)', `offset_shield_abilita` = '4' WHERE (`id_abilita` = '115');
UPDATE `abilita` SET `descrizione_abilita` = 'Quando il personaggio arriva a 0 punti Shield può dichiarare su se stesso la chiamata BONUS! +8 PUNTI SHIELD.' WHERE (`id_abilita` = '116');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio dopo avere subito per almeno 10 secondi la chiamata DOLORE (senza quindi aver dichiarato IMMUNE o aver subito NEUTRALIZZA) può alzare di due la prossima chiamata di danno secondo la normale scala, fino ad A ZERO!<br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! – DOPPIO! – TRIPLO! – QUADRUPLO! – CRITICO! - CRASH! – A ZERO!)\r' WHERE (`id_abilita` = '122');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio, dopo essere entrato in status Morto può rialzarsi con 50 Punti Ferita alocazionali, ma il suo Shield e la sua Batteria subiscono la chiamata BLOCCO! CONTINUO! Questo stato dura 1 minuto, durante i quali subisce tutte le chiamate di danno fino a QUADRUPLO come 1 singolo danno, le altre chiamate come 5 danni eccetto CREPA! e DISINTEGRAZIONE! che subisce normalmente. Passato il minuto o esauriti i Punti Ferita subisce la chiamata ARTEFATTO CREPA! e non può più utilizzare questa abilità.' WHERE (`id_abilita` = '121');
UPDATE `abilita` SET `descrizione_abilita` = 'Il valore di BONUS! Conferito con l\'abilità MEDIPACK – PRIME CURE è aumentato permanentemente di 1.' WHERE (`id_abilita` = '164');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può dichiarare NEUTRALIZZA! BLOCCO! X su un qualunque oggetto o impianto cibernetico del personaggio che sta toccando. Il personaggio dovrà specificare (sostituendo X) quale oggetto sta rimettendo in funzione.<br>Tempo Hacking: 10 secondi.<br>N.B. il cooldown di questa abilità è di 60 secondi.<br>N.B. Se l\'oggetto bersaglio è sottoposto anche alla chiamata CONTINUO!, tornerà immediatamente in stato di BLOCCO! fino a quando sarà soggetto a detta chiamata.' WHERE (`id_abilita` = '168');
UPDATE `abilita` SET `descrizione_abilita` = 'Il Personaggio può dichiarare BONUS! SHIELD +X! (dove X è il punteggio di Shield del personaggio) RAGGIO 10!.<br>Tempo Hacking: 10 secondi.<br>Al termine, il personaggio subisce BLOCCO! CONTINUO! TEMPO 3 MINUTI! al proprio Controller.', `prerequisito_abilita` = '-17' WHERE (`id_abilita` = '171');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può spendere 6 Punti Shield (se li possiede) per terminare un Cooldown attivo.' WHERE (`id_abilita` = '180');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può sostituire, per i prossimi 5 colpi, il danno della sua arma con la chiamata GUARIGIONE 2 4! VELENO! GUARIGIONE 4!.<br>Subisce quindi BLOCCO! alla batteria per 5 minuti.<br>N.B. Il cooldown di questa abilità è di 60 secondi.', `prerequisito_abilita` = '-18' WHERE (`id_abilita` = '187');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può dichiarare ELETTRO 1! SINGOLO! Su un bersaglio. Dopo averlo effettuato può<br>decidere di rimandare il cool-down standard e, dopo altri 10 secondi, può ripetere la chiamata sullo<br>stesso bersaglio. Può ripetere la stessa dichiarazione, sempre sullo stesso bersaglio e sempre ad<br>intervalli di 10 secondi, un numero di volte illimitato. Quando decide di interrompere la catena parte il<br>cool-down standard dell\'abilità. L\'abilità si considera interrotta se il personaggio o il bersaglio sono in status di coma.<br>Tempo Hacking: 10 secondi.' WHERE (`id_abilita` = '200');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio mentre è in fase di cool-down può, toccando un bersaglio consenziente e non già sotto<br>BLOCCO!, dichiarare BLOCCO! Batteria! TEMPO 30 secondi! E abbreviare il suo cool-down attualmente<br>attivo di 30 secondi fino ad arrivare a minimo 0 secondi.' WHERE (`id_abilita` = '204');
UPDATE `abilita` SET `descrizione_abilita` = 'Dopo aver sparato un colpo con il lanciagranate, se il colpo manca il bersaglio il personaggio potrà<br>dichiarare a dito, su un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo<br>la scala:<br>COMA! – A ZERO! – CRASH! - CRITICO! - QUADRUPLO! - TRIPLO! - DOPPIO! – SINGOLO!.\r' WHERE (`id_abilita` = '211');
UPDATE `abilita` SET `descrizione_abilita` = 'Una volta per vita, se il personaggio entra in uno dei punti di Respawn viene teletrasportato a un altro.<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '1');
UPDATE `abilita` SET `descrizione_abilita` = 'Una volta per vita , il personaggio se si muove a scatti dichiara IMMUNE! al primo danno che subisce. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '2');
UPDATE `abilita` SET `descrizione_abilita` = 'Se il personaggio si muove saltellando dichiara IMMUNE! ai danni delle chiamate ad area e raggio. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '3');
UPDATE `abilita` SET `descrizione_abilita` = 'Se al primo avversario abbattuto il personaggio esulta in modo evidente al pubblico, guadagna automaticamente 1 punto in classifica nelle partite DEATHMATCH. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '4');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio ha tempo 15 secondi per girare la mappa prima di giocare la partita<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '5');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può giocare usando 2 pistole<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '6');
UPDATE `abilita` SET `descrizione_abilita` = 'Una volta per Vita il personaggio può fare la dichiarazione di danno a dito indicando la vittima<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '7');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può suicidarsi per non dare punti al nemico. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '8');
UPDATE `abilita` SET `descrizione_abilita` = 'Se il personaggio in un match \"cattura la bandiera\" è equipaggiato con la sua arma base e tiene la bandiera la può lanciare. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '9');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio può fingersi morto per 30 secondi consecutivi. <br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '10');
UPDATE `abilita` SET `descrizione_abilita` = 'Ogni volta che il personaggio sta fermo in un posto per sparare almeno per 3 secondi può dichiarare al primo colpo che spara + 1 alla chiamata secondo lo schema SINGOLO!, DOPPIO! TRIPLO, QUADRUPLO<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '11');
UPDATE `abilita` SET `descrizione_abilita` = 'Se il personaggio ha appena vinto ( o fa parte della squadra che ha  vinto) una partita  può richiedere allo sponsor un extra del 25% del suo ingaggio dichiarando SONO L\'IDOLO DELLA FOLLA.<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '12');
UPDATE `abilita` SET `descrizione_abilita` = 'Il personaggio sceglie tra una di queste due opzioni:<br>DROGA: il personaggio ha passato la sua vita a sniffare, risulta immune agli effetti negativi  fisici delle droghe da inalazione.<br>CONTATTO: il personaggio ha passato la sua vita a contatto con sostanze schifose, risulta immune agli effetti negativi delle droghe da contatto.<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '13');
UPDATE `abilita` SET `descrizione_abilita` = 'I numerosi successi sportivi e mondani del personaggio hanno attirato l\'attenzione di uno Stalker che lo seguirà dall\'ombra e potrà fornire qualche aiuto, ma anche delle complicazioni, al personaggio.<br><br>Utilizzabile solo durante una partita di Deathmatch', `distanza_abilita` = '' WHERE (`id_abilita` = '14');


UPDATE `abilita` SET `prerequisito_abilita` = '-9' WHERE (`id_abilita` = '107');
UPDATE `abilita` SET `prerequisito_abilita` = '-14' WHERE (`id_abilita` = '123');
UPDATE `abilita` SET `prerequisito_abilita` = '-15' WHERE (`id_abilita` = '139');
UPDATE `abilita` SET `prerequisito_abilita` = '-16' WHERE (`id_abilita` = '155');
UPDATE `abilita` SET `prerequisito_abilita` = '-19' WHERE (`id_abilita` = '203');
UPDATE `abilita` SET `prerequisito_abilita` = '-20' WHERE (`id_abilita` = '219');


INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Rally', 'Il personaggio può dichiarare NEUTRALIZZA! PAURA! RAGGIO 5!\r', '1', '8', '99', 'personale', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Ricalibrare', 'Il personaggio può dichiarare IMMUNE! alla chiamata CONFUSIONE!', '1', '8', '92', 'personale', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Regalo d\'Addio', 'Il personaggio può, quando subisce un colpo che lo manda in status di COMA!, dopo essere caduto a terra,\nsparare un colpo con la propria arma.\r', '1', '8', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Maestria Nello Scudo', 'Lo scudo impugnato dal personaggio può parare fino ad una chiamata in più sulla normale scala dei danni.', '1', '9', '118', 'personale', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Vendetta', 'Il personaggio può dichiarare RIFLESSO! X quando una chiamata distrugge il suo scudo.<br>\nNon è possibile utilizzare questa abilità se lo scudo viene colpito dalle chiamate COMA! CREPA! e DISINTEGRAZIONE!, o da chiamate precedute da ARTEFATTO!', '1', '9', '223', '10 metri', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Rainbow Six', 'Il personaggio, se imbraccia uno scudo grande, può alzare di 1 il danno delle pistole.<br>\n(NOTA: i potenziamenti seguono la seguente scala SINGOLO! – DOPPIO! – TRIPLO! – QUADRUPLO! – CRITICO! - CRASH! – A ZERO!)', '1', '9', '-10', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Buckshot', 'Il personaggio può, se impugna un fucile a pompa, dichiarare il danno della propria arma aggiungendo IN QUEST\'AREA 5! e delineando un\'area di 90°.<br>L\'arma subirà BLOCCO! CONTINUO! TEMPO 1 ORA!', '1', '10', '133', '5 metri', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Maestria nel Tiro Lungo', 'Il personaggio, quando utilizza l\'abilità “Tiro Lungo” (sparando da oltre 10 metri) del fucile di precisione,\naumenta il danno di 2 invece che di 1, secondo la normale scala.<br>(SINGOLO! – DOPPIO! – TRIPLO! – QUADRUPLO! – CRITICO! - CRASH! – A ZERO!) ', '1', '10', '-11', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Raffica da Tre', 'Il personaggio, quando impugna un fucile d\'assalto, può dichiarare la chiamata della sua arma a dito su fino a 3\nbersagli entro 10 metri.<br>(N.B. il tempo di Cooldown di questa abilità è 60 secondi e NON 30 secondi)', '1', '10', '10 metri', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Un Pizzico di Follia', 'Quando il personaggio ha lo Shield ridotto a zero aumenta di 1 le chiamate fatte con il fucile a pompa entro 1\nmetro.<br>(NOTA: i potenziamenti seguono la seguente scala SINGOLO! – DOPPIO! – TRIPLO! – QUADRUPLO! –\nCRITICO! - CRASH! – A ZERO!)', '1', '11', '144', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Colpo di Coda', 'Dopo aver scagliato un coltello da lancio, se il colpo manca il bersaglio il personaggio potrà dichiarare a dito,\nsu un bersaglio entro 1 metro da dove impatta il colpo, il danno scalato di uno secondo la scala:<br>COMA! – A ZERO! – CRASH! - CRITICO! - QUADRUPLO! - TRIPLO! - DOPPIO! – SINGOLO!.', '1', '11', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Posizione Sopraelevata', 'Il personaggio, quando utilizza l\'abilità “Tiro Lungo” (sparando da oltre 10 metri) del fucile di precisione,\naumenta il danno di un ulteriore 1, secondo la normale scala, se spara da una posizione sopraelevata rispetto al\nbersaglio: ad esempio, una finestra ad un piano superiore.<br>(SINGOLO! – DOPPIO! – TRIPLO! – QUADRUPLO! – CRITICO! - CRASH! – A ZERO!)', '1', '11', '227', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Emettitori Avanzati', 'Il valore di BONUS! X SHIELD! conferito con tutte le abilità conosciute dal personaggio è aumentato\npermanentemente di 1.\r', '1', '12', '169', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Abbondanza', 'Il personaggio può dichiarare BONUS! DIFESA MENTALE +1! +4 PUNTI FERITA! + 1 DANNO! + 4 PUNTI SHIELD! BLOCCO! CONTINUO! BATTERIA! TEMPO 10 MINUTI! su un bersaglio a lui non ostile.<br>Tempo Hacking: 30 secondi.<br>N.B. il cooldown di questa abilità è di 60 secondi.\n', '1', '12', '-12', 'tocco', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Qui per Voi', 'Il personaggio dichiara su se stesso CRASH! SHIELD!, quindi ottiene 10 “cariche” che può utilizzare con ogni abilità che possiede che gli consenta di dichiarare NEUTRALIZZA! ad un effetto; per ogni carica che utilizza può ignorare 30 secondi di cooldown causati da detta abilità.<br>N.B. il cooldown di questa abilità è di 90 secondi, e si attiva quando sono terminate le cariche', '1', '12', 'personale', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Droni Specchio', 'Il personaggio può, toccando un bersaglio, dichiarare BONUS! RIFLESSO! ALLA PRIMA CHIAMATA!.<br>Tempo Hacking: 10 secondi.', '1', '13', '172', 'tocco', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Ingordigia', 'Il personaggio può beneficiare di un ulteriore BONUS! solo se proveniente da se stesso.\r', '1', '13', '156', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Psicoanalisi', 'Il personaggio può dichiarare NEUTRALIZZA COMANDO! toccando il bersaglio.<br>N.B. Il cooldown di questa abilità è di 60 secondi.', '1', '13', '-13', 'tocco', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Rischia Tutto', 'Il personaggio può, dopo aver inflitto una chiamata ELETTRO! ad un bersaglio (che quindi non deve aver\ndichiarato IMMUNE!), aumentare di 2 (invece che di 1) il bonus ai danni conferito dall\'abilità “Tiro Ravvicinato”\ndel fucile a pompa con il primo colpo contro lo stesso bersaglio, entro 10 secondi.\r', '1', '14', '194', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Focus', 'Il personaggio può, se sta già utilizzando l\'abilità BRUTE FORCE, dichiarare immune alle chiamate SHOCK! PAURA! CONFUSIONE! DOLORE! e COMANDO! che subisce.<br>Quando terminerà di utilizzare l\'abilità BRUTE FORCE (perchè il bersaglio ha subito l\'effetto o perchè ha deciso di interromperla autonomamente) il personaggio subisce ARTEFATTO! CONFUSIONE! TEMPO 30 SECONDI!', '1', '14', '193', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Immagine Spaventosa', 'Il personaggio può dichiarare ELETTRO 1! PAURA! su fino a tre bersagli differenti.<br>Tempo Hacking: 10 secondi.<br>N.B. E\' possibile utilizzare BRUTE FORCE con questa abilità, ma non sarà possibile cambiare i bersagli\n', '1', '14', '10 metri', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Palombella', 'Il personaggio può, dopo aver sparato un colpo in aria con il lanciagrnate, dichiarare DOPPIO! A dito su fino a 3\nbersagli a sua scelta entro 10 metri\r', '1', '15', '212', '10 metri', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Rocket Jump', 'Il personaggio può, dopo aver sparato un colpo tra i propri piedi, alzare il dito uscendo in FUORIGIOCO! In seguito DEVE avanzare o arretrare di 10 metri in linea retta, il più in fretta possibile, per poi tornare IN GIOCO! subendo il danno della propria arma ad entrambe le gambe (o allo shield, se lo ha ancora).<br>N.B. Il cooldown di questa abilità è di 60 secondi.', '1', '15', '212', 'personale', 'attivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `distanza_abilita`, `effetto_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('militare', 'Lock and Load', 'Il personaggio può, dopo aver colpito un bersaglio con il lanciagranate, aumentare di 1 il valore iniziale di\nELETTRO! della prima abilità con controller che utilizza contro lo stesso bersaglio, entro 1 minuto.', '1', '15', '194', 'personale', 'passivo', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `prerequisito_abilita`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('civile', 'Riparazione Rapida', 'Il personaggio riduce il tempo TOTALE di applicazione dell’abilità RIPARARE di 1 minuto (fino ad un minimo di 1\nminuto).\r', '30', '4', '44', '0', '0', '0');
INSERT INTO `abilita` (`tipo_abilita`, `nome_abilita`, `descrizione_abilita`, `costo_abilita`, `classi_id_classe`, `offset_pf_abilita`, `offset_shield_abilita`, `offset_mente_abilita`) VALUES ('civile', 'Nello Schifo Fino al Collo', 'Il personaggio può ignorare gli effetti negativi di un\'area ambientale (relativamente a condizioni ambientali\navverse) come indicato nelle apposite interazioni.\r', '60', '4', '0', '0', '0');


-- visualizzazione abilità
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('visualizza_pagina_gestione_abilita', 'L\'utente può accedere alla pagina delle abilità');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'visualizza_pagina_gestione_abilita');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'visualizza_pagina_gestione_abilita');
INSERT INTO `grants` (`nome_grant`, `descrizione_grant`) VALUES ('recuperaAbilita', 'L\'utente può recuperare dal db la lista delle abilit&agrave;.');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('admin', 'recuperaAbilita');
INSERT INTO `ruoli_has_grants` (`ruoli_nome_ruolo`, `grants_nome_grant`) VALUES ('staff', 'recuperaAbilita');

-- AGGIORNARE PROCEDURA CHECK ABILITA'