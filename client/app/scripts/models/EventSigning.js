var EventSigning = ( function EventSigning()
{
    return {

        init: function ()
        {
            this.user_info = JSON.parse( window.localStorage.getItem( "user" ) );
            this.modal = $( "#modal_iscrivi_pg" );

            this.setListeners();
        },

        showModal: function ( pgs )
        {
            this.modal.find( "#note" ).val( "" );
            this.modal.find( "#pagato" ).prop( "checked", false );
            this.modal.find( "#personaggio" ).html( "" );

            if ( pgs )
                this.creaListaPG( pgs );
            else
                this.recuperaPg();

            this.modal.modal( { drop: "static" } );
        },

        creaListaPG: function ( pgs )
        {
            var elems = pgs.reduce( function ( pre, ora ) 
            {
                return pre + "<option value=\"" + ora.id_personaggio + "\">" + ora.nome_personaggio + "</option>"
            }, "" );

            this.modal.find( "#personaggio" ).append( elems );
        },

        mandaIscrizione: function ()
        {
            Utils.requestData(
                Constants.API_POST_ISCRIZIONE,
                "POST",
                {
                    id_pg: this.modal.find( "#personaggio" ).val(),
                    pagato: this.modal.find( "#pagato" ).is( ":checked" ) ? 1 : 0,
                    tipo_pag: this.modal.find( "#metodo_pagamento" ).val(),
                    note: this.modal.find( "#note" ).val()
                },
                "Personaggio iscritto con successo.",
                null,
                Utils.reloadPage
            );
        },

        salvaListaPG: function ( d )
        {
            this.creaListaPG( d.result || d.data );
        },

        recuperaPg: function ()
        {
            var url = Constants.API_GET_PGS_PROPRI;

            if ( Utils.controllaPermessiPg( this.user_info, ["iscriviPg_altri"] ) )
                url = Constants.API_GET_PGS;

            Utils.requestData(
                url,
                "GET",
                "draw=1&columns[0][data]=id_personaggio&columns[0][name]=&columns[0][searchable]=true&columns[0][orderable]=true&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=nome_giocatore&columns[1][name]=&columns[1][searchable]=true&columns[1][orderable]=true&columns[1][search][value]=&columns[1][search][regex]=false&columns[2][data]=nome_personaggio&columns[2][name]=&columns[2][searchable]=true&columns[2][orderable]=true&columns[2][search][value]=&columns[2][search][regex]=false&order[0][column]=0&order[0][dir]=desc&start=0&length=10&search[value]=&search[regex]=false",
                this.salvaListaPG.bind( this )
            );
        },

        setListeners: function ()
        {
            this.modal.find( 'input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
            this.modal.find( "#btn_iscrivi" ).click( this.mandaIscrizione.bind( this ) );
        }
    };
} )();

$( function ()
{
    EventSigning.init();
} )