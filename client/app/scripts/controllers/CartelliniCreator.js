var CartelliniCreator = function ()
{

    return {
        init: function ()
        {
            this.user_info = JSON.parse(window.localStorage.getItem("user"));
            this.modal_cartell = $("#modal_form_cartellino");
            this.textarea_titolo = this.modal_cartell.find('.cartellino').find('.titolo').find('textarea');
            this.icona = this.modal_cartell.find('.cartellino').find('.icon-button');
            this.tag_input = this.modal_cartell.find('input[name="etichette"]');
            this.modelli = {};
            this.settings = {
                usa_icona: true
            };

            this.setListeners();
            this.recuperaModelli();
        },

        controllaErroriForm: function (form_obj)
        {
            var errori = [];

            if (form_obj.titolo_cartellino === "")
                errori.push("Il titolo del cartellino non pu&ograve; essere vuoto.");
            if (form_obj.descrizione_cartellino === "")
                errori.push("La descrizione del cartellino non pu&ograve; essere vuota.");
            if (form_obj.salva_modello === "on" && form_obj.nome_modello_cartellino === "")
                errori.push("Se si vuole salvare il cartellino come modello &egrave; obbligatorio inserire un nome.");

            if (errori.length > 0)
                Utils.showError("Sono stati trovati errori durante l'invio dei dati del cartellino:<br><ol><li>" + errori.join("</li><li>") + "</li></ol>", null, false);

            return errori.length > 0;
        },

        cartellinoCreato: function (dati_inviati)
        {
            CartelliniManager.tabella_cartellini.ajax.reload(null, false);
            Utils.resetSubmitBtn();

            if (dati_inviati.params.nome_modello_cartellino !== "")
                this.recuperaModelli();
        },

        inviaDati: function (e)
        {
            var URL = Constants.API_POST_CARTELLINO,
                success_mex = "Cartellino inserito con successo.",
                t = $(e.target),
                form = Utils.getFormData(t.parents(".modal").find("form")),
                tosend = {};

            if (this.controllaErroriForm(form))
                return false;

            if (form.id_cartellino !== "")
            {
                URL = Constants.API_POST_EDIT_CARTELLINO;
                success_mex = "Cartellino modificato con successo";
                tosend.id = form.id_cartellino;
                delete form.id_cartellino;
            }

            tosend.params = {};
            for (var f in form)
            {
                if (/_cartellino$/.test(f) && form[f] !== "")
                    tosend.params[f] = form[f];
            }

            if (form.etichette) tosend.etichette = form.etichette;

            Utils.requestData(
                URL,
                "POST",
                tosend,
                success_mex,
                null,
                this.cartellinoCreato.bind(this, tosend)
            );
        },

        resettaForm: function (e)
        {
            this.tag_input.tagsinput('removeAll');
            this.modal_cartell.find("input, select, textarea").each(function ()
            {
                el = $(this);
                if (el.is("input[type='text'],input[type='number'],textarea"))
                    el.val("");
                else if (el.is("select"))
                    el.find("option:selected").removeAttr("selected");
                else if (el.is("input[type='checkbox'][name='visibilita_icona']"))
                    el.iCheck("check");
                else if (el.is("input[type='checkbox']"))
                    el.iCheck("uncheck").trigger("change");
            });

            this.modal_cartell.find(".approvato_cartellino").hide();

            var select = this.modal_cartell.find("select[name='tipo_cartellino']"),
                option = {};

            select.html("");

            for (var t in Constants.MAPPA_TIPI_CARTELLINI)
                select.append("<option value='" + t + "'>" + Constants.MAPPA_TIPI_CARTELLINI[t].nome + "</option>");

            select.trigger("change");
        },

        riempiForm: function (valori)
        {
            this.tag_input.tagsinput("add", valori.etichette_componente);
            delete valori.etichette_componente;

            for (var v in valori)
                this.modal_cartell.find("[name='" + v + "']").val(valori[v]);

            if (valori.icona_cartellino !== null)
            {
                this.modal_cartell.find("[name='visibilita_icona']").iCheck("check");
                this.modal_cartell.find(".icon-button").find("i")[0].className = "fa " + valori.icona_cartellino;
            } else
                this.modal_cartell.find("[name='visibilita_icona']").iCheck("uncheck");

            if (valori.costo_attuale_ravshop_cartellino !== null)
            {
                this.modal_cartell.find("[name='pubblico_ravshop']").iCheck("check");
                this.modal_cartell.find("[name='old_costo_attuale_ravshop_cartellino']").val(valori.costo_attuale_ravshop_cartellino)
            } else
                this.modal_cartell.find("[name='pubblico_ravshop']").iCheck("uncheck");

            if (valori.nome_modello_cartellino !== null)
                this.modal_cartell.find("[name='salva_modello']").iCheck("check").trigger("change");
            else
                this.modal_cartell.find("[name='salva_modello']").iCheck("uncheck").trigger("change");

            if (Utils.controllaPermessiUtente(this.user_info, ["approvaCartellino"]))
                this.modal_cartell.find(".approvato_cartellino").removeClass("inizialmente-nascosto").show();
        },

        generaListaModelli: function (dati)
        {
            var modelli = dati.result,
                select = this.modal_cartell.find("select[name='modello_da_copiare']");

            for (var m in modelli)
            {
                select.append("<option value='" + modelli[m].id_cartellino + "'>" + modelli[m].nome_modello_cartellino + "</option>");
                modelli[m].nome_modello_cartellino = null;
                this.modelli[modelli[m].id_cartellino] = modelli[m];
            }
        },

        usaModello: function (e)
        {
            var t = $(e.currentTarget),
                id_modello = t.val();

            if (id_modello !== "")
                this.riempiForm(this.modelli[id_modello]);
            else
                this.resettaForm();
        },

        iconaPerTipo: function (e)
        {
            var target = $(e.target);
            this.icona.find("i")[0].className = "fa " + Constants.MAPPA_TIPI_CARTELLINI[target.val()].icona;
            this.modal_cartell.find("input[name='icona_cartellino']").val(Constants.MAPPA_TIPI_CARTELLINI[target.val()].icona);

            if (!Constants.MAPPA_TIPI_CARTELLINI[target.val()].acquistabile)
            {
                this.modal_cartell.find("[name='pubblico_ravshop']").iCheck("uncheck");
                this.modal_cartell.find("[name='costo_attuale_ravshop_cartellino']").val("");
                this.modal_cartell.find("[name='old_costo_attuale_ravshop_cartellino']").val("");
                this.modal_cartell.find(".costo_attuale_ravshop_cartellino_check").hide(500);
                this.modal_cartell.find(".costo_attuale_ravshop_cartellino").hide(500);
            } else
            {
                this.modal_cartell.find(".costo_attuale_ravshop_cartellino_check").show(500);

                if (this.modal_cartell.find("[name='pubblico_ravshop']").is(":checked"))
                    this.modal_cartell.find(".costo_attuale_ravshop_cartellino").show(500);
            }
        },

        toggleNomeModello: function (e)
        {
            var target = $(e.target);

            if (target.is(":checked"))
                this.modal_cartell.find(".nome_modello").show(500);
            else
                this.modal_cartell.find(".nome_modello").hide(500);
        },

        toggleCampoPrezzo: function (e)
        {
            var target = $(e.target);

            if (target.is(":checked"))
                this.modal_cartell.find(".costo_attuale_ravshop_cartellino").show(500);
            else
                this.modal_cartell.find(".costo_attuale_ravshop_cartellino").hide(500);
        },

        toggleVisibilitaIcona: function (e)
        {
            var target = $(e.target);

            this.settings.usa_icona = target.is(":checked");
            this.modal_cartell.find(".cartellino").toggleClass("senza-icona");

            if (this.settings.usa_icona)
            {
                this.textarea_titolo.unbind('keyup change', this.titoloKeyup.bind(this));
                this.textarea_titolo.css("height", null)
                this.textarea_titolo.val(this.textarea_titolo.val().replace("\n", " "))
                this.modal_cartell.find("input[name='icona_cartellino']").val(this.icona.find("i")[0].className.replace("fa ", ""));
            } else
            {
                this.modal_cartell.find("input[name='icona_cartellino']").val("");
                this.textarea_titolo.on('keyup change', this.titoloKeyup.bind(this)).trigger('change');
            }
        },

        iconaSelezionata: function (event)
        {
            this.icona.find("i")[0].className = "fa " + event.iconpickerValue;
            this.modal_cartell.find("input[name='icona_cartellino']").val(event.iconpickerValue);
        },

        titoloKeyup: function ()
        {
            var font_height = parseInt(this.textarea_titolo.css("font-size"), 10),
                new_height = 0;

            this.textarea_titolo.height(1);
            new_height = this.textarea_titolo[0].scrollHeight;
            new_height = new_height === 0 ? font_height : new_height;

            this.textarea_titolo.height(new_height);
        },

        mostraModalFormCartellino: function (defaults, e)
        {
            this.resettaForm();

            if (defaults !== null)
                this.riempiForm(defaults);

            this.modal_cartell.modal("show");
        },

        setIconPicker: function ()
        {
            this.icona.iconpicker({
                hideOnSelect: true,
                templates: {
                    search: '<input type="search" class="form-control iconpicker-search" placeholder="Cerca icona" />'
                }
            });
            this.icona.on('iconpickerSelected', this.iconaSelezionata.bind(this));
        },

        setCheckboxes: function ()
        {
            this.modal_cartell.find('.icheck input[type="checkbox"]').iCheck("destroy");
            this.modal_cartell.find('.icheck input[type="checkbox"]').iCheck({
                checkboxClass: 'icheckbox_square-blue'
            });
            this.modal_cartell.find('#ravshop').on('ifChanged', this.toggleCampoPrezzo.bind(this));
            this.modal_cartell.find('#visibilita_icona').on('ifChanged', this.toggleVisibilitaIcona.bind(this));
            this.modal_cartell.find('#salva_modello').on('ifChanged', this.toggleNomeModello.bind(this));
        },

        tagItemAggiunto: function (ev)
        {
            setTimeout(function ()
            {
                $('.bootstrap-tagsinput :input').val('');
            }, 0);
        },

        setTagsInput: function ()
        {
            this.tag_input.tagsinput({
                typeahead: {
                    source: function (query)
                    {
                        return $.get({
                            url: Constants.API_GET_TAGS,
                            xhrFields: {
                                withCredentials: true
                            }
                        });
                    }
                },
                cancelConfirmKeysOnEmpty: true,
                freeInput: true
            });

            this.tag_input.on('itemAdded', this.tagItemAggiunto.bind(this));
        },

        recuperaModelli: function ()
        {
            Utils.requestData(
                Constants.API_GET_MODELLI_CARTELLINI,
                "GET", {},
                this.generaListaModelli.bind(this)
            );
        },

        setListeners: function ()
        {
            $("#btn_creaNuovoCartellino").click(this.mostraModalFormCartellino.bind(this, null));
            this.modal_cartell.find("select[name='tipo_cartellino']").on("change", this.iconaPerTipo.bind(this));
            this.modal_cartell.find("select[name='modello_da_copiare']").on("change", this.usaModello.bind(this));
            this.modal_cartell.find("#btn_invia_cartellino").click(this.inviaDati.bind(this));

            if (!this.settings.usa_icona)
                this.textarea_titolo.on('keyup change', this.titoloKeyup.bind(this)).trigger('change');

            this.setIconPicker();
            this.setCheckboxes();
            this.setTagsInput();
            this.resettaForm();
        }
    };
}();

$(function ()
{
    CartelliniCreator.init();
});
