﻿var RegistrationManager = function () {
    var CIVILIAN_CLASS_LIST_ID = "listaClassiCivili",
        CIVILIAN_CLASS_BUCKET_ID = "listaClassiCiviliAcquistate",
        MILITARY_CLASS_LIST_ID = "listaClassiMilitari",
        MILITARY_CLASS_BUCKET_ID = "listaClassiMilitariAcquistate",
        CIVILIAN_ABILITY_LIST_ID = "listaAbilitaCivili",
        CIVILIAN_ABILITY_BUCKET_ID = "listaAbilitaCiviliAcquistate",
        MILITARY_ABILITY_LIST_ID = "listaAbilitaMilitari",
        MILITARY_ABILITY_BUCKET_ID = "listaAbilitaMilitariAcquistate",
        MILITARY_BASE_CLASS_LABEL = "base",
        MILITARY_ADVA_CLASS_LABEL = "avanzata";

    return {
        init: function () {
            this.setListeners();
            this.getClassesInfo();
            this.getInfo();
            this.getOptionsInfo();
            this.getStaffUsers();
            $("#inviaDati").click(this.inviaDati.bind(this));
        },

        setListeners: function () {
            $('.icheck input[type="checkbox"]').iCheck("destroy");
            $('.icheck input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });
        },

        onMSError: function (err) {
            console.log(err);
        },

        classeCivileRenderizzata: function (dato, lista, indice, dom_elem) {
            //dato.costo_classe = Constants.COSTI_PROFESSIONI[ this.ms_classi_civili.numeroCarrello() ];
            //dato.innerHTML = dom_elem[0].innerHTML = dato.nome_classe + " ( " + Constants.COSTI_PROFESSIONI[
            // this.ms_classi_civili.numeroCarrello() ] + " PX )";
        },

        ricalcolaCostiClassiCivili: function () {
            var indice_costo = this.ms_classi_civili.numeroCarrello(),
                dati_lista = this.ms_classi_civili.datiListaAttuali();

            for (var l in dati_lista) {
                var d = dati_lista[l];

                if (d.id_classe) {
                    d.costo_classe = Constants.COSTI_PROFESSIONI[indice_costo];
                    d.innerHTML = d.nome_classe + " ( " + d.costo_classe + " PX )";
                }
            }

            this.ms_classi_civili.ridisegnaListe();
        },

        classeCivileSelezionata: function (tipo_lista, dato, lista, dom_elem, selezionati, da_utente) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            var indice_costo = this.ms_classi_civili.numeroCarrello() + selezionati.length,
                id_selezionati = selezionati.map(function (el) { return el.replace(/\D/g, "") + ""; });

            for (var l in lista) {
                var d = lista[l];

                if (d.id_classe && id_selezionati.indexOf(l) === -1) {
                    d.costo_classe = Constants.COSTI_PROFESSIONI[indice_costo];
                    d.innerHTML = d.nome_classe + " ( " + d.costo_classe + " PX )";
                }
            }

            this.ms_classi_civili.ridisegnaListe();

            try {
                if (da_utente !== false)
                    this.punti_exp.diminuisciConteggio(dato.costo_classe);

                this.inserisciDatiAbilitaCivili([dato]);
            } catch (e) {
                if (e.message === Contatore.ERRORS.VAL_TROPPO_BASSO) {
                    this.ms_classi_civili.deselezionaUltimo();
                    Utils.showError("Non hai più punti per comprare altre professioni.");
                }
            }
        },

        abilitaCivileSelezionata: function (tipo_lista, dato, lista, dom_elem, selezionati) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            try {
                this.punti_exp.diminuisciConteggio(dato.costo_abilita);

                if (this.opzioni_abilita[dato.id_abilita]) {
                    $("#opzioni_abilita").show(400);
                    $("#opzioni_" + dato.id_abilita).show(400);
                }
            } catch (e) {
                if (e.message === Contatore.ERRORS.VAL_TROPPO_BASSO) {
                    this.ms_abilita_civili.deselezionaUltimo(); //TODO: controllare bene questo!!!
                    Utils.showError("Non hai più punti per comprare altre abilit&agrave;.");
                }
            }
        },

        classeCivileDeselezionata: function (tipo_lista, dato, lista, dom_elem, selezionati) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            var indice_costo = this.ms_classi_civili.numeroCarrello() + selezionati.length,
                indice_costo_2 = parseInt(indice_costo, 10),
                id_selezionati = selezionati.map(function (el) { return el.replace(/\D/g, "") + ""; });

            for (var l in lista) {
                var d = lista[l];

                if (d.id_classe && id_selezionati.indexOf(l) === -1) {
                    d.costo_classe = Constants.COSTI_PROFESSIONI[indice_costo];
                    d.innerHTML = d.nome_classe + " ( " + d.costo_classe + " PX )";
                } else if (d.id_classe && id_selezionati.indexOf(l) !== -1 && indice_costo_2 >= 0) {
                    d.costo_classe = Constants.COSTI_PROFESSIONI[--indice_costo_2];
                    d.innerHTML = d.nome_classe + " ( " + d.costo_classe + " PX )";
                }
            }

            this.ms_classi_civili.ridisegnaListe();

            this.punti_exp.aumentaConteggio(dato.costo_classe);
            this.ms_abilita_civili.rimuoviDatiLista("id_classe", dato.id_classe);
        },

        abilitaCivileDeselezionata: function (tipo_lista, dato, lista, dom_elem, selezionati) {
            this.punti_exp.aumentaConteggio(dato.costo_abilita);

            if (this.opzioni_abilita[dato.id_abilita])
                $("#opzioni_" + dato.id_abilita).hide(400, function () {
                    if ($("#opzioni_abilita .form-group:visible").length === 0)
                        $("#opzioni_abilita").hide(400);
                });

        },

        abilitaMilitareSelezionata: function (tipo_lista, dato, lista, dom_elem, selezionati) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            try {
                this.punti_comb.diminuisciConteggio(dato.costo_abilita);

                if (this.opzioni_abilita[dato.id_abilita]) {
                    $("#opzioni_abilita").show(400);
                    $("#opzioni_" + dato.id_abilita).show(400);
                }
            } catch (e) {
                if (e.message === Contatore.ERRORS.VAL_TROPPO_BASSO) {
                    this.ms_abilita_militari.deselezionaUltimo();
                    Utils.showError("Non hai più punti per comprare altre abilit&agrave;.");
                }
            }
        },

        abilitaMilitareDeselezionata: function (tipo_lista, dato, lista, dom_elem, selezionati) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            this.punti_comb.aumentaConteggio(dato.costo_abilita);

            if (this.opzioni_abilita[dato.id_abilita])
                $("#opzioni_" + dato.id_abilita).hide(400, function () {
                    if ($("#opzioni_abilita .form-group:visible").length === 0)
                        $("#opzioni_abilita").hide(400);
                });
        },

        impostaMSClassiCivili: function () {
            var dati = [],
                punti = this.pg_info ? this.pg_info.px_risparmiati : Constants.PX_TOT;

            for (var d in this.classInfos.classi.civile) {
                var dato = this.classInfos.classi.civile[d];

                if (typeof dato === "object") {
                    dato = JSON.parse(JSON.stringify(dato));

                    dato.innerHTML = dato.nome_classe + " ( " + Constants.COSTI_PROFESSIONI[0] + " PX )";
                    dato.costo_classe = Constants.COSTI_PROFESSIONI[0];
                    dato.prerequisito = null;
                    dato.gia_selezionato = false;

                    if (this.pg_info)
                        dato.gia_selezionato = this.pg_info.classi.civile.filter(function (e) { return e.id_classe === dato.id_classe }).length > 0;

                    dati.push(dato);
                }
            }

            this.ms_classi_civili = new MultiSelector({
                id_lista: CIVILIAN_CLASS_LIST_ID,
                id_carrello: CIVILIAN_CLASS_BUCKET_ID,
                btn_aggiungi: $(".compra-classe-civile-btn"),
                btn_rimuovi: $(".butta-classe-civile-btn"),
                ordina_per_attr: "id_classe",
                dati_lista: dati,
                onError: this.onMSError.bind(this),
                elemSelezionato: this.classeCivileSelezionata.bind(this),
                elemDeselezionato: this.classeCivileDeselezionata.bind(this),
                elemRenderizzato: this.classeCivileRenderizzata.bind(this)
            });
            this.ms_classi_civili.crea();

            this.punti_exp = new Contatore({
                elemento: $("#puntiEsperienza"),
                valore_max: punti,
                valore_ora: punti
            });
        },

        classeMilitareSelezionata: function (tipo_lista, dato, lista, dom_elem, selezionati, da_utente) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            try {
                if (da_utente !== false)
                    this.punti_comb.diminuisciConteggio(dato.costo_classe);

                this.inserisciDatiAbilitaMilitari([dato])
            } catch (e) {
                if (e.message === Contatore.ERRORS.VAL_TROPPO_BASSO) {
                    this.ms_classi_militari.deselezionaUltimo();
                    Utils.showError("Non hai più punti per comprare altre classi.");
                }
            }
        },

        classeMilitareDeselezionata: function (tipo_lista, dato) {
            if (tipo_lista !== MultiSelector.TIPI_LISTE.LISTA)
                return false;

            this.punti_comb.aumentaConteggio(dato.costo_classe);
            this.ms_abilita_militari.rimuoviDatiLista("id_classe", dato.id_classe);
        },

        classeMilitareAcquistabile: function (id_prerequisito, dato, dati_lista, dati_carrello, selezionati) {
            var da_controllare = dati_carrello.concat(selezionati || []),
                elem_selezionato = selezionati.filter(function (el) { return el.id_classe === dato.id_classe }).length > 0;

            if (da_controllare.length === 2 && !elem_selezionato)
                return false;

            if (!id_prerequisito)
                return true;

            return da_controllare.filter(function (el) { return el.id_classe === id_prerequisito; }).length > 0;
        },

        impostaMSClassiMilitari: function () {
            var dati = [],
                punti = this.pg_info ? this.pg_info.pc_risparmiati : Constants.PC_TOT;

            for (var d in this.classInfos.classi.militare) {
                var dato = this.classInfos.classi.militare[d];

                if (typeof dato === "object") {
                    dato = JSON.parse(JSON.stringify(dato));

                    dato.innerHTML = dato.nome_classe + " ( 1 PC )";
                    dato.prerequisito = this.classeMilitareAcquistabile.bind(this, dato.prerequisito_classe);
                    dato.gia_selezionato = false;

                    if (this.pg_info)
                        dato.gia_selezionato = this.pg_info.classi.militare.filter(function (e) { return e.id_classe === dato.id_classe }).length > 0 || false;

                    dati.push(dato);
                }
            }

            this.ms_classi_militari = new MultiSelector({
                id_lista: MILITARY_CLASS_LIST_ID,
                id_carrello: MILITARY_CLASS_BUCKET_ID,
                btn_aggiungi: $(".compra-classe-militare-btn"),
                btn_rimuovi: $(".butta-classe-militare-btn"),
                ordina_per_attr: "id_classe",
                dati_lista: dati,
                onError: this.onMSError.bind(this),
                elemSelezionato: this.classeMilitareSelezionata.bind(this),
                elemDeselezionato: this.classeMilitareDeselezionata.bind(this)
            });
            this.ms_classi_militari.crea();

            this.punti_comb = new Contatore({
                elemento: $("#puntiCombattimento"),
                valore_max: punti,
                valore_ora: punti
            });
        },

        controllaPrerequisitoAbilita: function (elem, dati_lista, dati_carrello, selezionati) {
            var da_controllare = dati_carrello.concat(selezionati || []),
                pre = parseInt(elem.prerequisito_abilita),
                id = parseInt(elem.id_abilita);

            if (pre === Constants.PREREQUISITO_TUTTE_ABILITA)
                return da_controllare.length >= this.classInfos.abilita[elem.id_classe].length - 1;
            else if (pre === Constants.PREREQUISITO_4_SPORTIVO) {
                da_controllare = da_controllare.filter(function (el) {
                    return parseInt(el.id_abilita, 10) !== Constants.ID_ABILITA_IDOLO &&
                        (!el.prerequisito || (el.prerequisito && parseInt(el.prerequisito.id_abilita, 10) !== Constants.ID_ABILITA_IDOLO))
                });

                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_SPORTIVO && parseInt(e.id_abilita) !== id;
                }).length >= 4;
            } else if (pre === Constants.PREREQUISITO_F_TERRA_T_SCELTO)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_abilita) === Constants.ID_ABILITA_F_TERRA ||
                        parseInt(e.id_abilita) === Constants.ID_ABILITA_T_SCELTO;
                }).length === 2;
            else if (pre === Constants.PREREQUISITO_SMUOVER_MP_RESET)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_abilita) === Constants.ID_ABILITA_SMUOVERE ||
                        parseInt(e.id_abilita) === Constants.ID_ABILITA_MEDPACK_RESET;
                }).length === 2;
            else if (pre === Constants.PREREQUISITO_5_SUPPORTO_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_SUPPORTO_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 5;
            else if (pre === Constants.PREREQUISITO_3_ASSALTATA_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_ASSALTATORE_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 3;
            else if (pre === Constants.PREREQUISITO_3_ASSALTATA_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_ASSALTATORE_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 3;
            else if (pre === Constants.PREREQUISITO_3_GUASTATOR_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 3;
            else if (pre === Constants.PREREQUISITO_3_GUASTATO_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 3;
            else if (pre === Constants.PREREQUISITO_15_GUARDIAN_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUARDIANO_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_5_GUARDIANO_BAAV)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUARDIANO_BASE && parseInt(e.id_abilita) !== id;
                }).length +
                    da_controllare.filter(function (e) {
                        return parseInt(e.id_classe) === Constants.ID_CLASSE_GUARDIANO_AVANZATO && parseInt(e.id_abilita) !== id;
                    }).length >= 5;
            else if (pre === Constants.PREREQUISITO_4_ASSALTATO_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_ASSALTATORE_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 4;
            else if (pre === Constants.PREREQUISITO_7_SUPPORTO_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_SUPPORTO_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 7;
            else if (pre === Constants.PREREQUISITO_15_GUARDIAN_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUARDIANO_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_ASSALTAT_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_ASSALTATORE_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_ASSALTAT_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_ASSALTATORE_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_SUPPORTO_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_SUPPORTO_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_SUPPORTO_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_SUPPORTO_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_GUASTATO_BASE)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_BASE && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_15_GUASTATO_AVAN)
                return da_controllare.filter(function (e) {
                    return parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_AVANZATO && parseInt(e.id_abilita) !== id;
                }).length >= 15;
            else if (pre === Constants.PREREQUISITO_3_GUASTATORE)
                return da_controllare.filter(function (e) {
                    return (parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_AVANZATO
                        || parseInt(e.id_classe) === Constants.ID_CLASSE_GUASTATORE_BASE)
                        && parseInt(e.id_abilita) !== id;
                }).length >= 3;

            return false;
        },

        impostaMSAbilitaCivili: function () {
            this.ms_abilita_civili = new MultiSelector({
                id_lista: CIVILIAN_ABILITY_LIST_ID,
                id_carrello: CIVILIAN_ABILITY_BUCKET_ID,
                btn_aggiungi: $(".compra-abilita-civile-btn"),
                btn_rimuovi: $(".butta-abilita-civile-btn"),
                ordina_per_attr: "id_abilita",
                onError: this.onMSError.bind(this),
                elemSelezionato: this.abilitaCivileSelezionata.bind(this),
                elemDeselezionato: this.abilitaCivileDeselezionata.bind(this)
            });
            this.ms_abilita_civili.crea();
        },

        impostaMSAbilitaMilitari: function () {
            this.ms_abilita_militari = new MultiSelector({
                id_lista: MILITARY_ABILITY_LIST_ID,
                id_carrello: MILITARY_ABILITY_BUCKET_ID,
                btn_aggiungi: $(".compra-abilita-militare-btn"),
                btn_rimuovi: $(".butta-abilita-militare-btn"),
                ordina_per_attr: "id_abilita",
                onError: this.onMSError.bind(this),
                elemSelezionato: this.abilitaMilitareSelezionata.bind(this),
                elemDeselezionato: this.abilitaMilitareDeselezionata.bind(this)
            });
            this.ms_abilita_militari.crea();
        },

        inserisciDatiAbilita: function (selezionati, ms) {
            var dati = [];

            for (var s in selezionati) {
                var id_classe = selezionati[s].id_classe,
                    px_testo = selezionati[s].tipo_classe === "civile" ? "PX" : "PC";

                for (var d in this.classInfos.abilita[id_classe]) {
                    var dato = this.classInfos.abilita[id_classe][d];

                    if (typeof dato === "object") {
                        dato = JSON.parse(JSON.stringify(dato));

                        var prerequisito = "";
                        if (parseInt(dato.prerequisito_abilita) > 0)
                            prerequisito = "<br><br>Prerequisiti:<br>" + dato.nome_prerequisito_abilita;
                        else if (parseInt(dato.prerequisito_abilita) < 0)
                            prerequisito = "<br><br>Prerequisiti:<br>" + Constants.SPECIAL_PREREQUISITES[dato.prerequisito_abilita];

                        dato.innerHTML = dato.nome_abilita + " ( " + dato.costo_abilita + " " + px_testo + " )";
                        dato.prerequisito = null;
                        dato.title = dato.nome_abilita ? dato.nome_abilita : dato.nome_classe;
                        dato.gia_selezionato = false;

                        if (this.pg_info)
                            dato.gia_selezionato = this.pg_info.abilita[dato.tipo_abilita].filter(function (e) { return e.id_abilita === dato.id_abilita }).length > 0;

                        if (dato.descrizione_abilita) {
                            dato.content = dato.descrizione_abilita + prerequisito;
                            dato.title = dato.nome_abilita;
                            delete dato.descrizione_abilita;
                            delete dato.nome_prerequisito_abilita;
                        }

                        if (dato.prerequisito_abilita && dato.prerequisito_abilita > 0)
                            dato.prerequisito = { id_abilita: dato.prerequisito_abilita };
                        else if (dato.prerequisito_abilita && dato.prerequisito_abilita < 0)
                            dato.prerequisito = this.controllaPrerequisitoAbilita.bind(this);

                        dati.push(dato);
                    }
                }
            }

            ms.aggiungiDatiLista(dati);
            ms.deselezionaTutti();
        },

        inserisciDatiAbilitaCivili: function (selezionati) {
            this.inserisciDatiAbilita.call(this, selezionati, this.ms_abilita_civili);
        },

        inserisciDatiAbilitaMilitari: function (selezionati) {
            this.inserisciDatiAbilita.call(this, selezionati, this.ms_abilita_militari);
        },

        impostaOpzioniAbilita: function () {
            for (var oa in this.opzioni_abilita) {
                var op = this.opzioni_abilita[oa];

                if (typeof oa === "string") {
                    var elems = op.reduce(function (pre, ora) { return pre + "<option value=\"" + ora + "\">" + ora + "</option>" }, "");
                    $("#opzioni_" + oa + " select").append(elems);

                    if (this.pg_info && this.pg_info.opzioni && this.pg_info.opzioni[oa]) {
                        $("#opzioni_abilita").show(400);
                        console.log(this.pg_info.opzioni[oa].opzione);
                        $("#opzioni_" + oa + " select").val(this.pg_info.opzioni[oa].opzione).attr("disabled", true);
                        $("#opzioni_" + oa).show(400);
                    }
                }
            }
        },

        getInfo: function () {
            this.pg_info = JSON.parse(window.localStorage.getItem('logged_pg'));
            this.user_info = JSON.parse(window.localStorage.getItem('user'));
            this.permessoPNG = Utils.controllaPermessiUtente(this.user_info, ["creaPNG"]);
        },

        getClassesInfo: function () {
            Utils.requestData(
                Constants.API_GET_INFO,
                "GET",
                "",
                function (data) {
                    this.classInfos = data.info;
                    this.impostaMSClassiCivili();
                    this.impostaMSClassiMilitari();
                    this.impostaMSAbilitaCivili();
                    this.impostaMSAbilitaMilitari();
                }.bind(this)
            );
        },

        getOptionsInfo: function () {
            Utils.requestData(
                Constants.API_GET_OPZIONI_ABILITA,
                "GET",
                "",
                function (data) {
                    this.opzioni_abilita = data.result;
                    this.impostaOpzioniAbilita();
                }.bind(this)
            );
        },

        getStaffUsers: function () {
            if (this.permessoPNG) {
                Utils.requestData(
                    Constants.API_GET_STAFF_USERS,
                    "GET", {},
                    this.riempiElencoStaffer.bind(this)
                );
            }
        },

        riempiElencoStaffer: function (data) {
            var staffers = data.result,
                menu = $("select[name='giocatori_email_giocatore']");

            for (var s in staffers) {
                var selected = this.user_info.email_giocatore === staffers[s].email_giocatore ? "selected" : "";
                menu.append("<option value='" + staffers[s].email_giocatore + "' " + selected + ">" + staffers[s].nome_giocatore + "</option>");
            }
        },

        submitRedirect: function () {
            if (this.pg_info) {
                window.localStorage.setItem("pg_da_loggare", this.pg_info.id_personaggio);
                Utils.redirectTo(Constants.PG_PAGE);
            } else
                Utils.redirectTo(Constants.MAIN_PAGE);
            ì
        },

        inviaDati: function () {
            var vuoto = /^\s+$/,
                errori = "",
                opzioni_vals = $("#opzioni_abilita").find(".form-group:visible select:not([disabled])").toArray().map(function (e) { return $(e).val(); }),
                cc_selezionate = this.ms_classi_civili.datiSelezionati(),
                cm_selezionate = this.ms_classi_militari.datiSelezionati(),
                ac_selezionate = this.ms_abilita_civili.datiSelezionati(),
                am_selezionate = this.ms_abilita_militari.datiSelezionati();

            if (!this.pg_info) {
                if (!$("#nomePG").val() || ($("#nomePG").val() && vuoto.test($("#nomePG").val())))
                    errori += "<li>Il campo nome utente non pu&ograve; essere vuoto.</li>";
                if (!$("#etaPG").val() || ($("#etaPG").val() && (vuoto.test($("#etaPG").val()) || !/^\d+$/.test($("#etaPG").val()) || $("#etaPG").val() === "0")))
                    errori += "<li>Il campo et&agrave; non pu&ograve; essere vuoto o 0.</li>";
                if (cc_selezionate.length === 0 && !this.permessoPNG)
                    errori += "<li>Devi acquistare almeno una professione.</li>";
                if (cm_selezionate.length === 0 && !this.permessoPNG)
                    errori += "<li>Devi acquistare almeno un'abilit&agrave; civile.</li>";
                if (ac_selezionate.length === 0 && !this.permessoPNG)
                    errori += "<li>Devi acquistare almeno una classe militare.</li>";
                if (am_selezionate.length === 0 && !this.permessoPNG)
                    errori += "<li>Devi acquistare almeno un'abilit&agrave; militare.</li>";
            } else if (this.pg_info &&
                cc_selezionate.length === 0 &&
                cm_selezionate.length === 0 &&
                ac_selezionate.length === 0 &&
                am_selezionate.length === 0 &&
                !this.permessoPNG
            ) {
                errori += "<li>Devi acquistare almeno una classe o un'abilit&agrave;.</li>";
            }

            if (opzioni_vals.filter(function (e, i, ar) { return ar.lastIndexOf(e) !== i; }).length > 0)
                errori += "<li>Non &egrave; possibile selezionare due opzioni uguali per abilit&agrave; diverse.</li>";

            if (errori) {
                Utils.showError("Sono stati rilevati degli errori:<ul>" + errori + "</ul>");
                return false;
            }

            var classi = cc_selezionate.concat(cm_selezionate)
                .reduce(function (pre, curr) {
                    return pre + "classi[]=" + curr.id_classe + "&";
                }, "") || "classi=&",

                abilita = ac_selezionate.concat(am_selezionate)
                    .reduce(function (pre, curr) {
                        return pre + "abilita[]=" + curr.id_abilita + "&";
                    }, "") || "abilita=&",
                opzioni = $("#opzioni_abilita").find(".form-group:visible select:not([disabled])").serialize() || "opzioni=",
                nome = !this.pg_info ? "nome=" + encodeURIComponent($("#nomePG").val()) : "id_utente=" + this.pg_info.id_personaggio,
                eta = !this.pg_info ? "eta=" + $("#etaPG").val() + "&" : "",
                property = "giocatori_email_giocatore=" + $("[name='giocatori_email_giocatore']").val(),
                contatta = "contattabile_giocatore=" + ($("[name='contattabile_personaggio']").is(":checked") ? 1 : 0),
                data = nome + "&" + eta + classi + abilita + opzioni,
                url = this.pg_info ? Constants.API_POST_ACQUISTA : Constants.API_POST_CREAPG;

            if (this.permessoPNG)
                data += "&" + property + "&" + contatta;

            Utils.requestData(
                url,
                "POST",
                data,
                function () {
                    var message = "";

                    if (this.pg_info)
                        message = "Acquisti effettuati con successo.";
                    else
                        message = "La creazione è avvenuta con successo.<br>Potrai vedere il tuo nuovo personaggio nella sezione apposita.<br>È consigliato aggiungere un Background.";

                    $("#message").unbind("hidden.bs.modal");
                    $("#message").on("hidden.bs.modal", this.submitRedirect.bind(this));
                    Utils.showMessage(message);
                }.bind(this)
            );
        }
    };
}();

// eslint-disable-line no-console
$(function () {
    RegistrationManager.init();
});