/**
 * Created by Miroku on 03/03/2018.
 */

var MessaggingManager = function ()
{
    return {

        init: function ()
        {
            this.user_info = JSON.parse( window.localStorage.getItem( "user" ) );
            this.pg_info = window.localStorage.getItem( "logged_pg" );
            this.pg_info = this.pg_info ? JSON.parse( this.pg_info ) : null;
            this.visibile_ora = typeof this.user_info.pg_da_loggare !== "undefined" ? $( "#lista_ig" ) : $( "#lista_fg" );

            this.vaiA( this.visibile_ora, true );

            this.setListeners();
            this.recuperaDatiPropriPG();
            this.controllaStorage();
            this.mostraMessaggi();
        },

        erroreDataTable: function ( e, settings, techNote, message )
        {
            if ( !settings.jqXHR.responseText )
                return false;

            var real_error = settings.jqXHR.responseText.replace( /^([\S\s]*?)\{"[\S\s]*/i, "$1" );
            real_error = real_error.replace( "\n", "<br>" );
            Utils.showError( real_error );
        },

        risettaMessaggio: function ()
        {
            this.id_destinatario = null;
            this.conversazione_in_lettura = null;

            $( ".form-destinatario" ).first().find( ".nome-destinatario" ).val( "" );
            $( ".form-destinatario" ).first().find( ".nome-destinatario" ).attr( "disabled", false );
            $( ".form-destinatario" ).first().find( ".controlli-destinatario" ).show();
            $( "#messaggio" ).val( "" );
            $( "#messaggio" ).attr( "disabled", false );
            $( "#oggetto" ).val( "" );
            $( "#oggetto" ).attr( "disabled", false );

            $( "#tipo_messaggio" ).attr( "disabled", false );
            $( "#invia_messaggio" ).attr( "disabled", true );
            this.inserisciMittente();
        },

        aggiungiDestinatarioInArray: function ( input_elem, id )
        {
            var index = $( ".form-destinatario" ).index( $( input_elem ).parents( ".form-destinatario" ) );

            if ( !( this.id_destinatari instanceof Array ) )
                this.id_destinatari = [];

            if ( this.id_destinatari.indexOf( id ) === -1 && !/^\s*$/.test( id ) )
                this.id_destinatari[index] = id;

            console.log( "adding", this.id_destinatari );
        },

        rimuoviDestinatarioInArray: function ( input_elem )
        {
            var index = $( ".form-destinatario" ).index( $( input_elem ).parents( ".form-destinatario" ) );

            if ( this.id_destinatari instanceof Array && this.id_destinatari[index] )
                this.id_destinatari.splice( index, 1 );

            console.log( "removing", this.id_destinatari );
        },

        destinatarioSelezionato: function ( event, ui )
        {
            this.aggiungiDestinatarioInArray( event.target, ui.item.real_value );

            $( "#invia_messaggio" ).attr( "disabled", false );
        },

        scrittoSuDestinatario: function ( e, ui )
        {
            var scritta = $( e.target ).val().substr( 1 ),
                index_dest = $( ".form-destinatario" ).index( $( e.target ).parents( ".form-destinatario" ) );

            if ( this.id_destinatari && this.id_destinatari[index_dest] )
                this.id_destinatari[index_dest] = null;

            if ( $( "#tipo_messaggio" ).val() === "ig" && $( e.target ).val().substr( 0, 1 ) === "#" && /^\d+$/.test( scritta ) && scritta !== "" )
            {
                this.aggiungiDestinatarioInArray( e.target, scritta );
                $( "#invia_messaggio" ).attr( "disabled", false );
            }
            //else if ( $("#tipo_messaggio").val() === "ig" && $(e.target).val().substr(0,1) !== "#" )
            //    $("#invia_messaggio").attr("disabled",true);
        },

        selezionatoDestinatario: function ( e, ui )
        {
            //if( !ui.item && $("#tipo_messaggio").val() !== "ig" && $(e.target).val().substr(0,1) !== "#" )
            //    $("#invia_messaggio").attr("disabled",true);
        },

        inserisciMittente: function ()
        {
            if ( $( "#tipo_messaggio" ).val() === "ig" )
                this.renderizzaMenuIG();
            else if ( $( "#tipo_messaggio" ).val() === "fg" )
                this.renderizzaMenuFG();
        },

        resettaInputDestinatari: function ()
        {
            $( ".form-destinatario:not(:first)" ).remove();
            $( ".form-destinatario" ).first().find( ".nome-destinatario" ).val( "" );
            this.impostaControlliDestinatari();
        },

        cambiaListaDestinatari: function ( e )
        {
            this.id_destinatari = [];
            this.resettaInputDestinatari();
            $( "#invia_messaggio" ).attr( "disabled", true );

            this.inserisciMittente();
        },

        recuperaDestinatariAutofill: function ( tipo, req, res )
        {
            var url = tipo === "ig" ? Constants.API_GET_DESTINATARI_IG : Constants.API_GET_DESTINATARI_FG;
            //var url = Constants.API_GET_DESTINATARI_IG;

            Utils.requestData(
                url,
                "GET",
                { term: req.term },
                function ( data )
                {
                    var dati = data.results.filter( function ( el ) { return el.real_value !== $( "#mittente" ).val(); } );
                    res( dati );
                }
            );
        },

        rimuoviAutocompleteDestinatario: function ()
        {
            if ( $( ".form-destinatario" ).find( ".nome-destinatario" ).data( 'autocomplete' ) )
            {
                $( ".form-destinatario" ).find( ".nome-destinatario" ).autocomplete( "destroy" );
                $( ".form-destinatario" ).find( ".nome-destinatario" ).removeData( 'autocomplete' );
            }
        },

        impostaAutocompleteDestinatario: function ()
        {
            this.rimuoviAutocompleteDestinatario();
            $( ".form-destinatario" ).find( ".nome-destinatario" ).autocomplete( {
                autoFocus: true,
                select: this.destinatarioSelezionato.bind( this ),
                search: this.scrittoSuDestinatario.bind( this ),
                change: this.selezionatoDestinatario.bind( this ),
                source: this.recuperaDestinatariAutofill.bind( this, $( "#tipo_messaggio" ).val() )
            } );
        },

        impostaInterfacciaScrittura: function ()
        {
            var default_type = "fg";

            if ( this.user_info && this.user_info.pg_da_loggare )
                default_type = "ig";

            $( "#tipo_messaggio" ).val( default_type );
            this.impostaControlliDestinatari();

            $( "#tipo_messaggio" ).change( this.cambiaListaDestinatari.bind( this ) );
            $( "#invia_messaggio" ).click( this.inviaMessaggio.bind( this ) );
            $( "#risetta_messaggio" ).click( this.risettaMessaggio.bind( this ) );

            if ( this.conversazione_in_lettura )
            {
                var id_mittente;

                if ( default_type === "ig" && this.conversazione_in_lettura[0].id_mittente === this.user_info.
                    this.id_destinatari = [this.conversazione_in_lettura[0].id_mittente];

                $( "#tipo_messaggio" ).val( this.conversazione_in_lettura.tipo );
                $( "#tipo_messaggio" ).attr( "disabled", true );

                $( ".form-destinatario" ).first().find( ".nome-destinatario" ).val( this.conversazione_in_lettura.mittente );
                $( ".form-destinatario" ).first().find( ".nome-destinatario" ).attr( "disabled", true );
                $( ".form-destinatario" ).first().find( ".controlli-destinatario" ).hide();

                if ( this.conversazione_in_lettura.oggetto )
                {
                    var oggetto_decodificato = decodeURIComponent( this.conversazione_in_lettura.oggetto );
                    $( "#oggetto" ).val( "Re: " + oggetto_decodificato.replace( /^\s*?re:\s?/i, "" ) );
                    $( "#oggetto" ).attr( "disabled", true );
                }

                $( "#invia_messaggio" ).attr( "disabled", false );
            }

            this.inserisciMittente();
        },

        liberaSpazioMessaggio: function ()
        {
            $( "#oggetto_messaggio" ).text( "" );
            $( "#mittente_messaggio" ).text( "" );
            $( "#destinatario_messaggio" ).text( "" );
            $( "#data_messaggio" ).text( "" );
            $( "#corpo_messaggio" ).text( "" );
        },

        mostraConversazione: function ( dati )
        {
            this.conversazione_in_lettura = dati;
            $( ".message-container" ).not( "#template_messaggio" ).remove();

            for ( var d in dati )
            {
                var nodo_mex = $( "#template_messaggio" ).clone(),
                    testo_mex = decodeURIComponent( dati[d].testo_messaggio ).replace( /\n/g, "<br>" ),
                    testo_ogg = decodeURIComponent( dati[d].oggetto_messaggio ).replace( /Re:\s?/g, "" );

                if ( parseInt( d, 10 ) === 0 )
                    nodo_mex.find( ".oggetto-messaggio" ).text( testo_ogg );

                nodo_mex.removeClass( "hidden" );
                nodo_mex.attr( "id", "" );
                nodo_mex.find( ".mittente-messaggio" ).text( dati[d].nome_mittente );
                nodo_mex.find( ".destinatario-messaggio" ).text( dati[d].nome_destinatario );
                nodo_mex.find( ".data-messaggio" ).text( dati[d].data_messaggio );
                nodo_mex.find( ".corpo-messaggio" ).html( testo_mex );

                $( "#template_messaggio" ).parent().append( nodo_mex );
            }
        },

        leggiMessaggio: function ( e )
        {
            var target = $( e.target );
            this.recuperaConversazione( target.attr( "data-id" ), target.attr( "data-tipo" ) );
            this.vaiA( $( "#leggi_messaggio" ), false, e );
        },

        formattaNonLetti: function ( data, type, row )
        {
            var asterisk = "";

            if ( data.substr( 0, 2 ) === "<a" )
                asterisk = "<i class='fa fa-asterisk'></i> ";

            return parseInt( row.letto_messaggio, 10 ) === 0 ? "<strong>" + asterisk + data + "</strong>" : data;
        },

        formattaOggettoMessaggio: function ( data, type, row )
        {
            return this.formattaNonLetti( "<a href='#' " +
                "class='link-messaggio' " +
                "data-id='" + row.id_conversazione + "' " +
                "data-tipo='" + row.tipo_messaggio + "' " +
                "data-casella='" + row.casella_messaggio + "'>" + decodeURIComponent( data ) + "</a>", type, row );
        },

        tabellaDisegnata: function ( e )
        {
            $( ".link-messaggio" ).unbind( "click" );
            $( ".link-messaggio" ).click( this.leggiMessaggio.bind( this ) );
        },

        aggiornaDati: function ()
        {
            if ( this.tab_fg ) this.tab_fg.ajax.reload( null, true );
            if ( this.tab_inviati_fg ) this.tab_inviati_fg.ajax.reload( null, true );
            if ( this.tab_ig ) this.tab_ig.ajax.reload( null, true );
            if ( this.tab_inviati_ig ) this.tab_inviati_ig.ajax.reload( null, true );
        },

        mostraMessaggi: function ()
        {
            if ( this.user_info && !( this.user_info.pg_da_loggare && typeof this.user_info.event_id !== "undefined" ) )
                $( "#sezioni" ).find( "li:first-child" ).removeClass( "inizialmente-nascosto" ).show();

            $( "#sezioni" ).find( "li:last-child" ).removeClass( "inizialmente-nascosto" ).show();

            if ( this.user_info && this.user_info.pg_da_loggare && typeof this.user_info.event_id !== "undefined" )
            {
                $( "#sezioni" ).find( ".nome_sezione" ).text( "Caselle" );
                $( "#tipo_messaggio" ).val( "ig" ).hide();
                // this.recuperaDestinatariAutofill.bind(this,"ig");
            }

            this.tab_fg = this.creaDataTable.call( this, 'lista_fg_table', Constants.API_GET_MESSAGGI, { tipo: "fg" } );
            this.tab_ig = this.creaDataTable.call( this, 'lista_ig_table', Constants.API_GET_MESSAGGI, { tipo: "ig" } );
        },

        trovaDestinatarioInConv: function ( mittente )
        {

        },

        mittenteRispostaScelto: function ( e )
        {
            var t = $( e.currentTarget );
            this.trovaDestinatarioInConv( t.val() )
        },

        renderizzaMenuIG: function ()
        {
            var pgs = this.info_propri_pg;
            $( "#mittente" ).html( "" );
            $( "#mittente" ).prop( "disabled", false );

            for ( var p in pgs )
                $( "#mittente" ).append( $( "<option>" ).val( pgs[p].id_personaggio ).text( "Da: " + pgs[p].nome_personaggio ) );

            if ( this.conversazione_in_lettura && this.conversazione_in_lettura.id_destinatario )
                $( "#mittente" ).val( this.conversazione_in_lettura.id_destinatario ).prop( "disabled", true );

            if ( this.pg_info && !this.conversazione_in_lettura )
                $( "#mittente" ).val( this.pg_info.id_personaggio ).prop( "disabled", true );
            else if ( this.pg_info && this.conversazione_in_lettura )
            {
                $( "#mittente" ).val( this.pg_info.id_personaggio ).prop( "disabled", true );
                this.trovaDestinatarioInConv( this.pg_info.id_personaggio );
            }
            else if ( !this.pg_info && this.conversazione_in_lettura )
                $( "#mittente" ).on( "change", this.mittenteRispostaScelto.bind( this ) )
        },

        renderizzaMenuFG: function ()
        {
            $( "#mittente" ).html( "" );
            $( "#mittente" ).append( $( "<option>" ).val( this.user_info.email_giocatore ).text( "Da: " + this.user_info.nome_giocatore ) );
            $( "#mittente" ).val( this.user_info.email_giocatore ).prop( "disabled", true );
        },

        recuperaDatiPropriPG: function ()
        {
            Utils.requestData(
                Constants.API_GET_PGS_PROPRI,
                "GET",
                {},
                function ( data )
                {
                    this.info_propri_pg = data.result;
                    this.inserisciMittente();
                }.bind( this )
            );
        },

        creaDataTable: function ( id, url, data )
        {
            //TODO: checkbox per mostrare i messaggi dei soli propri PG
            return $( '#' + id )
                .on( "error.dt", this.erroreDataTable.bind( this ) )
                .on( "draw.dt", this.tabellaDisegnata.bind( this ) )
                .DataTable( {
                    processing: true,
                    serverSide: true,
                    dom: "<'row'<'col-sm-6'lB><'col-sm-6'f>>" +
                        "<'row'<'col-sm-12 table-responsive'tr>>" +
                        "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                    buttons: ["reload"],
                    language: Constants.DATA_TABLE_LANGUAGE,
                    ajax: function ( d, callback )
                    {
                        //$("input[name='filtri']").val()
                        var tosend = $.extend( d, data );

                        if ( data.tipo === "ig" )
                            tosend.filtro = $( '#' + id ).parents( ".box-body" ).find( "input[name='filtri']:checked" ).val();

                        Utils.requestData(
                            url,
                            "GET",
                            tosend,
                            callback
                        );
                    },
                    columns: [
                        {
                            title: "Partecipanti Conversazione",
                            data: "coinvolti",
                            render: this.formattaNonLetti.bind( this )
                        },
                        {
                            title: "Oggetto",
                            data: "oggetto_messaggio",
                            render: this.formattaOggettoMessaggio.bind( this )
                        },
                        {
                            title: "Data",
                            data: "data_messaggio",
                            render: this.formattaNonLetti.bind( this )
                        }
                    ],
                    order: [[2, 'desc']]
                } );
        },

        impostaControlliDestinatari: function ()
        {
            $( ".form-destinatario" ).find( ".aggiungi-destinatario" ).unbind( "click" );
            $( ".form-destinatario" ).find( ".rimuovi-destinatario" ).unbind( "click" );

            $( ".form-destinatario" ).find( ".aggiungi-destinatario" ).click( this.aggiungiDestinatario.bind( this ) );
            $( ".form-destinatario" ).find( ".rimuovi-destinatario:not(.disabled)" ).click( this.rimuoviDestinatario.bind( this ) );

            this.impostaAutocompleteDestinatario();

            if ( $( "#tipo_messaggio" ).val() === "ig" )
                $( ".form-destinatario" ).find( ".nome-destinatario" ).popover( {
                    content: "In caso di ID inserire sempre # prima del numero.",
                    trigger: Utils.isDeviceMobile() ? "click" : "hover",
                    placement: "top"
                } );
        },

        aggiungiDestinatario: function ( e )
        {
            var nodo = $( ".form-destinatario" ).first().clone();

            nodo.find( ".nome-destinatario" ).val( "" );
            nodo.find( ".rimuovi-destinatario" ).removeClass( "disabled" );
            nodo.insertAfter( $( e.currentTarget ).parents( ".form-destinatario" ) );

            this.impostaControlliDestinatari();
        },

        rimuoviDestinatario: function ( e )
        {
            this.rimuoviDestinatarioInArray( $( e.currentTarget ).parents( ".form-destinatario" ).find( ".nome-destinatario" )[0] );
            $( e.currentTarget ).parents( ".form-destinatario" ).remove();
        },

        messaggioInviatoOk: function ( data )
        {
            Utils.showMessage( data.message, Utils.reloadPage );
        },

        inviaDatiMessaggio: function ( dati )
        {
            delete dati.mittente_text;

            Utils.requestData(
                Constants.API_POST_MESSAGGIO,
                "POST",
                dati,
                this.messaggioInviatoOk.bind( this ),
                null,
                null
            );
        },

        mostraConfermaInvio: function ( dati )
        {
            Utils.showConfirm(
                dati.mittente_text + ", confermi di voler inviare il messaggio?",
                this.inviaDatiMessaggio.bind( this, dati ),
                false
            );
        },

        inviaMessaggio: function ()
        {
            var destinatari = this.id_destinatari,
                oggetto = $( "#oggetto" ).val(),
                testo = $( "#messaggio" ).val(),
                data = {};

            if ( !destinatari || ( destinatari && destinatari.length === 0 ) || !oggetto || !testo )
            {
                Utils.showError( "Per favore compilare tutti i campi." );
                return false;
            }

            data.tipo = $( "#tipo_messaggio" ).val();
            data.mittente = $( "#mittente" ).val();
            data.destinatari = destinatari;
            data.oggetto = encodeURIComponent( oggetto );
            data.testo = encodeURIComponent( testo );

            if ( this.conversazione_in_lettura )
            {
                data.id_risposta = this.conversazione_in_lettura[0].id_messaggio;
                data.id_conversazione = this.conversazione_in_lettura[0].id_conversazione;
            }

            data.mittente_text = $( "#mittente" ).find( "option:selected" ).text().replace( "Da: ", "" );

            if ( data.tipo === "ig" )
                this.mostraConfermaInvio( data );
            else
                this.inviaDatiMessaggio( data );
        },

        recuperaConversazione: function ( idconv, tipo )
        {
            var dati = {
                mexid: idconv,
                tipo: tipo
            };

            Utils.requestData(
                Constants.API_GET_CONVERSAZIONE,
                "POST",
                dati,
                function ( data )
                {
                    this.mostraConversazione( data.result );
                }.bind( this )
            );
        },

        nuovoBoxAppare: function ( cosa, e )
        {
            this.aggiornaDati();

            if ( !cosa.is( $( "#leggi_messaggio" ) ) )
                this.liberaSpazioMessaggio();

            if ( cosa.is( $( "#scrivi_messaggio" ) ) )
                this.impostaInterfacciaScrittura();

            if ( e && !$( e.target ).is( $( "#rispondi_messaggio" ) ) && !cosa.is( $( "#leggi_messaggio" ) ) )
                this.risettaMessaggio();
        },

        mostra: function ( cosa, e )
        {
            this.visibile_ora = cosa;
            this.visibile_ora.removeClass( "inizialmente-nascosto" ).fadeIn( 400 );

            this.nuovoBoxAppare( cosa, e );
        },

        vaiA: function ( dove, force, e )
        {
            if ( this.visibile_ora.is( dove ) && !force )
                return false;
            else if ( this.visibile_ora.is( $( "#scrivi_messaggio" ) ) )
                this.resettaInputDestinatari();

            var target = e ? $( e.target ) : null;

            $( ".active" ).removeClass( "active" );

            if ( target && target.is( "a" ) )
                target.parent().addClass( "active" );
            else if ( target && !target.is( "a" ) )
                target.addClass( "active" );

            this.visibile_ora.fadeOut( 400, this.mostra.bind( this, dove, e ) );
        },

        controllaStorage: function ()
        {
            var scrivi_a = window.localStorage.getItem( "scrivi_a" );

            if ( scrivi_a )
            {
                var dati = JSON.parse( scrivi_a ),
                    sp = dati.id.split( "#" ),
                    tipo = sp[0],
                    id_dest = sp[1],
                    id_mitt = 0;

                window.localStorage.removeItem( "scrivi_a" );

                if ( tipo === "ig" && !this.pg_info )
                    id_mitt = null;
                else if ( tipo === "ig" && this.pg_info )
                    id_mitt = this.pg_info.id_personaggio;
                else if ( tipo === "fg" )
                    id_mitt = this.user_info.email_giocatore;

                if ( ( tipo === "ig" && this.user_info && this.user_info.pg_propri.length > 0 && this.user_info.pg_propri.indexOf( id ) !== -1 )
                    || ( tipo === "fg" && this.user_info.email_giocatore === id ) )
                {
                    Utils.showError( "Non puoi mandare messaggi a te stesso o ai tuoi personaggi.", Utils.redirectTo.bind( this, Constants.MAIN_PAGE ) );
                    return;
                }

                this.conversazione_in_lettura = [{
                    id_mittente: id_dest,
                    id_destinatario: id_mitt,
                    tipo: tipo,
                    mittente: dati.nome
                }];

                this.vaiA( $( "#scrivi_messaggio" ), false, null );
            }
        },

        filtraMessaggiIG: function ( e ) 
        {
            var table_id = $( e.currentTarget ).parents( ".box-body" ).find( "table" ).attr( "id" );

            if ( table_id === "lista_ig_table" )
                this.tab_ig.draw();
        },

        setListeners: function ()
        {
            $( "#vaia_fg" ).click( this.vaiA.bind( this, $( "#lista_fg" ), false ) );
            $( "#vaia_ig" ).click( this.vaiA.bind( this, $( "#lista_ig" ), false ) );
            $( "#vaia_scrivi" ).click( this.vaiA.bind( this, $( "#scrivi_messaggio" ), false ) );
            $( "#rispondi_messaggio" ).click( this.vaiA.bind( this, $( "#scrivi_messaggio" ), false ) );

            $( '.iradio' ).iCheck( {
                radioClass: 'iradio_square-blue',
                labelHover: true
            } ).on( "ifChecked", this.filtraMessaggiIG.bind( this ) );
        }
    }
}();

$( function ()
{
    MessaggingManager.init();
} );
