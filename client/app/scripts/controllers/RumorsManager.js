/**
 * Created by Miroku on 11/03/2018.
 */
var RumorsManager = function() {
    return {
        init: function() {
            this.setListeners();
            this.impostaTabellaRumors();
            this.recuperaEventi();
        },

        controlloCampi: function(data) {
            var errors = [];

            if (data.is_bozza) {
                if (data.luogo_ig == "" && data.testo == "" && data.data_ig == "") {
                    errors.push("Per salvare una bozza compilare almeno il Luogo In Gioco, la Data In Gioco o il testo del rumor.");
                }
            } else {
                if (data.luogo_ig == "") {
                    errors.push("Campo Luogo In Gioco obbligatorio");
                }

                if (data.testo == "") {
                    errors.push("Campo Testo Rumor obbligatorio");
                }

                if (data.data_ig == "") {
                    errors.push("Campo Data In Gioco obbligatorio");
                }

                if (data.data_pubblicazione == "") {
                    errors.push("Campo Data Pubblicazione obbligatorio");
                }

                if (data.ora_pubblicazione == "") {
                    errors.push("Campo Ora Pubblicazione obbligatorio");
                }

                if (!data.eventi_id_evento || parseInt(data.eventi_id_evento) === -1) {
                    errors.push("Campo Live del Rumor obbligatorio");
                }

                if (data.data_pubblicazione !== "" && data.ora_pubblicazione !== "") {
                    var dataSplit = data.data_pubblicazione.split("/");
                    var ora_pubb = data.ora_pubblicazione.split(":").length > 2 ? data.ora_pubblicazione : data.ora_pubblicazione + ":00";
                    var dataPubb = new Date(Date.parse(dataSplit[2] + "-" + dataSplit[1] + "-" + dataSplit[0] + "T" + ora_pubb + ".000"));
                    console.log(dataSplit[2] + "-" + dataSplit[1] + "-" + dataSplit[0] + "T" + ora_pubb + ".000");

                    if (new Date() > dataPubb) {
                        errors.push("La data di pubblicazione deve essere nel futuro.");
                    }
                }
            }

            return errors;
        },

        invioCompletato: function(modal) {
            modal.modal("hide");
            this.tabella_rumors.ajax.reload(null, false);
            Utils.resetSubmitBtn();
        },

        inviaDati: function(is_bozza, e) {
            var modal = $("#modal_rumor"),
                form = modal.find("form"),
                formData = Utils.getFormData(form, true),
                modifica = modal.hasClass("modifica"),
                url = Constants.API_PUT_RUMORS,
                data = {};

            if (modifica) {
                url = Constants.API_POST_RUMORS;
                data.id = formData.id
            }

            data.luogo_ig = encodeURIComponent(formData.luogo_ig || "");
            data.testo = encodeURIComponent(formData.testo || "");
            data.data_ig = encodeURIComponent(formData.data_ig || "");
            data.data_pubblicazione = formData.data_pubblicazione || "";
            data.ora_pubblicazione = formData.ora_pubblicazione || "";
            data.is_bozza = is_bozza;

            if (parseInt(formData.eventi_id_evento) !== -1)
                data.eventi_id_evento = parseInt(formData.eventi_id_evento)

            var errors = this.controlloCampi(data);
            if (errors.length > 0) {
                Utils.showError(
                    "Sono stati riscontrati i seguenti errori:<ul><li>" + errors.join("</li><li>") + "</li></ul>",
                    null,
                    false,
                )

                return;
            }

            Utils.requestData(
                url,
                "POST",
                data,
                "Dati inviati con successo",
                null,
                this.invioCompletato.bind(this, modal)
            );
        },

        eliminaRumor: function(id_rumor) {
            Utils.requestData(
                Constants.API_DEL_RUMORS,
                "POST", { id: id_rumor },
                "Componente eliminato con successo.",
                null,
                this.invioCompletato.bind(this, $("#modal_rumor"))
            );
        },

        mostraConfermaElimina: function(e) {
            var t = $(e.currentTarget),
                dati = this.tabella_rumors.row(t.parents("tr")).data();

            Utils.showConfirm(
                "Sicuro di voler eliminare il rumor con id <strong>" + dati.id_rumor + "</strong>?<br>",
                this.eliminaRumor.bind(this, dati.id_rumor),
                true
            );
        },

        recuperaEventi: function() {
            Utils.requestData(
                Constants.API_GET_LISTA_EVENTI,
                "GET", {
                    draw: 0,
                    columns: [{ data: "id_evento" }],
                    order: [{ column: 0, dir: "desc" }],
                    start: 0,
                    length: 999,
                    search: null
                },
                this.renderMenuEvento.bind(this)
            );
        },

        mostraTimePicker: function() {
            $(this).timepicker('showWidget');
        },

        mostraModalRumor: function(modal_class, e) {
            var t = $(e.currentTarget),
                dati = this.tabella_rumors.row(t.parents("tr")).data(),
                modal = $("#modal_rumor");

            modal.find("form")[0].reset();

            if (dati) {
                for (var d in dati) {
                    if (typeof dati[d] !== "string")
                        continue;

                    if ($("#" + d).is("input[type='checkbox']")) {
                        $("#" + d).iCheck(parseInt(dati[d]) === 1 ? "check" : "uncheck");
                    } else {
                        $("#" + d).val(decodeURIComponent(dati[d]));
                    }
                }
            }


            modal.removeClass("nuovo");
            modal.removeClass("modifica");
            modal.removeClass("visualizza");
            modal.addClass(modal_class);
            modal.modal("show");
        },

        renderMenuEvento: function(resp) {
            var menu = $("#eventi_id_evento");
            var option = {};
            var eventi = resp.data;

            for (var e in eventi) {
                if (typeof eventi[e] !== "object")
                    continue;

                option = $("<option></option>");
                option.text(eventi[e].titolo_evento);
                option.val(eventi[e].id_evento);
                menu.append(option);
            }
        },

        renderCheckbox: function(data) {
            var checked = data === "1" ? "checked" : "";
            return "<div class='checkbox icheck'>" +
                "<input type='checkbox' " +
                "" + checked + " disabled>" +
                "</div>";
        },

        renderURIEncodedText: function(data) {
            return decodeURIComponent(data);
        },

        renderAzioni: function(data, type, row) {
            var dataPubb = new Date(Date.parse(row.data_pubb_formattata + "T" + row.ora_pubblicazione_rumor + ".000"));
            var enabled = new Date() > dataPubb && parseInt(row.is_bozza_rumor) === 0 ? "disabled" : "";

            var pulsanti = "";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default mostra' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Mostra Rumor'><i class='fa fa-eye'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default modifica' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Modifica Rumor' " + enabled + "><i class='fa fa-pencil'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default elimina' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Elimina Rumor' " + enabled + "><i class='fa fa-trash-o'></i></button>";

            return pulsanti;
        },

        setGridListeners: function() {
            AdminLTEManager.controllaPermessi();

            $('input[type="checkbox"]').iCheck("destroy");
            $('input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });

            $('td button.modifica').click(this.mostraModalRumor.bind(this, "modifica"));
            $('td button.mostra').click(this.mostraModalRumor.bind(this, "visualizza"));
            $('td button.elimina').click(this.mostraConfermaElimina.bind(this));
        },

        erroreDataTable: function(e, settings) {
            if (!settings.jqXHR || !settings.jqXHR.responseText) {
                console.log("DataTable error:", e, settings);
                return false;
            }

            var real_error = settings.jqXHR.responseText.replace(/^([\S\s]*?)\{"[\S\s]*/i, "$1");
            real_error = real_error.replace("\n", "<br>");
            Utils.showError(real_error);
        },

        impostaTabellaRumors: function() {
            var columns = [],
                id = "tabella_rumors";

            columns.push({
                title: "ID",
                data: "id_rumor",
            });
            columns.push({
                title: "Live",
                data: "titolo_evento"
            });
            columns.push({
                title: "Creatore",
                data: "nome_completo"
            });
            columns.push({
                title: "Luogo IG",
                data: "luogo_ig_rumor",
                render: this.renderURIEncodedText.bind(this)
            });
            columns.push({
                title: "Data Pubblicazione",
                data: "data_pubb_formattata"
            });
            columns.push({
                title: "Ora Pubblicazione",
                data: "ora_pubblicazione_rumor",
            });
            columns.push({
                title: "Bozza",
                data: "is_bozza_rumor",
                width: "5%",
                render: this.renderCheckbox.bind(this)
            });
            columns.push({
                title: "Azioni",
                render: this.renderAzioni.bind(this),
                orderable: false
            });

            this.tabella_rumors = $('#' + id)
                .on("error.dt", this.erroreDataTable.bind(this))
                .on("draw.dt", this.setGridListeners.bind(this))
                .DataTable({
                    ajax: function(data, callback) {
                        Utils.requestData(
                            Constants.API_GET_RUMORS,
                            "GET",
                            data,
                            callback
                        );
                    },
                    columns: columns,
                    rowId: function(data) {
                        return 'r_' + data.id_rumor;
                    },
                    order: [
                        [0, 'desc']
                    ]
                });
        },

        setListeners: function() {
            $('.icheck input[type="checkbox"]').iCheck("destroy");
            $('.icheck input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });

            $('[data-provide="timepicker"]').focus(this.mostraTimePicker);

            $("#btn_invia_bozza_rumor").click(this.inviaDati.bind(this, true));
            $("#btn_invia_dati_rumor").click(this.inviaDati.bind(this, false));
            $("#btn_inserisciRumor").click(this.mostraModalRumor.bind(this, "nuovo"));
        }
    };
}();

$(function() {
    RumorsManager.init();
});