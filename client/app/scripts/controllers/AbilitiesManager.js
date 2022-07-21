/**
 * Created by Miroku on 11/03/2018.
 */
var AbilitiesManager = function() {
    var SEPARATORE = "££";

    return {
        init: function() {
            this.abilita_selezionati = {};
            this.abilita_da_modificare = {}

            this.setListeners();
            this.impostaTabellaAbilita();
        },

        mostraChildRow: function(e) {
            var tr = $(e.currentTarget).closest('tr');
            var row = this.tabella_abilita.row(tr);

            if (row.child.isShown()) {
                tr.removeClass('shown');
                row.child.hide();
            } else {
                row.child(row.data().descrizione_abilita).show();
                tr.addClass('shown');
            }
        },

        creaExpandButton: function(data, type, row, meta) {
            return "<span class=\"expand-bt\">" + Utils.pad(data, 3) + " <li class=\"fa fa-angle-down\"></li></span>";
        },

        renderPrerequisito: function(data, type, row, meta) {
            if (parseInt(row.prerequisito_abilita) > 0) {
                return data;
            }

            return Constants.SPECIAL_PREREQUISITES[row.prerequisito_abilita + ""];
        },

        setGridListeners: function() {
            AdminLTEManager.controllaPermessi();

            $('td > .expand-bt').click(this.mostraChildRow.bind(this));
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
                data: "nome_prerequisito_abilita", //prerequisito_abilita
                render: this.renderPrerequisito.bind(this)
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

        setListeners: function() {}
    };
}();

$(function() {
    AbilitiesManager.init();
});