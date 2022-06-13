/**
 * Created by Miroku on 11/03/2018.
 */
var ComponentsManager = function() {
    var SEPARATORE = "££";

    return {
        init: function() {
            this.abilita_selezionati = {};
            this.abilita_da_modificare = {}

            this.setListeners();
            this.impostaTabellaAbilita();
        },

        resettaContatori: function(e) {
            var t = $(e.currentTarget),
                table_id = t.parents(".box-body").find("table").attr("id");

            this.abilita_selezionati[table_id] = {};
            window.localStorage.removeItem("abilita_da_stampare");

            $("#" + table_id).find("input[type='number']").val(0);
        },

        resettaBulkEdit: function(e) {
            var t = $(e.currentTarget),
                table_id = t.parents(".box-body").find("table").attr("id");

            this.abilita_da_modificare[table_id] = {};

            $("#" + table_id).find(".icheck").iCheck("uncheck");
        },

        apriBulkEdit: function(e) {
            var t = $(e.currentTarget),
                table_id = t.parents(".box-body").find("table").attr("id"),
                numDaMod = 0,
                stessoTipo = true,
                primoID = Object.keys(this.abilita_da_modificare[table_id])[0],
                primoComp = this.abilita_da_modificare[table_id][primoID];

            for (var compID in this.abilita_da_modificare[table_id]) {
                numDaMod++

                if (primoComp.tipo_abilita !== this.abilita_da_modificare[table_id][compID].tipo_abilita)
                    stessoTipo = false
            }

            if (numDaMod > 1 && stessoTipo)
                this.mostraModalModifica(e, true);
            else if (numDaMod < 2)
                Utils.showMessage("Bisogna spuntare almeno 2 componenti.");
            else if (!stessoTipo)
                Utils.showMessage("Non puoi spuntare componenti di tipo diverso.");
        },

        creaComponente: function(tipo, e) {
            var t = $(e.currentTarget),
                table_id = t.parents(".box-body").find("table").attr("id"),
                datatable = this[table_id],
                dati = datatable.row(t.parents("tr")).data(),
                modal = $("#modal_modifica_abilita_" + table_id);

            modal.find("form").addClass("new-component");
            modal.modal("show");
        },

        componenteSelezionato: function(e) {
            var t = $(e.target),
                num = parseInt(t.val(), 10),
                table_id = t.parents("table").attr("id"),
                datatable = this[table_id],
                dati = datatable.row(t.parents("tr")).data();

            if (num > 0)
                this.abilita_selezionati[table_id][dati.id_abilita] = num;
            else
                delete this.abilita_selezionati[table_id][dati.id_abilita];
        },

        selezionaComponente: function(e) {
            $("input[type='number']").val(0);

            for (var t in this.abilita_selezionati)
                for (var c in this.abilita_selezionati[t])
                    $("#ck_" + c).val(this.abilita_selezionati[t][c]);
        },

        renderTipoApp: function(data) {
            if (data !== null)
                return data.replaceAll(",", ", ")
            else
                return data
        },

        renderAzioni: function() {
            var pulsanti = "";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default modifica' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Modifica Componente'><i class='fa fa-pencil'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default elimina' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Elimina Componente'><i class='fa fa-trash-o'></i></button>";

            return pulsanti;
        },

        renderCheckStampa: function(data, type, row) {
            return "<div class=\"input-group\">" +
                "<input type='number' min='0' step='1' value='0' class='form-control' style='width:70px' id='ck_" + row.id_abilita + "'>" +
                "</div>";
        },

        controllaErroriForm: function(form_obj) {
            var errori = [],
                is_bulk_edit = form_obj.bulk_edit === "true";

            if (form_obj.id_abilita === "" && !is_bulk_edit)
                errori.push("L'ID del componente non pu&ograve; essere vuoto.");
            if (form_obj.nome_abilita === "" && !is_bulk_edit)
                errori.push("Il nome del componente non pu&ograve; essere vuoto.");

            if (errori.length > 0)
                Utils.showError("Sono stati trovati errori durante l'invio dei dati del componente:<br><ol><li>" + errori.join("</li><li>") + "</li></ol>", null, false);

            return errori.length > 0;
        },

        componenteModificato: function(modal, tabella) {
            modal.modal("hide");
            tabella.ajax.reload(null, false);
            Utils.resetSubmitBtn();
        },

        inviaNuovoComponente: function(data, modal, table_id) {
            var tosend = data;

            tosend.tipo_crafting_abilita = table_id.replace("tabella_", "");

            if (tosend.tipo_applicativo_abilita instanceof Array)
                tosend.tipo_applicativo_abilita = tosend.tipo_applicativo_abilita.join(",");

            delete tosend.old_id
            delete tosend.bulk_edit

            Utils.requestData(
                Constants.API_POST_NUOVO_abilita,
                "POST", { params: tosend },
                "Componente inserito con successo.",
                null,
                this.componenteModificato.bind(this, modal, this[table_id])
            );
        },

        inviaModificheComponente: function(data, modal, table_id) {
            var id = data.old_id,
                url = Constants.API_POST_EDIT_COMPONENT,
                msg = "Componente modificato con successo.",
                dati = this.abilita_da_modificare[table_id];

            if (data.bulk_edit === "true" && Object.keys(dati).length > 0) {
                id = Object.keys(dati).map(function(id) { return id + SEPARATORE + dati[id].nome_abilita });
                url = Constants.API_POST_BULK_EDIT_COMPONENTS;
                comps = Object.keys(dati).map(
                    function(id) {
                        return dati[id].nome_abilita + " (" + id + ")";
                    }
                );

                msg = "I seguenti componenti sono stati modificati con successo:<br>" + comps.join(", ")

                delete data.bulk_edit
                delete data.id_abilita
                delete data.nome_abilita
                delete data.descrizione_abilita
            }

            delete data.old_id
            delete data.bulk_edit

            Utils.requestData(
                url,
                "POST", { id: id, modifiche: data },
                msg,
                null,
                this.componenteModificato.bind(this, modal, this[table_id])
            );
        },

        inviaDati: function(e) {
            var t = $(e.currentTarget),
                modal = t.parents(".modal"),
                table_id = modal.attr("id").replace("modal_modifica_abilita_", ""),
                form = t.parents(".modal").find("form"),
                data = Utils.getFormData(form, true),
                isNew = form.hasClass("new-component");

            if (this.controllaErroriForm(data))
                return false;

            if (isNew)
                this.inviaNuovoComponente(data, modal, table_id)
            else
                this.inviaModificheComponente(data, modal, table_id)
        },

        recuperaListaCompSpuntati: function(table_id) {
            return Object.keys(this.abilita_da_modificare[table_id]).map(
                function(id) {
                    return this.abilita_da_modificare[table_id][id].nome_abilita + " (" + id + "), ";
                }.bind(this)).join(", ");
        },

        recuperaIDCompSpuntati: function(table_id, prefix) {
            return Object.keys(this.abilita_da_modificare[table_id]).map(
                function(id) {
                    return prefix + id
                });
        },

        onModalHide: function(e) {
            var modal = $(e.target);
        },

        riempiCampiModifica: function(modal, dati) {
            modal.find("input[name='old_id']").val(dati.id_abilita)

            for (var d in dati) {

            }
        },

        riempiCampiModificaDiGruppo: function(modal, dati) {
            var primoID = Object.keys(dati)[0],
                valUguali = JSON.parse(JSON.stringify(dati[primoID]));

            for (var campo in valUguali) {
                var primo = dati[primoID][campo],
                    tuttiUguali = true;

                for (var d in dati) {
                    if (dati[d][campo] !== primo) {
                        tuttiUguali = false;
                        break;
                    }
                }

                if (tuttiUguali)
                    valUguali[campo] = primo;
                else
                    valUguali[campo] = "";
            }

            this.riempiCampiModifica(modal, valUguali);
        },

        mostraModalModifica: function(e, bulk_edit) {
            var t = $(e.target),
                table_id = t.parents(".box-body").find("table").attr("id"),
                datatable = this[table_id],
                modal = $("#modal_modifica_abilita_" + table_id),
                bulk_edit = typeof bulk_edit !== "undefined" ? bulk_edit === true : false;

            modal.find("form").addClass("edit-component");

            if (bulk_edit) {
                modal.find("[name='id_abilita']").parents(".form-group").hide();
                modal.find("[name='nome_abilita']").parents(".form-group").hide();
                modal.find("[name='descrizione_abilita']").parents(".form-group").hide();
                modal.find(".bulk-edit-msg .lista-componenti").text(this.recuperaListaCompSpuntati(table_id))
                modal.find(".bulk-edit-msg").show();
                modal.find("input[name='bulk_edit']").val("true")

                this.riempiCampiModificaDiGruppo(modal, this.abilita_da_modificare[table_id])
            } else {
                var dati = datatable.row(t.parents("tr")).data();
                this.riempiCampiModifica(modal, dati)
            }

            $("#modal_modifica_abilita_tabella_tecnico").find("[name='tipo_abilita']").trigger("change");
            modal.modal("show");
        },

        eliminaComponente: function(id_comp, modal, table_id) {
            Utils.requestData(
                Constants.API_POST_REMOVE_COMPONENT,
                "POST", { id: id_comp },
                "Componente eliminato con successo.",
                null,
                this.componenteModificato.bind(this, modal, this[table_id])
            );
        },

        mostraConfermaElimina: function(e) {
            var t = $(e.currentTarget),
                modal = t.parents(".modal"),
                table_id = t.parents("table").attr("id"),
                datatable = this[table_id],
                dati = datatable.row(t.parents("tr")).data();

            Utils.showConfirm("Sicuro di voler eliminare il componente <strong>" + dati.id_abilita + "</strong>?<br>" +
                "ATTENZIONE:<br>Ogni ricetta che contiene questo componente verr&agrave; eliminata a sua volta.", this.eliminaComponente.bind(this, dati.id_abilita, modal, table_id), true);
        },

        mostraChildRow: function(e) {
            var tr = $(e.currentTarget).closest('tr');
            var row = this.tabella_abilita.row(tr);
            console.log(row.data());

            if (row.child.isShown()) {
                // This row is already open - close it
                row.child.hide();
                tr.removeClass('shown');
            } else {
                // Open this row
                row.child(row.data().descrizione_abilita).show();
                tr.addClass('shown');
            }
        },

        salvaComponenteDaModificare: function(e) {
            var t = $(e.currentTarget),
                table_id = t.parents("table").attr("id"),
                datatable = this[table_id],
                dati = datatable.row(t.parents("tr")).data(),
                key = dati.id_abilita; // + SEPARATORE + dati.nome_abilita;

            if (t.is(":checked"))
                this.abilita_da_modificare[table_id][key] = dati
            else {
                if (typeof this.abilita_da_modificare[table_id][key] !== "undefined")
                    delete this.abilita_da_modificare[table_id][key]
            }
        },

        creaCheckBoxBulkEdit: function(data, type, row, meta) {
            var table_id = meta.settings.sTableId,
                checked = typeof this.abilita_da_modificare[table_id][row.id_abilita] !== "undefined" ? "checked" : "";

            return "<div class='checkbox icheck'>" +
                "<input type='checkbox' " +
                "class='modificaComponente' " +
                checked + ">" +
                "</div>";
        },

        creaExpandButton: function(data, type, row, meta) {
            return "<span class=\"expand-bt\">" + data + " <li class=\"fa fa-angle-down\"></span>";
        },

        setGridListeners: function() {
            AdminLTEManager.controllaPermessi();

            $('td > .expand-bt').click(this.mostraChildRow.bind(this));

            /*$('input[type="checkbox"]').iCheck("destroy");
            $('input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });

            $("td input.modificaComponente").unbind("ifChanged", this.salvaComponenteDaModificare.bind(this));
            $("td input.modificaComponente").on("ifChanged", this.salvaComponenteDaModificare.bind(this));

            $("td [data-toggle='popover']").popover("destroy");
            $("td [data-toggle='popover']").popover();

            $("[data-toggle='tooltip']").tooltip("destroy");
            $("[data-toggle='tooltip']").tooltip();

            $("td > button.modifica").unbind("click");
            $("td > button.modifica").click(this.mostraModalModifica.bind(this));

            $("td > button.elimina").unbind("click");
            $("td > button.elimina").click(this.mostraConfermaElimina.bind(this));

            $("td > button.stampa-cartellino").unbind("click", this.stampaCartellini.bind(this));
            $("td > button.stampa-cartellino").click(this.stampaCartellini.bind(this));

            $('td > input[type="number"]').unbind("change");
            $('td > input[type="number"]').on("change", this.componenteSelezionato.bind(this));

            this.selezionaComponente();*/
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

        impostaTabellaAbilita: function() {
            var columns = [],
                id = "tabella_abilita";

            this.abilita_da_modificare = {};

            /*columns.push({
                title: "Modifica",
                render: this.creaCheckBoxBulkEdit.bind(this),
                className: 'text-center modificaComponente',
                orderable: false
            });*/
            columns.push({
                title: "ID",
                data: "id_abilita",
                render: this.creaExpandButton.bind(this),
            });
            columns.push({
                title: "Tipo",
                data: "tipo_abilita"
            });
            columns.push({
                title: "Nome",
                data: "nome_abilita"
            });
            columns.push({
                title: "Costo",
                data: "costo_abilita"
            });
            columns.push({
                title: "Classe",
                data: "nome_classe_abilita"
            });
            columns.push({
                title: "Prerequisito",
                data: "nome_prerequisito_abilita"
            });
            columns.push({
                title: "Distanza",
                data: "distanza_abilita",
                width: "5%",
            });
            columns.push({
                title: "Effetto",
                data: "effetto_abilita"
            });
            columns.push({
                title: "Offset PF",
                data: "offset_pf_abilita"
            });
            columns.push({
                title: "Offset Punti Shield",
                data: "offset_shield_abilita"
            });
            columns.push({
                title: "Offset Punti Mente",
                data: "offset_mente_abilita"
            });
            /*columns.push({
                title: "Azioni",
                render: this.renderAzioni.bind(this),
                orderable: false
            });*/

            this.tabella_abilita = $('#' + id)
                .on("error.dt", this.erroreDataTable.bind(this))
                .on("draw.dt", this.setGridListeners.bind(this))
                .DataTable({
                    ajax: function(data, callback) {
                        Utils.requestData(
                            Constants.API_GET_ABILITA,
                            "GET",
                            data,
                            callback
                        );
                    },
                    columns: columns,
                    rowId: function(data) {
                        return 'ab_' + data.id_abilita;
                    },
                    order: [
                        [0, 'asc']
                    ]
                });
        },

        setListeners: function() {
            /*$("#btn_creaComponentiTecnico").click(this.creaComponente.bind(this, "tecnico"));
            $("#btn_creaComponentiChimico").click(this.creaComponente.bind(this, "chimico"));
            $("#btn_stampaRicetteTecnico").click(this.stampaCartellini.bind(this));
            $("#btn_stampaRicetteChimico").click(this.stampaCartellini.bind(this));
            $("#btn_resettaContatoriTecnico").click(this.resettaContatori.bind(this));
            $("#btn_resettaContatoriChimico").click(this.resettaContatori.bind(this));
            $("#btn_invia_modifiche_tabella_tecnico").click(this.inviaDati.bind(this));
            $("#btn_invia_modifiche_tabella_chimico").click(this.inviaDati.bind(this));
            $("#btn_apriBulkEditChimico").click(this.apriBulkEdit.bind(this));
            $("#btn_apriBulkEditTecnico").click(this.apriBulkEdit.bind(this));
            $("#btn_resettaBulkEditChimico").click(this.resettaBulkEdit.bind(this));
            $("#btn_resettaBulkEditTecnico").click(this.resettaBulkEdit.bind(this));

            $("#modal_modifica_abilita_tabella_tecnico").find("[name='tipo_abilita']").on("change", this.mostraSceltaApplicativo.bind(this));
            $("#modal_modifica_abilita_tabella_tecnico").on("hidden.bs.modal", this.onModalHide.bind(this));
            $("#modal_modifica_abilita_tabella_chimico").on("hidden.bs.modal", this.onModalHide.bind(this));

            $('.icheck input[type="checkbox"]').iCheck("destroy");
            $('.icheck input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });*/
        }
    };
}();

$(function() {
    ComponentsManager.init();
});