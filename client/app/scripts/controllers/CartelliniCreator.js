var CartelliniCreator = function ()
{
    var mappa_tipi_icone = {
        componente_consumabile: "fa-cubes",
        abilita_sp_malattia: "fa-medkit",
        armatura_protesi_potenziamento: "fa-shield",
        arma_equip: "fa-rocket",
        interazione_area: "fa-puzzle-piece"
    };

    return {
        init : function ()
        {
            this.textarea_titolo = $("#modal_form_cartellino").find('.cartellino').find('.titolo').find('textarea');
            this.icona           = $("#modal_form_cartellino").find('.cartellino').find('.icon-button');
            this.tag_input       = $("#modal_form_cartellino").find('input[name="etichette"]');
            this.settings        = {
                usa_icona : true
            };

            this.setListeners();
        },

        controllaErroriForm : function ( form_obj )
        {
            var errori = [];

            if( form_obj.titolo_cartellino === ""  )
                errori.push("Il titolo del cartellino non pu&ograve; essere vuoto.");
            if( form_obj.descrizione_cartellino === ""  )
                errori.push("La descrizione del cartellino non pu&ograve; essere vuota.");
            if( form_obj.salva_modello === "on" && form_obj.nome_modello_cartellino === "" )
                errori.push("Se si vuole salvare il cartellino come modello &egrave; obbligatorio inserire un nome.");

            if( errori.length > 0 )
                Utils.showError("Sono stati trovati errori durante l'invio dei dati del cartellino:<br><ol><li>"+errori.join("</li><li>")+"</li></ol>",null,false);

            return errori.length > 0;
        },

        inviaDati : function ( e )
        {
            var t = $(e.target),
                form = Utils.getFormData(t.parents(".modal").find("form")),
                tosend = { params: {} };

            if( this.controllaErroriForm(form) )
                return false;

            for ( var f in form )
            {
                if( /_cartellino$/.test(f) && form[f] !== "" )
                    tosend.params[f] = form[f];
            }

            if( form.etichette ) tosend.etichette = form.etichette;

            Utils.requestData(
                Constants.API_POST_CARTELLINO,
                "POST",
                tosend,
                "Cartellino inserito con successo."
            );
        },

        resettaForm : function ( e )
        {

        },

        iconaPerTipo : function ( e )
        {
            var target = $(e.target);
            this.icona.find("i")[0].className = "fa " + mappa_tipi_icone[ target.val() ];
            $("#modal_form_cartellino").find("input[name='icona_cartellino']").val( mappa_tipi_icone[ target.val() ] );
        },

        toggleNomeModello : function (e)
        {
            var target = $(e.target);

            if (target.is(":checked"))
                $("#modal_form_cartellino").find(".nome_modello").show(500);
            else
                $("#modal_form_cartellino").find(".nome_modello").hide(500);
        },

        toggleCampoPrezzo : function (e)
        {
            var target = $(e.target);

            if (target.is(":checked"))
                $("#modal_form_cartellino").find(".costo_attuale_ravshop_cartellino").show(500);
            else
                $("#modal_form_cartellino").find(".costo_attuale_ravshop_cartellino").hide(500);
        },

        toggleVisibilitaIcona : function (e)
        {
            var target = $(e.target);

            this.settings.usa_icona = target.is(":checked");
            $("#modal_form_cartellino").find(".cartellino").toggleClass("senza-icona");

            if (this.settings.usa_icona)
            {
                this.textarea_titolo.unbind('keyup change', this.titoloKeyup.bind(this));
                this.textarea_titolo.css("height", null)
                this.textarea_titolo.val(this.textarea_titolo.val().replace("\n", " "))
                $("#modal_form_cartellino").find("input[name='icona_cartellino']").val( this.icona.find("i")[0].className.replace("fa ","") );
            }
            else
            {
                $("#modal_form_cartellino").find("input[name='icona_cartellino']").val("");
                this.textarea_titolo.on('keyup change', this.titoloKeyup.bind(this)).trigger('change');
            }
        },

        iconaSelezionata : function (event)
        {
            this.icona.find("i")[0].className = "fa " + event.iconpickerValue;
            $("#modal_form_cartellino").find("input[name='icona_cartellino']").val(event.iconpickerValue);
        },

        titoloKeyup : function ()
        {
            var font_height = parseInt(this.textarea_titolo.css("font-size"), 10),
                new_height  = 0;

            this.textarea_titolo.height(1);
            new_height = this.textarea_titolo[0].scrollHeight;
            new_height = new_height === 0 ? font_height : new_height;

            this.textarea_titolo.height(new_height);
        },

        mostraModalFormCartellino : function ()
        {
            $("#modal_form_cartellino").modal("show");
        },

        setIconPicker: function ()
        {
            this.icona.iconpicker({
                hideOnSelect : true,
                templates    : {
                    search : '<input type="search" class="form-control iconpicker-search" placeholder="Cerca icona" />'
                }
            });
            this.icona.on('iconpickerSelected', this.iconaSelezionata.bind(this));
        },

        setCheckboxes: function ()
        {
            $("#modal_form_cartellino").find('.icheck input[type="checkbox"]').iCheck("destroy");
            $("#modal_form_cartellino").find('.icheck input[type="checkbox"]').iCheck({
                checkboxClass : 'icheckbox_square-blue'
            });
            $("#modal_form_cartellino").find('#ravshop').on('ifChanged', this.toggleCampoPrezzo.bind(this));
            $("#modal_form_cartellino").find('#visibilita_icona').on('ifChanged', this.toggleVisibilitaIcona.bind(this));
            $("#modal_form_cartellino").find('#salva_modello').on('ifChanged', this.toggleNomeModello.bind(this));
        },

        tagItemAggiunto: function ( ev )
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
                        return $.get(Constants.API_GET_TAGS);
                    }
                },
                cancelConfirmKeysOnEmpty: true,
                freeInput: true
            });

            this.tag_input.on('itemAdded', this.tagItemAggiunto.bind(this));
        },

        setListeners : function ()
        {
            $("#btn_creaNuovoCartellino").click(this.mostraModalFormCartellino.bind(this));
            $("#modal_form_cartellino").find("select[name='tipo_cartellino']").on("change", this.iconaPerTipo.bind(this)).trigger("change");
            $("#modal_form_cartellino").find("#btn_invia_cartellino").click( this.inviaDati.bind(this) );

            if (!this.settings.usa_icona)
                this.textarea_titolo.on('keyup change', this.titoloKeyup.bind(this)).trigger('change');

            this.setIconPicker();
            this.setCheckboxes();
            this.setTagsInput();
        }
    };
}();

$(function ()
{
    CartelliniCreator.init();
});
