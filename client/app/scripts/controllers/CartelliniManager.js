var CartelliniManager = (function ()
{
    return {
        init: function ()
        {
            this.cartellini_selezionati = {};
            this.tabella_cartellini = {};

            for (var t in Constants.MAPPA_TIPI_CARTELLINI)
                this.cartellini_selezionati[t] = {};

            this.setListeners();
            this.impostaTabella();
        },

        resettaContatori: function (e)
        {
            for (var c in this.cartellini_selezionati)
                this.cartellini_selezionati[c] = {};

            window.localStorage.removeItem("cartellini_da_stampare");
            this.tabella_cartellini.find("input[type='number']").val(0);
        },

        stampaCartellini: function (e)
        {
            var cartellini = this.cartellini_selezionati;

            if (Object.keys(cartellini).length === 0)
            {
                Utils.showError(
                    "Non è stato selezionato nessun cartellino da stampare."
                );
                return false;
            }

            window.localStorage.removeItem("cartellini_da_stampare");
            window.localStorage.setItem("cartellini_da_stampare", JSON.stringify(cartellini));
            window.open(Constants.STAMPA_CARTELLINI_PAGE, "Stampa Cartellini");
        },

        cartellinoSelezionato: function (e)
        {
            var t = $(e.target),
                num = parseInt(t.val(), 10),
                dati = this.tabella_cartellini.row(t.parents("tr")).data();

            console.log(dati.tipo_cartellino);

            if (num > 0)
                this.cartellini_selezionati[dati.tipo_cartellino][dati.id_cartellino] = num;
            else
                delete this.cartellini_selezionati[dati.tipo_cartellino][dati.id_cartellino];
        },

        selezionaCartellino: function (e)
        {
            $("input[type='number']").val(0);

            for (var t in this.cartellini_selezionati)
                for (var c in this.cartellini_selezionati[t])
                    $("#ck_" + c).val(this.cartellini_selezionati[t][c]);
        },

        renderAzioni: function (data, type, row)
        {
            var pulsanti = "";

            pulsanti +=
                "<button type='button' " +
                "class='btn btn-xs btn-default modifica' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Modifica Cartellino'><i class='fa fa-pencil'></i></button>";

            pulsanti +=
                "<button type='button' " +
                "class='btn btn-xs btn-default elimina' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Elimina Cartellino'><i class='fa fa-trash-o'></i></button>";

            return pulsanti;
        },

        renderCheckStampa: function (data, type, row)
        {
            return (
                '<div class="input-group">' +
                "<input type='number' min='0' step='1' value='0' class='form-control' style='width:70px' id='ck_" +
                row.id_cartellino +
                "'>" +
                "</div>"
            );
        },

        renderCosto: function (data, type, row)
        {
            var testo = !isNaN(parseInt(data)) ? data : "Non acquistabile";
            return testo;
        },

        renderSiNo: function (data, type, row)
        {
            var testo = parseInt(data, 10) === 1 ? "S&igrave;" : "No";
            return testo;
        },

        renderTipo: function (data, type, row)
        {
            return Constants.MAPPA_TIPI_CARTELLINI[data].nome;
        },

        renderCartellino: function (data, type, row)
        {
            var c = $("#cartellino_template").clone();
            c.attr("id", null);
            c.removeClass("template");

            if (row.icona_cartellino === null)
            {
                c.find(".icona_cartellino")
                    .parent()
                    .remove();
                c.find(".titolo_cartellino").height("80%");
            }

            for (var r in row)
            {
                if (c.find("." + r).length !== 0 && row[r] !== null)
                {
                    if (r === "icona_cartellino")
                        c.find("." + r).html(
                            "<i class='fa " + row[r] + "'></i>"
                        );
                    else c.find("." + r).text(row[r]);
                }
            }

            return c[0].outerHTML;
        },

        eliminaCartellino: function (id)
        {
            Utils.requestData(
                Constants.API_POST_DEL_CARTELLINO,
                "POST",
                { id: id },
                "Cartellino eliminato con successo.",
                null,
                this.tabella_cartellini.ajax.reload.bind(this, null, false)
            );
        },

        mostraConfermaElimina: function (e)
        {
            var t = $(e.currentTarget),
                dati = this.tabella_cartellini.row(t.parents("tr")).data();

            Utils.showConfirm(
                "Sicuro di voler eliminare il cartellino <strong>" +
                dati.titolo_cartellino +
                "</strong>?",
                this.eliminaCartellino.bind(this, dati.id_cartellino),
                true
            );
        },

        mostraModalModifica: function (e)
        {
            var t = $(e.currentTarget),
                dati = this.tabella_cartellini.row(t.parents("tr")).data();

            CartelliniCreator.mostraModalFormCartellino(dati);
        },

        setGridListeners: function ()
        {
            AdminLTEManager.controllaPermessi();

            $("td [data-toggle='popover']").popover("destroy");
            $("td [data-toggle='popover']").popover();

            $("[data-toggle='tooltip']").tooltip("destroy");
            $("[data-toggle='tooltip']").tooltip();

            $("td > button.modifica").unbind("click");
            $("td > button.modifica").click(
                this.mostraModalModifica.bind(this)
            );

            $("td > button.elimina").unbind("click");
            $("td > button.elimina").click(
                this.mostraConfermaElimina.bind(this)
            );

            $("td > button.stampa-cartellino").unbind(
                "click",
                this.stampaCartellini.bind(this)
            );
            $("td > button.stampa-cartellino").click(
                this.stampaCartellini.bind(this)
            );

            $('input[type="number"]').unbind("change");
            $('input[type="number"]').on(
                "change",
                this.cartellinoSelezionato.bind(this)
            );

            this.selezionaCartellino();
        },

        erroreDataTable: function (e, settings)
        {
            if (!settings.jqXHR || !settings.jqXHR.responseText)
            {
                console.log("DataTable error:", e, settings);
                return false;
            }

            var real_error = settings.jqXHR.responseText.replace(
                /^([\S\s]*?)\{"[\S\s]*/i,
                "$1"
            );
            real_error = real_error.replace("\n", "<br>");
            Utils.showError(real_error);
        },

        impostaTabella: function ()
        {
            var columns = [];

            columns.push({
                title: "Stampa",
                render: this.renderCheckStampa.bind(this)
            });
            columns.push({
                title: "ID",
                data: "id_cartellino"
            });
            columns.push({
                title: "Cartellino",
                render: this.renderCartellino.bind(this),
                orderable: false
            });
            columns.push({
                title: "Data Creazione",
                data: "data_creazione_cartellino"
            });
            columns.push({
                title: "Tipo",
                data: "tipo_cartellino",
                render: this.renderTipo.bind(this)
            });
            columns.push({
                title: "Costo",
                data: "costo_attuale_ravshop_cartellino",
                render: this.renderCosto.bind(this)
            });
            columns.push({
                title: "Approvato",
                data: "approvato_cartellino",
                render: this.renderSiNo.bind(this)
            });
            columns.push({
                title: "Azioni",
                render: this.renderAzioni.bind(this),
                orderable: false
            });

            this.tabella_cartellini = $("#tabella_cartellini")
                .on("error.dt", this.erroreDataTable.bind(this))
                .on("draw.dt", this.setGridListeners.bind(this))
                .DataTable({
                    processing: true,
                    serverSide: true,
                    dom:
                        "<'row'<'col-sm-6'lB><'col-sm-6'f>>" +
                        "<'row'<'col-sm-12 table-responsive'tr>>" +
                        "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                    buttons: ["reload"],
                    language: Constants.DATA_TABLE_LANGUAGE,
                    ajax: function (data, callback)
                    {
                        var campi_nascosti = [
                            "titolo_cartellino",
                            "testata_cartellino",
                            "piepagina_cartellino",
                            "descrizione_cartellino",
                            "icona_cartellino",
                            "nome_modello_cartellino"
                        ];
                        for (var c in campi_nascosti)
                            data.columns.push({
                                data: campi_nascosti[c],
                                name: "",
                                searchable: true,
                                orderable: false,
                                search: { regex: false, value: "" }
                            });

                        Utils.requestData(
                            Constants.API_GET_CARTELLINI,
                            "GET",
                            data,
                            callback
                        );
                    },
                    columns: columns,
                    order: [[1, "desc"]]
                });
        },

        setListeners: function ()
        {
            $("#btn_stampaCartellini").click(this.stampaCartellini.bind(this));
            $("#btn_resettaContatori").click(this.resettaContatori.bind(this));
        }
    };
})();

$(function ()
{
    CartelliniManager.init();
});
