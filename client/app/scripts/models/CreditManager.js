var CreditManager = function ()
{
    return {

        init: function ()
        {
            //TODO: mettere pulsanti per aumentare e diminure il valore a causa di cel che non fanno inserire numeri negativi
            this.modal_selector = "#modal_modifica_credito";
            this.listeners_set = false;
        },

        impostaModal: function ( settings )
        {
            this.settings = { valore_max: Infinity, valore_min: -Infinity };
            this.settings = $.extend( this.settings, settings );

            if ( this.settings.pg_ids.length < 1 )
            {
                Utils.showError( "Impossibile assegnare Bit a 0 personaggi." );
                return false;
            }

            this.setListeners();
            this.risettaValori();
            this.impostaValori();
        },

        inviaRichiestaAssegna: function ()
        {
            if ( $( this.modal_selector ).find( "#motivo_credito" ).val() === "" )
            {
                Utils.showError( "&Egrave; obbligatorio inserire una motivazione per il bonifico." );
                return false;
            }

            Utils.requestData(
                Constants.API_POST_TRANSAZIONE_MOLTI,
                "POST",
                {
                    importo: $( this.modal_selector ).find( "#offset_crediti" ).val(),
                    note: $( this.modal_selector ).find( "#motivo_credito" ).val(),
                    creditori: this.settings.pg_ids
                },
                "Bonifico eseguito con successo.",
                null,
                this.settings.onSuccess
            );
        },

        impostaValori: function ()
        {
            $( this.modal_selector ).find( "#nome_personaggi" ).text( this.settings.nome_personaggi.join( ", " ) );
            $( this.modal_selector ).modal( { drop: "static" } );
        },

        risettaValori: function ()
        {
            $( this.modal_selector ).find( "#btn_modifica" ).attr( "disabled", false ).find( "i" ).remove();
            $( this.modal_selector ).find( "#nome_personaggi" ).html( "" );
            $( this.modal_selector ).find( "#offset_crediti" ).val( 0 );
        },

        setListeners: function ()
        {
            if ( this.listeners_set )
                return false;

            this.listeners_set = true;

            $( this.modal_selector ).find( "#btn_modifica" ).unbind( "click", this.inviaRichiestaAssegna.bind( this ) );
            $( this.modal_selector ).find( "#btn_modifica" ).click( this.inviaRichiestaAssegna.bind( this ) );

            if ( Utils.isDeviceMobile() )
            {
                $( "#modal_modifica_credito" ).find( ".pulsantiera-mobile" ).removeClass( "inizialmente-nascosto" );
                new PulsantieraNumerica( {
                    target: $( "#modal_modifica_credito" ).find( "#offset_crediti" ),
                    pulsantiera: $( "#modal_modifica_credito" ).find( "#pulsanti_credito" ),
                    valore_max: this.settings.valore_max,
                    valore_min: this.settings.valore_min
                } );
            }
        }
    }
}();

$( function ()
{
    CreditManager.init();
} );