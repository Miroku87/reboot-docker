
var PgEditManager = function ()
{
    return {
        init: function ()
        {
            this.user_info = JSON.parse( window.localStorage.getItem( "user" ) );
            var permessi = [
                "modificaPG_anno_nascita_personaggio_altri",
                "modificaPG_contattabile_personaggio_altri",
                "modificaPG_motivazioni_olocausto_inserite_personaggio_altri",
                "modificaPG_nome_personaggio_altri",
                "modificaPG_giocatori_email_giocatore_altri"
            ];

            if ( !Utils.controllaPermessiUtente( this.user_info, permessi, false ) )
                return false;

            this.modal = $( "#modal_modifica_pg" );
            this.onSuccess = Utils.reloadPage;
            this.dati = {};
            this.getUsers();
            this.setListeners();
        },

        riempiElencoUsers: function ( data )
        {
            var users = data.data,
                menu = this.modal.find( "select[name='giocatori_email_giocatore']" );

            for ( var s in users )
                menu.append( "<option value='" + users[s].email_giocatore + "'>" + users[s].nome_completo + "</option>" );
        },

        getUsers: function ()
        {
            Utils.requestData(
                Constants.API_GET_PLAYERS,
                "GET",
                "draw=1&columns=&order=&start=0&length=999&search=",
                this.riempiElencoUsers.bind( this )
            );
        },

        riempiModal: function ( elem )
        {
            this.dati = elem.data();

            for ( var d in this.dati )
            {
                var campo = $( "[name='" + d + "']" );

                if ( campo.is( "input[type='checkbox']" ) )
                    campo.iCheck( this.dati[d] == 1 ? "check" : "uncheck" );
                else
                    campo.val( this.dati[d] );
            }
        },

        resettaModal: function ()
        {
            this.modal.find( "form" ).trigger( "reset" );
            this.modal.find( "select[name='giocatori_email_giocatore']" ).find( "option[value='" + this.dati.giocatori_email_giocatore + "']" ).prop( "selected", true );
            $( "#contattabile" ).iCheck( "check" );
            $( "#motivazioni" ).iCheck( "uncheck" );
        },

        mostraModal: function ( e )
        {
            this.resettaModal();
            this.riempiModal( $( e.currentTarget ) );
            this.modal.modal( "show" );
        },

        inviaDati: function ()
        {
            var form = Utils.getFormData( this.modal.find( "form" ) ),
                tosend = {};

            for ( var f in form )
            {
                if ( typeof this.dati[f] !== "undefined" && form[f] != this.dati[f] )
                    tosend[f] = form[f];
            }

            if ( Object.keys( tosend ).length > 0 )
                Utils.requestData(
                    Constants.API_POST_EDIT_PG,
                    "POST",
                    { id: this.dati.id_personaggio, modifiche: tosend },
                    "Personaggio modificato con successo",
                    null,
                    this.onSuccess
                );
            else
                this.modal.modal( "hide" );
        },

        setListeners: function ()
        {
            $( ".mostraModalEditPG" ).click( this.mostraModal.bind( this ) );
            this.modal.find( "#btn_modifica" ).click( this.inviaDati.bind( this ) );
            this.modal.find( ".icheck" ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
        },

        setOnSuccess: function ( f )
        {
            this.onSuccess = f;
        }
    };
}();

$( function ()
{
    PgEditManager.init();
} );