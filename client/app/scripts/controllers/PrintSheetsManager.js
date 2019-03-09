var PrintSheetsManager = (function ()
{
    var CARTELLINI_PER_PAG = 6,
        ICONE = {
            "programmazione": "fa-qrcode",
            "tecnico": "fa-wrench",
            "chimico": "fa-flask"
        },
        BIOSTRUTTURE = ["cerotto", "fiala", "solido"],
        BIOSTRUTTURE_TEXT = {
            cerotto: "in cerotto",
            fiala: "in fiala",
            solido: "solida"
        },
        MAPPA_TIPI_RICETTE = {
            "Programma": "componente_consumabile",
            "Sostanza": "componente_consumabile",
            "Arma Mischia": "arma_equip",
            "Pistola": "arma_equip",
            "Fucile Assalto": "arma_equip",
            "Mitragliatore": "arma_equip",
            "Shotgun": "arma_equip",
            "Fucile Precisione": "arma_equip",
            "Gadget Normale": "arma_equip",
            "Gadget Avanzato": "arma_equip",
            "Protesi Generica": "armatura_protesi_potenziamento",
            "Protesi Braccio": "armatura_protesi_potenziamento",
            "Protesi Gamba": "armatura_protesi_potenziamento",
            "Esoscheletro": "armatura_protesi_potenziamento"
        };

    return {
        init: function ()
        {
            this.richieste_complete = {};
            this.dati_cartellini = { ricetta: [], schede_pg: [], componente_crafting: [] };
            this.qta_cartellini = {};

            for (var t in Constants.MAPPA_TIPI_CARTELLINI)
                this.dati_cartellini[t] = [];

            this.setListeners();
            this.recuperaInfoCartellini();
        },

        disegna_schede_pg: function (pg)
        {

            //TODO: font troppo grosso
            var cartellino = $(".cartellino.scheda-pg.template").clone(),
                note_cartellino = "NOTE: " + decodeURIComponent(pg.note_cartellino_personaggio).replace(/<br>/g, " ");

            cartellino.removeClass("template");

            cartellino.find(".giocatore").text(pg.nome_giocatore);
            cartellino.find(".pg-id").text(Utils.pad(pg.id_personaggio));
            cartellino.find(".pg-nome").text(pg.nome_personaggio);
            cartellino.find(".pg-anno").text(pg.anno_nascita_personaggio);
            cartellino.find(".pg-pf").text(Utils.pad(pg.pf_personaggio));
            cartellino.find(".pg-ps").text(Utils.pad(pg.shield_personaggio));
            cartellino.find(".pg-mente").text(Utils.pad(pg.mente_personaggio, 4));
            cartellino.find(".pg-pc").text(Utils.pad(pg.pc_risparmiati, 4) + "/" + Utils.pad(pg.pc_personaggio, 4));
            cartellino.find(".pg-px").text(Utils.pad(pg.px_risparmiati, 4) + "/" + Utils.pad(pg.px_personaggio, 4));
            cartellino.find(".note-pg").html(note_cartellino);
            cartellino.find(".lista-classi-civili").text(pg.classi_civili || "");
            cartellino.find(".lista-classi-militari").text(pg.classi_militari || "");
            cartellino.find(".lista-abilita-civili").text(pg.abilita_civili || "");
            cartellino.find(".lista-abilita-militari").text(pg.abilita_militari || "");
            cartellino.attr("id", null);

            new QRCode(cartellino.find(".qr-code")[0], {
                text: "PG-" + pg.id_personaggio,
                width: 75,
                height: 75,
                colorLight: "white",
                correctLevel: QRCode.CorrectLevel.H
            });

            return cartellino;

        },

        disegna_componente_consumabile: function (info)
        {
            return this.disegna_generico(info);
        },

        disegna_abilita_sp_malattia: function (info)
        {
            return this.disegna_generico(info);
        },

        disegna_armatura_protesi_potenziamento: function (info)
        {
            return this.disegna_generico(info);
        },

        disegna_arma_equip: function (info)
        {
            return this.disegna_generico(info);
        },

        disegna_interazione_area: function (info)
        {
            return this.disegna_generico(info);
        },

        disegna_generico: function (info)
        {
            var c = $(".cartellino.generico.template").clone();
            c.removeClass("template");

            if (info.icona_cartellino === null)
            {
                c.find(".icona_cartellino")
                    .parent()
                    .remove();
                c.find(".titolo_cartellino").height("80%");
            }
            else if (info.icona_cartellino !== null && info.titolo_cartellino.length > 15)
                c.find(".titolo_cartellino").css("font-size", "1em")

            for (var r in info)
            {
                if (c.find("." + r).length !== 0 && info[r] !== null)
                {
                    if (r === "icona_cartellino")
                        c.find("." + r).html(
                            "<i class='fa " + info[r] + "'></i>"
                        );
                    else
                        c.find("." + r).html(info[r]);
                }
            }

            return c;
        },

        inserisciPagina: function ()
        {
            pagina = $("#page_template").clone();
            pagina.attr("id", null);

            $("#container").append(pagina);
            $("#container").append("<div class='page-break'></div>");

            return pagina;
        },

        pulisciDatiCartellini: function ()
        {
            var chiavi = [];

            for (var d in this.dati_cartellini)
            {
                if (this.dati_cartellini[d].length > 0)
                    chiavi.push(d);
                else
                    delete this.dati_cartellini[d];
            }

            return chiavi;
        },

        disegnaCartellini: function ()
        {
            var num_cartellini = 0,
                pagina = null,
                chiavi = this.pulisciDatiCartellini();
            //TODO: PROBLEMAAAA

            for (var tipo in this.dati_cartellini)
            {
                for (var c in this.dati_cartellini[tipo])
                {
                    var cartellino = this.dati_cartellini[tipo][c];

                    if (!pagina || (num_cartellini % CARTELLINI_PER_PAG === 0 && pagina.children().size() !== 0))
                        pagina = this.inserisciPagina();

                    pagina.append(this["disegna_" + cartellino.tipo_cartellino](cartellino));

                    num_cartellini++;
                }

                if (chiavi.indexOf(tipo) < chiavi.length - 1)
                    pagina = this.inserisciPagina();
            }

            if (window.parent.stampa_subito)
                setTimeout(window.print, 1000);
        },

        controllaERiempi: function (tipo)
        {
            var num_completi = 0;
            this.richieste_complete[tipo] = true;

            //this.dati_cartellini[tipo] = (data.data || data.result).reduce(function (prev, el) { prev[el[id_name]] = el; return prev; }, {});

            for (var t in this.richieste_complete)
                if (this.richieste_complete[t])
                    num_completi++;

            if (num_completi === Object.keys(this.richieste_complete).length)
                this.disegnaCartellini();
        },

        recuperaInfo_schede_pg: function (ids)
        {
            Utils.requestData(
                Constants.API_GET_PGS_CON_ID,
                "GET", {
                    ids: ids
                },
                function (data)
                {
                    var schede = data.data.map(function (el) { el.tipo_cartellino = "schede_pg"; return el; });
                    this.dati_cartellini.schede_pg = schede;
                    this.controllaERiempi("schede_pg")
                }.bind(this)
            );
        },

        recuperaInfo_ricetta: function (ids)
        {
            Utils.requestData(
                Constants.API_GET_RICETTE_CON_ID,
                "GET",
                { ids: ids },
                function (data)
                {
                    var data_mapped = data.result.map(function (el) 
                    {

                        var tipo = MAPPA_TIPI_RICETTE[el.tipo_oggetto],
                            id_risultato = el.id_unico_risultato_ricetta ? Utils.pad(el.id_unico_risultato_ricetta, 4) + "<br><br>" : "",
                            ret = {
                                id_cartellino: el.id_ricetta,
                                tipo_cartellino: tipo,
                                titolo_cartellino: el.nome_ricetta,
                                descrizione_cartellino: id_risultato + el.risultato_ricetta.replace(/;/g, "<br>"),
                                icona_cartellino: ICONE[el.tipo_ricetta.toLowerCase()],
                                testata_cartellino: Utils.pad(el.id_ricetta, 4),
                                piepagina_cartellino: "Tipologia: " + el.tipo_oggetto
                            };

                        if (el.biostruttura_sostanza)
                            ret.piepagina_cartellino += " " + BIOSTRUTTURE_TEXT[el.biostruttura_sostanza];

                        if (el.tipo_oggetto.toLowerCase().indexOf("protesi") !== -1)
                            ret.descrizione_cartellino += "<br><br>FCC: " + el.fcc_componente;

                        return ret;
                    });

                    for (var d in data_mapped)
                    {
                        var qta = this.qta_cartellini.ricetta[data_mapped[d].id_cartellino];

                        this.dati_cartellini[data_mapped[d].tipo_cartellino] =
                            this.dati_cartellini[data_mapped[d].tipo_cartellino].concat(Array(qta).fill(data_mapped[d]));
                    }

                    this.controllaERiempi("ricetta");
                }.bind(this)
            );
        },

        recuperaInfo_componente_crafting: function (ids)
        {
            Utils.requestData(
                Constants.API_GET_COMPONENTI_CON_ID,
                "GET",
                { ids: ids },
                function (data)
                {
                    var data_mapped = data.result.map(function (el) 
                    {
                        var ret = {
                            id_cartellino: el.id_componente,
                            tipo_cartellino: "componente_consumabile",
                            titolo_cartellino: el.nome_componente,
                            descrizione_cartellino: "",
                            icona_cartellino: ICONE[el.tipo_crafting_componente.toLowerCase()],
                            testata_cartellino: "" + el.id_componente,
                            piepagina_cartellino: "Tipologia: " + el.tipo_componente
                        };

                        if (el.tipo_crafting_componente === "tecnico")
                        {
                            ret.descrizione_cartellino = (el.descrizione_componente + "<br><br><br>" +
                                "Volume:   " + el.volume_componente + "<br><br>" +
                                "Energia:  " + el.energia_componente).replace(/\s/g, "&nbsp;");;
                        }
                        else if (el.tipo_crafting_componente === "chimico" && el.tipo_componente !== "sostanza")
                        {
                            ret.titolo_cartellino = ret.titolo_cartellino.toUpperCase();
                            ret.descrizione_cartellino = el.descrizione_componente;
                        }
                        else if (el.tipo_crafting_componente === "chimico" && el.tipo_componente === "sostanza")
                        {
                            var tabella =
                                "             Primario  Secondario<br><br>" +
                                "Curativo:    x         yyy<br><br>" +
                                "Tossico:     z         qqq<br><br>" +
                                "Psicotropo:  w         kkk<br><br>" +
                                "FATTORE DIPENDENZA:  #";

                            tabella = tabella
                                .replace("x", el.curativo_primario_componente)
                                .replace("yyy", el.curativo_secondario_componente)
                                .replace("z", el.tossico_primario_componente)
                                .replace("qqq", el.tossico_secondario_componente)
                                .replace("w", el.psicotropo_primario_componente)
                                .replace("kkk", el.psicotropo_secondario_componente)
                                .replace("#", el.possibilita_dipendeza_componente)
                                .replace(/\s/g, "&nbsp;");

                            ret.titolo_cartellino = ret.titolo_cartellino.toUpperCase();
                            ret.descrizione_cartellino = el.descrizione_componente + "<br><br>" + tabella;
                        }

                        return ret;
                    });

                    for (var d in data_mapped)
                    {
                        var qta = this.qta_cartellini.componente_crafting[data_mapped[d].id_cartellino];
                        this.dati_cartellini.componente_consumabile =
                            this.dati_cartellini.componente_consumabile.concat(Array(qta).fill(data_mapped[d]));
                    }

                    this.controllaERiempi("componente_crafting");
                }.bind(this)
            );
        },

        recuperaInfo_componente_consumabile: function (ids)
        {
            this.recuperaInfo_generico(ids, "componente_consumabile");
        },

        recuperaInfo_abilita_sp_malattia: function (ids)
        {
            this.recuperaInfo_generico(ids, "abilita_sp_malattia");
        },

        recuperaInfo_armatura_protesi_potenziamento: function (ids)
        {
            this.recuperaInfo_generico(ids, "armatura_protesi_potenziamento");
        },

        recuperaInfo_arma_equip: function (ids)
        {
            this.recuperaInfo_generico(ids, "arma_equip");
        },

        recuperaInfo_interazione_area: function (ids)
        {
            this.recuperaInfo_generico(ids, "interazione_area");
        },

        recuperaInfo_generico: function (ids, tipo)
        {
            Utils.requestData(
                Constants.API_GET_CARTELLINI_CON_ID,
                "GET", {
                    ids: ids
                },
                function (data)
                {
                    for (var d in data)
                    {
                        var qta = this.qta_cartellini[tipo][data[d].id_cartellino];
                        this.dati_cartellini[tipo] = this.dati_cartellini[tipo].concat(Array(qta).fill(data[d]));
                    }
                    this.controllaERiempi(tipo);
                }.bind(this)
            );
        },

        recuperaInfoCartellini: function ()
        {
            if (window.localStorage.getItem("cartellini_da_stampare"))
            {
                this.qta_cartellini = JSON.parse(window.localStorage.getItem("cartellini_da_stampare"));

                for (var c in this.qta_cartellini)
                {
                    if (Object.keys(this.qta_cartellini[c]).length > 0)
                    {
                        this.richieste_complete[c] = false;
                        this["recuperaInfo_" + c](Object.keys(this.qta_cartellini[c]));
                    }
                }
            }
        },

        setListeners: function () { }
    };
})();
$(function ()
{
    PrintSheetsManager.init();
});
