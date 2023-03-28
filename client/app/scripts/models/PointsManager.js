var PointsManager = function () {
    return {

        init: function () {
            //TODO: mettere pulsanti per aumentare e diminure il valore a causa di cel che non fanno inserire numeri negativi
            this.listeners_set = false;
        },

        impostaModal: function (settings) {
            this.settings = { valore_max: Infinity, valore_min: -Infinity };
            this.settings = $.extend(this.settings, settings);
            this.setListeners();
            this.risettaValori();
            this.impostaValori();
        },

        inviaRichiestaAssegna: function () {
            Utils.requestData(
                Constants.API_POST_EDIT_MOLTI_PG,
                "POST",
                {
                    pg_ids: this.settings.pg_ids,
                    modifiche: {
                        pc_personaggio: $("#modal_assegna_punti").find("#offset_pc").val(),
                        px_personaggio: $("#modal_assegna_punti").find("#offset_px").val()
                    },
                    is_offset: true,
                    note_azione: $("#modal_assegna_punti").find(".note-azione").val()
                },
                "Punti modificati con successo.",
                null,
                this.settings.onSuccess
            );
        },

        impostaValori: function () {
            $("#modal_assegna_punti").find("#nome_personaggi").text(this.settings.nome_personaggi.join(", "));
            $("#modal_assegna_punti").find(".note-azione").val(this.settings.note_azione);
            $("#modal_assegna_punti").modal({ drop: "static" });
        },

        risettaValori: function () {
            $("#modal_assegna_punti").find("#btn_assegna").attr("disabled", false).find("i").remove();
            $("#modal_assegna_punti").find("#nome_personaggi").html("");

            $("#modal_assegna_punti").find("#offset_pc").val(0);
            $("#modal_assegna_punti").find("#offset_px").val(0);
        },

        setListeners: function () {
            if (this.listeners_set)
                return false;

            this.listeners_set = true;

            $("#modal_assegna_punti").find("#btn_assegna").unbind("click", this.inviaRichiestaAssegna.bind(this));
            $("#modal_assegna_punti").find("#btn_assegna").click(this.inviaRichiestaAssegna.bind(this));

            if (Utils.isDeviceMobile()) {
                $("#modal_assegna_punti").find(".pulsantiera-mobile").removeClass("inizialmente-nascosto");
                new PulsantieraNumerica({
                    target: $("#modal_assegna_punti").find("#offset_pc"),
                    pulsantiera: $("#modal_assegna_punti").find("#pulsanti_pc"),
                    valore_max: this.settings.valore_max,
                    valore_min: this.settings.valore_min
                });
                new PulsantieraNumerica({
                    target: $("#modal_assegna_punti").find("#offset_px"),
                    pulsantiera: $("#modal_assegna_punti").find("#pulsanti_px"),
                    valore_max: this.settings.valore_max,
                    valore_min: this.settings.valore_min
                });
            }
        }
    }
}();

$(function () {
    PointsManager.init();
});