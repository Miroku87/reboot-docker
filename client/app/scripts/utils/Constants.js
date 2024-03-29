var Constants = {};

Constants.API_URL = "http://localhost/api.php";
Constants.SITE_URL = "http://localhost:9000";

Constants.API_POST_REGISTRA = Constants.API_URL + "/usersmanager/registra";
Constants.API_POST_RECUPERO_PWD = Constants.API_URL + "/usersmanager/recuperapassword";
Constants.API_POST_LOGIN = Constants.API_URL + "/usersmanager/login";
Constants.API_POST_MOD_GIOCATORE = Constants.API_URL + "/usersmanager/modificautente";
Constants.API_POST_MOD_PWD = Constants.API_URL + "/usersmanager/modificapassword";
Constants.API_POST_CREAPG = Constants.API_URL + "/charactersmanager/creapg";
Constants.API_POST_ACQUISTA = Constants.API_URL + "/charactersmanager/acquista";
Constants.API_POST_EDIT_PG = Constants.API_URL + "/charactersmanager/modificapg";
Constants.API_POST_EDIT_ETA_PG = Constants.API_URL + "/charactersmanager/modificaetapg";
Constants.API_POST_EDIT_MOLTI_PG = Constants.API_URL + "/charactersmanager/modificamoltipg";
Constants.API_POST_MESSAGGIO = Constants.API_URL + "/messagingmanager/inviamessaggio";
Constants.API_POST_EVENTO = Constants.API_URL + "/eventsmanager/creaevento";
Constants.API_POST_MOD_EVENTO = Constants.API_URL + "/eventsmanager/modificaevento";
Constants.API_POST_ISCRIZIONE = Constants.API_URL + "/eventsmanager/iscrivipg";
Constants.API_POST_DISISCRIZIONE = Constants.API_URL + "/eventsmanager/disiscrivipg";
Constants.API_POST_PUBBLICA_EVENTO = Constants.API_URL + "/eventsmanager/pubblicaevento";
Constants.API_POST_RITIRA_EVENTO = Constants.API_URL + "/eventsmanager/ritiraevento";
Constants.API_POST_DEL_EVENTO = Constants.API_URL + "/eventsmanager/eliminaevento";
Constants.API_POST_EDIT_ISCRIZIONE = Constants.API_URL + "/eventsmanager/modificaiscrizionepg";
Constants.API_POST_PUNTI_EVENTO = Constants.API_URL + "/eventsmanager/impostapuntiassegnatievento";
Constants.API_POST_CREA_RUOLO = Constants.API_URL + "/grantsmanager/crearuolo";
Constants.API_POST_DEL_RUOLO = Constants.API_URL + "/grantsmanager/eliminaruolo";
Constants.API_POST_ASSOCIA_PERMESSI = Constants.API_URL + "/grantsmanager/associapermessi";
Constants.API_POST_CREA_ARTICOLO = Constants.API_URL + "/newsmanager/creanotizia";
Constants.API_POST_EDIT_ARTICOLO = Constants.API_URL + "/newsmanager/modificanotizia";
Constants.API_POST_PUBBLICA_ARTICOLO = Constants.API_URL + "/newsmanager/pubblicanotizia";
Constants.API_POST_RITIRA_ARTICOLO = Constants.API_URL + "/newsmanager/ritiranotizia";
Constants.API_POST_CRAFTING_PROGRAMMA = Constants.API_URL + "/craftingmanager/inserisciricettanetrunner";
Constants.API_POST_CRAFTING_TECNICO = Constants.API_URL + "/craftingmanager/inserisciricettatecnico";
Constants.API_POST_CRAFTING_CHIMICO = Constants.API_URL + "/craftingmanager/inserisciricettamedico";
Constants.API_POST_NUOVO_COMPONENTE = Constants.API_URL + "/craftingmanager/inseriscicomponente";
Constants.API_EDIT_RICETTA = Constants.API_URL + "/craftingmanager/modificaricetta";
Constants.API_POST_EDIT_COMPONENT = Constants.API_URL + "/craftingmanager/modificacomponente";
Constants.API_POST_BULK_EDIT_COMPONENTS = Constants.API_URL + "/craftingmanager/modificagruppocomponenti"
Constants.API_POST_REMOVE_COMPONENT = Constants.API_URL + "/craftingmanager/eliminacomponente";
Constants.API_POST_RICETTE_STAMPATE = Constants.API_URL + "/craftingmanager/segnaricettecomestampate";
Constants.API_POST_TRANSAZIONE = Constants.API_URL + "/transactionmanager/inseriscitransazione";
Constants.API_POST_TRANSAZIONE_MOLTI = Constants.API_URL + "/transactionmanager/inseriscitransazionemolti";
Constants.API_COMPRA_COMPONENTI = Constants.API_URL + "/transactionmanager/compracomponenti";
Constants.API_COMPRA_OGGETTI = Constants.API_URL + "/transactionmanager/compraoggetti";

Constants.API_POST_CARTELLINO = Constants.API_URL + "/cartellinimanager/creacartellino";
Constants.API_POST_EDIT_CARTELLINO = Constants.API_URL + "/cartellinimanager/modificacartellino";
Constants.API_POST_DEL_CARTELLINO = Constants.API_URL + "/cartellinimanager/eliminacartellino";

Constants.API_GET_LOGOUT = Constants.API_URL + "/usersmanager/logout";
Constants.API_GET_ACESS = Constants.API_URL + "/usersmanager/controllaaccesso";
Constants.API_CHECK_PWD = Constants.API_URL + "/usersmanager/controllapwd";
Constants.API_GET_PLAYERS = Constants.API_URL + "/usersmanager/recuperalistagiocatori";
Constants.API_GET_NOTE_GIOCATORE = Constants.API_URL + "/usersmanager/recuperanoteutente";
Constants.API_GET_STAFF_USERS = Constants.API_URL + "/usersmanager/recuperautentistaffer";

Constants.API_GET_PGS_PROPRI = Constants.API_URL + "/charactersmanager/recuperapropripg";
Constants.API_GET_PG_LOGIN = Constants.API_URL + "/charactersmanager/loginpg";
Constants.API_GET_INFO = Constants.API_URL + "/charactersmanager/recuperainfoclassi";
Constants.API_GET_OPZIONI_ABILITA = Constants.API_URL + "/charactersmanager/recuperaopzioniabilita";
Constants.API_GET_PGS = Constants.API_URL + "/charactersmanager/mostrapersonaggi";
Constants.API_GET_PGS_CON_ID = Constants.API_URL + "/charactersmanager/mostrapersonaggiconid";
Constants.API_GET_STORICO_PG = Constants.API_URL + "/charactersmanager/recuperastorico";
Constants.API_GET_NOTE_CARTELLINO_PG = Constants.API_URL + "/charactersmanager/recuperaNoteCartellino";

Constants.API_GET_MESSAGGI = Constants.API_URL + "/messagingmanager/recuperamessaggi";
Constants.API_GET_CONVERSAZIONE = Constants.API_URL + "/messagingmanager/recuperaconversazione";
Constants.API_GET_DESTINATARI_FG = Constants.API_URL + "/messagingmanager/recuperadestinatarifg";
Constants.API_GET_DESTINATARI_IG = Constants.API_URL + "/messagingmanager/recuperadestinatariig";
Constants.API_GET_MESSAGGI_NUOVI = Constants.API_URL + "/messagingmanager/recuperanonletti";

Constants.API_GET_EVENTO = Constants.API_URL + "/eventsmanager/recuperaevento";
Constants.API_GET_LISTA_EVENTI = Constants.API_URL + "/eventsmanager/recuperalistaeventi";
Constants.API_GET_INFO_ISCRITTI_AVANZATE = Constants.API_URL + "/eventsmanager/recuperalistaiscrittiavanzato";
Constants.API_GET_INFO_ISCRITTI_BASE = Constants.API_URL + "/eventsmanager/recuperalistaiscrittibase";
Constants.API_GET_PARTECIPANTI_EVENTO = Constants.API_URL + "/eventsmanager/recuperalistapartecipanti";
Constants.API_GET_NOTE_ISCRITTO = Constants.API_URL + "/eventsmanager/recuperanotepgiscritto";

Constants.API_GET_RUOLI = Constants.API_URL + "/grantsmanager/recuperaruoli";
Constants.API_GET_PERMESSI = Constants.API_URL + "/grantsmanager/recuperalistapermessi";
Constants.API_GET_PERMESSI_DEI_RUOLI = Constants.API_URL + "/grantsmanager/recuperapermessideiruoli";

Constants.API_GET_ARTICOLI_PUBBLICATI = Constants.API_URL + "/newsmanager/recuperanotiziepubbliche";
Constants.API_GET_TUTTI_ARTICOLI = Constants.API_URL + "/newsmanager/recuperanotizie";

Constants.API_GET_RICETTE = Constants.API_URL + "/craftingmanager/recuperaricette";
Constants.API_GET_RICETTE_CON_ID = Constants.API_URL + "/craftingmanager/recuperaricetteconid";
Constants.API_GET_RICETTE_PER_RAVSHOP = Constants.API_URL + "/craftingmanager/recuperaricetteperravshop";
Constants.API_GET_COMPONENTI_BASE = Constants.API_URL + "/craftingmanager/recuperacomponentibase";
Constants.API_GET_COMPONENTI_AVANZATO = Constants.API_URL + "/craftingmanager/recuperacomponentiavanzato";
Constants.API_GET_COMPONENTI_CON_ID = Constants.API_URL + "/craftingmanager/recuperacomponenticonid";

Constants.API_GET_INFO_BANCA = Constants.API_URL + "/transactionmanager/recuperainfobanca";
Constants.API_GET_MOVIMENTI = Constants.API_URL + "/transactionmanager/recuperamovimenti";

Constants.API_GET_STATS_CLASSI = Constants.API_URL + "/statistics/recuperastatisticheclassi";
Constants.API_GET_STATS_ABILITA = Constants.API_URL + "/statistics/recuperastatisticheabilita";
Constants.API_GET_STATS_ABILITA_PER_PROFESSIONE = Constants.API_URL + "/statistics/recuperastatisticheabilitaperprofessione";
Constants.API_GET_STATS_CREDITI = Constants.API_URL + "/statistics/recuperastatistichecrediti";
Constants.API_GET_STATS_PG = Constants.API_URL + "/statistics/recuperastatistichepg";
Constants.API_GET_STATS_PUNTEGGI = Constants.API_URL + "/statistics/recuperastatistichepunteggi";
Constants.API_GET_STATS_RAVSHOP = Constants.API_URL + "/statistics/recuperastatisticheqtaravshop";
Constants.API_GET_STATS_ACQUISTI_RAVSHOP = Constants.API_URL + "/statistics/recuperastatisticheacquistiravshop";
Constants.API_GET_STATS_ARMI = Constants.API_URL + "/statistics/recuperastatistichearmistampate";

Constants.API_GET_TAGS = Constants.API_URL + "/cartellinimanager/recuperatagsunici";
Constants.API_GET_CARTELLINI = Constants.API_URL + "/cartellinimanager/recuperacartellini";
Constants.API_GET_CARTELLINI_CON_ID = Constants.API_URL + "/cartellinimanager/recuperacartelliniconid";
Constants.API_GET_MODELLI_CARTELLINI = Constants.API_URL + "/cartellinimanager/recuperamodelli";

Constants.API_GET_ABILITA = Constants.API_URL + "/abilitiesmanager/recuperaabilita"

Constants.API_DEL_GIOCATORE = Constants.API_URL + "/usersmanager/eliminagiocatore";
Constants.API_DEL_CLASSE_PG = Constants.API_URL + "/charactersmanager/rimuoviclassepg";
Constants.API_DEL_ABILITA_PG = Constants.API_URL + "/charactersmanager/rimuoviabilitapg";
Constants.API_DEL_PERSONAGGIO = Constants.API_URL + "/charactersmanager/eliminapg";

Constants.API_GET_RUMORS = Constants.API_URL + "/rumorsmanager/recuperalistarumors";
Constants.API_PUT_RUMORS = Constants.API_URL + "/rumorsmanager/inseriscirumor";
Constants.API_POST_RUMORS = Constants.API_URL + "/rumorsmanager/modificarumor";
Constants.API_DEL_RUMORS = Constants.API_URL + "/rumorsmanager/eliminarumor";

Constants.LOGIN_PAGE = Constants.SITE_URL + "/";
Constants.MAIN_PAGE = Constants.SITE_URL + "/main.html";
Constants.PG_PAGE = Constants.SITE_URL + "/scheda_pg.html";
Constants.ABILITY_SHOP_PAGE = Constants.SITE_URL + "/negozio_abilita.html";
Constants.STAMPA_CARTELLINI_PAGE = Constants.SITE_URL + "/stampa_cartellini.html";
Constants.STAMPA_ISCRITTI_PAGE = Constants.SITE_URL + "/stampa_tabella_iscritti.html";
Constants.STAMPA_RICETTE = Constants.SITE_URL + "/stampa_ricetta.html";
Constants.CREAPG_PAGE = Constants.SITE_URL + "/crea_pg.html";
Constants.EVENTI_PAGE = Constants.SITE_URL + "/eventi.html";
Constants.CREA_EVENTO_PAGE = Constants.SITE_URL + "/crea_evento.html";
Constants.MESSAGGI_PAGE = Constants.SITE_URL + "/messaggi.html";
Constants.PROFILO_PAGE = Constants.SITE_URL + "/profilo.html";

Constants.PX_TOT = 220;
Constants.PC_TOT = 6;
Constants.ANNO_PRIMO_LIVE = 271;
Constants.ANNO_INIZIO_OLOCAUSTO = 239;
Constants.ANNO_FINE_OLOCAUSTO = 244;
Constants.SCONTO_MERCATO = 5;
Constants.QTA_PER_SCONTO_MERCATO = 6;
Constants.CARTELLINI_PER_PAG = 6;

Constants.COSTI_PROFESSIONI = [0, 20, 40, 60, 80, 100, 120];

Constants.PREREQUISITO_TUTTE_ABILITA = -1;
Constants.PREREQUISITO_F_TERRA_T_SCELTO = -2;
Constants.PREREQUISITO_5_SUPPORTO_BASE = -3;
Constants.PREREQUISITO_3_GUASTATOR_BASE = -4;
Constants.PREREQUISITO_4_SPORTIVO = -5;
Constants.PREREQUISITO_3_ASSALTATA_BASE = -6;
Constants.PREREQUISITO_3_GUASTATO_AVAN = -7;
Constants.PREREQUISITO_3_ASSALTATA_AVAN = -8;
Constants.PREREQUISITO_15_GUARDIAN_BASE = -9;
Constants.PREREQUISITO_5_GUARDIANO_BAAV = -10;
Constants.PREREQUISITO_4_ASSALTATO_BASE = -11;
Constants.PREREQUISITO_7_SUPPORTO_BASE = -12;
Constants.PREREQUISITO_SMUOVER_MP_RESET = -13;
Constants.PREREQUISITO_15_GUARDIAN_AVAN = -14;
Constants.PREREQUISITO_15_ASSALTAT_BASE = -15;
Constants.PREREQUISITO_15_ASSALTAT_AVAN = -16;
Constants.PREREQUISITO_15_SUPPORTO_BASE = -17;
Constants.PREREQUISITO_15_SUPPORTO_AVAN = -18;
Constants.PREREQUISITO_15_GUASTATO_BASE = -19;
Constants.PREREQUISITO_15_GUASTATO_AVAN = -20;
Constants.PREREQUISITO_3_GUASTATORE = -21;

Constants.ID_ABILITA_F_TERRA = 135;
Constants.ID_ABILITA_T_SCELTO = 130;
Constants.ID_ABILITA_IDOLO = 12;
Constants.ID_ABILITA_ARMA_SEL = 140;
Constants.ID_ABILITA_SMUOVERE = 162;
Constants.ID_ABILITA_MEDPACK_RESET = 167;

Constants.ID_CLASSE_SPORTIVO = 1;
Constants.ID_CLASSE_GUARDIANO_BASE = 8;
Constants.ID_CLASSE_GUARDIANO_AVANZATO = 9;
Constants.ID_CLASSE_ASSALTATORE_BASE = 10;
Constants.ID_CLASSE_ASSALTATORE_AVANZATO = 11;
Constants.ID_CLASSE_SUPPORTO_BASE = 12;
Constants.ID_CLASSE_SUPPORTO_AVANZATO = 13;
Constants.ID_CLASSE_GUASTATORE_BASE = 14;
Constants.ID_CLASSE_GUASTATORE_AVANZATO = 15;

Constants.TIPO_GRANT_PG_PROPRIO = "_proprio";
Constants.TIPO_GRANT_PG_ALTRI = "_altri";
Constants.RUOLO_ADMIN = "admin";
Constants.INTERVALLO_CONTROLLO_MEX = 60000;
Constants.ID_RICETTA_PAG = 4;

Constants.DEFAULT_ACCREDITO_BIT = "Accredito a vostro favore da parte di {1}.";
Constants.DEFAULT_ADDEBITO_BIT = "Addebito a favore di {1}.";

Constants.DEFAULT_ERROR = "Impossibile completare l'operazione, verificare che la tipologia sia conforme alla destinazione.";
Constants.DEVE_ERROR = "Impossibile completare l'operazione. Non &egrave; possibile combinare pi&ugrave; applicazioni che DEVONO dichiarare qualcosa.";

Constants.MAPPA_TIPI_CARTELLINI = {
    schede_pg: { icona: "fa-user", acquistabile: false, nome: "Scheda PG", colore: "bianco", colore_eng: "white" },
    componente_consumabile: { icona: "fa-cubes", acquistabile: true, nome: "Componente Consumabile", colore: "verde", colore_eng: "green" },
    abilita_sp_malattia: { icona: "fa-medkit", acquistabile: false, nome: "Abilit&agrave; Speciale / Malattia", colore: "rosso", colore_eng: "red" },
    armatura_protesi_potenziamento: { icona: "fa-shield", acquistabile: true, nome: "Armatura / Protesi / Potenziamento", colore: "azzurro", colore_eng: "light-blue" },
    arma_equip: { icona: "fa-rocket", acquistabile: true, nome: "Arma / Equipaggiamento", colore: "bianco", colore_eng: "white" },
    interazione_area: { icona: "fa-puzzle-piece", acquistabile: false, nome: "Interazione / Area", colore: "giallo", colore_eng: "yellow" }
};

Constants.DATA_TABLE_LANGUAGE = {
    "decimal": "",
    "emptyTable": "Nessun dato disponibile",
    "info": "Da _START_ a _END_ di _TOTAL_ risultati visualizzati",
    "infoEmpty": "Da 0 a 0 di 0 visualizzati",
    "infoFiltered": "(filtrati da un massimo di _MAX_ risultati)",
    "infoPostFix": "",
    "thousands": ".",
    "lengthMenu": "_MENU_",
    "loadingRecords": "Carico...",
    "processing": "Elaboro...",
    "search": "Cerca:",
    "zeroRecords": "Nessuna corrispondenza trovata",
    "paginate": {
        "first": "Primo",
        "last": "Ultimo",
        "next": ">>",
        "previous": "<<"
    },
    "aria": {
        "sortAscending": ": clicca per ordinare la colonna in ordine crescente",
        "sortDescending": ": clicca per ordinare la colonna in ordine decrescente"
    }
};

Constants.CHART_COLORS = ["#fcb3bc", "#ff61a1", "#e026c9", "#a726e3", "#735e7f", "#a42946", "#df7623", "#f8ae29", "#ffd658", "#cde02f", "#70f03b", "#70e026", "#11c26a", "#3affb5", "#3a80ff", "#114a67", "#b8656f", "#711d96", "#431d96", "#204b99", "#1e9194", "#1b9a17", "#8f9a18", "#c2d517", "#e6ff00", "#ffb403", "#fe7903", "#e0611a", "#dc3717", "#f11310", "#821613", "#8e1f40"];

Constants.SPECIAL_PREREQUISITES = {
    "-1": "tutte le abilta della classe",
    "-2": "FUOCO A TERRA e TIRATORE SCELTO",
    "-3": "almeno 5 abilita di Supporto Base",
    "-4": "almeno 3 abilita Guastatore Base",
    "-5": "almeno 4 abilita da Sportivo",
    "-6": "almeno 3 talenti da Assaltatore Base",
    "-7": "almeno 3 talenti da Guastatore Avanzato",
    "-8": "almeno 3 talenti da Assaltatore Avanzato",
    "-9": "almeno 15 abilita da Guardiano Base",
    "-10": "almeno 5 abilita da Guardiano Base / Avanzato",
    "-11": "almeno 4 abilita da Assaltatore Base",
    "-12": "almeno 7 abilita da Supporto Base",
    "-13": "SMUOVERE e MEDIPACK - RESETTARE",
    "-14": "almeno 15 abilita da Guardiano Avanzato",
    "-15": "almeno 15 abilita da Assaltatore Base",
    "-16": "almeno 15 abilita da Assaltatore Avanzato",
    "-17": "almeno 15 abilita da Supporto Base",
    "-18": "almeno 15 abilita da Supporto Avanzato",
    "-19": "almeno 15 abilita da Guastatore Base",
    "-20": "almeno 15 abilita da Guastatore Avanzato",
}