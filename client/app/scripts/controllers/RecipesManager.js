var RecipesManager = function ()
{

    return {
        init: function ()
        {
            this.ricette_selezionate = { ricetta: {} };

            this.recuperaDatiLocali();
            this.setListeners();
            this.creaDataTable();
        },

        resettaContatori: function ( e )
        {
            for ( var c in this.ricette_selezionate )
                this.ricette_selezionate[c] = {};

            window.localStorage.removeItem( "cartellini_da_stampare" );

            $( "#griglia_ricette" ).find( "input[type='number']" ).val( 0 );
        },

        stampaCartellini: function ( e )
        {
            window.localStorage.removeItem( "cartellini_da_stampare" );
            window.localStorage.setItem( "cartellini_da_stampare", JSON.stringify( this.ricette_selezionate ) );
            window.open( Constants.STAMPA_CARTELLINI_PAGE, "Stampa Cartellini" );
        },

        inviaModificheRicetta: function ( id_ricetta )
        {
            var approv = $( "#modal_modifica_ricetta" ).find( "#approvata" ).val(),
                extra = encodeURIComponent( Utils.stripHMTLTag( $( "#modal_modifica_ricetta" )
                    .find( "#extra_cartellino" )
                    .val() ).replace( /\n/g, "<br>" ) ),
                note = encodeURIComponent( Utils.stripHMTLTag( $( "#modal_modifica_ricetta" ).find( "#note_ricetta" ).val() )
                    .replace( /\n/g, "<br>" ) ),
                dati = {
                    id: id_ricetta,
                    modifiche: {
                        note_ricetta: note,
                        extra_cartellino_ricetta: extra,
                        approvata_ricetta: approv,
                        in_ravshop_ricetta: $( "input[name='pubblico_ricetta']" ).is( ":checked" ) ? 1 : 0
                    }
                };

            if ( dati.modifiche.in_ravshop_ricetta )
            {
                dati.modifiche.costo_attuale_ricetta = $( "input[name='costo_attuale_ricetta']" ).val();
                dati.modifiche.old_costo_attuale_ricetta = $( "input[name='old_costo_attuale_ricetta']" ).val();
                dati.modifiche.disponibilita_ravshop_ricetta = $( "input[name='disponibilita_ricetta']" ).val();
            }

            Utils.requestData(
                Constants.API_EDIT_RICETTA,
                "POST",
                dati,
                "Modifiche apportate con successo",
                null,
                this.recipes_grid.ajax.reload.bind( this, null, false )
            );
        },

        pubblicaSuRavshop: function ( e )
        {
            if ( $( "input[name='pubblico_ricetta']" ).is( ":checked" ) )
            {
                $( "#modal_modifica_ricetta" ).find( ".costo_attuale_ricetta" ).show( 500 ).removeClass( "inizialmente-nascosto" );
                $( "#modal_modifica_ricetta" ).find( ".disponibilita_ricetta" ).show( 500 ).removeClass( "inizialmente-nascosto" );
            }
            else
            {
                $( "#modal_modifica_ricetta" ).find( "input[name='costo_attuale_ricetta']" ).val( 0 );
                $( "#modal_modifica_ricetta" ).find( "input[name='disponibilita_ricetta']" ).val( 1 );
                $( "#modal_modifica_ricetta" ).find( ".costo_attuale_ricetta" ).hide( 500 );
                $( "#modal_modifica_ricetta" ).find( ".disponibilita_ricetta" ).hide( 500 );
            }
        },

        mostraModalRicetta: function ( editMode, e )
        {
            var t = $( e.target ),
                dati = this.recipes_grid.row( t.parents( 'tr' ) ).data(),
                extra = Utils.unStripHMTLTag( decodeURIComponent( dati.extra_cartellino_ricetta ) )
                    .replace( /<br>/g, "\r" ),
                extra = extra === "null" ? "" : extra,
                note = Utils.unStripHMTLTag( decodeURIComponent( dati.note_ricetta ) ).replace( /<br>/g, "\r" ),
                note = note === "null" ? "" : note,
                comps = "<li>" + dati.componenti_ricetta.split( ";" ).join( "</li><li>" ) + "</li>",
                result = dati.risultato_ricetta ? "<li>" + dati.risultato_ricetta.split( ";" )
                    .join( "</li><li>" ) + "</li>" : "<li></li>";

            $( "#modal_modifica_ricetta" ).find( "#nome_ricetta" ).text( dati.nome_ricetta );
            $( "#modal_modifica_ricetta" ).find( "#lista_componenti" ).html( comps );
            $( "#modal_modifica_ricetta" ).find( "#risultato" ).html( result );

            if ( editMode === true )
            {
                $( "#modal_modifica_ricetta" ).find( "#vedi_note_ricetta" ).parent().hide();
                $( "#modal_modifica_ricetta" ).find( "#vedi_extra_cartellino_ricetta" ).parent().hide();

                $( "#modal_modifica_ricetta" ).find( "#approvata" ).val( dati.approvata_ricetta );
                $( "#modal_modifica_ricetta" ).find( "#extra_cartellino" ).val( extra );
                $( "#modal_modifica_ricetta" ).find( "#note_ricetta" ).val( note );

                $( "#modal_modifica_ricetta" ).find( "#btn_invia_modifiche_ricetta" ).unbind( "click" );
                $( "#modal_modifica_ricetta" )
                    .find( "#btn_invia_modifiche_ricetta" )
                    .click( this.inviaModificheRicetta.bind( this, dati.id_ricetta ) );

                $( "#modal_modifica_ricetta" ).find( "input[name='pubblico_ricetta']" ).iCheck( parseInt( dati.in_ravshop_ricetta, 10 ) === 1 ? "check" : "uncheck" ).trigger( "change" );
                $( "#modal_modifica_ricetta" ).find( "input[name='costo_attuale_ricetta']" ).val( dati.costo_attuale_ricetta );
                $( "#modal_modifica_ricetta" ).find( "input[name='old_costo_attuale_ricetta']" ).val( dati.costo_attuale_ricetta );
                $( "#modal_modifica_ricetta" ).find( "input[name='disponibilita_ricetta']" ).val( dati.disponibilita_ravshop_ricetta );

                $( "#modal_modifica_ricetta" ).find( "form" ).show();
                $( "#modal_modifica_ricetta" ).find( "#btn_invia_modifiche_ricetta" ).show();
            }
            else if ( editMode === false )
            {
                $( "#modal_modifica_ricetta" ).find( "#vedi_note_ricetta" ).html( dati.note_ricetta ).show();
                $( "#modal_modifica_ricetta" ).find( "#vedi_extra_cartellino_ricetta" ).html( dati.extra_cartellino_ricetta ).show();

                $( "#modal_modifica_ricetta" ).find( "form" ).hide();
                $( "#modal_modifica_ricetta" ).find( "#btn_invia_modifiche_ricetta" ).hide();
            }

            $( "#modal_modifica_ricetta" ).modal( { drop: "static" } );
        },

        ricettaSelezionata: function ( e )
        {
            var t = $( e.target ),
                num = parseInt( t.val(), 10 ),
                dati = this.recipes_grid.row( t.parents( "tr" ) ).data(),
                tipo = "ricetta";

            if ( num > 0 )
                this.ricette_selezionate[tipo][dati.id_ricetta] = num;
            else
                delete this.ricette_selezionate[tipo][dati.id_ricetta];
        },

        selezionaRicette: function ( e )
        {
            $( "input[type='text']" ).val( 0 );

            for ( var tipo in this.ricette_selezionate )
                for ( var id in this.ricette_selezionate[tipo] )
                    $( "#ck_" + r ).val( this.ricette_selezionate[tipo][id] );
        },

        rifiutaRicetta: function ( dati )
        {
            Utils.requestData(
                Constants.API_EDIT_RICETTA,
                "POST",
                { id: dati.id_ricetta, modifiche: { "approvata_ricetta": -1 } },
                "Ricetta rifiutata con successo.",
                null,
                this.recipes_grid.ajax.reload.bind( this, null, false )
            );
        },

        approvaRicetta: function ( dati )
        {
            Utils.requestData(
                Constants.API_EDIT_RICETTA,
                "POST",
                { id: dati.id_ricetta, modifiche: { "approvata_ricetta": 1 } },
                "Ricetta approvata con successo.",
                null,
                this.recipes_grid.ajax.reload.bind( this, null, false )
            );
        },

        confermaRifiutaRicetta: function ( e )
        {
            var t = $( e.target ),
                dati = this.recipes_grid.row( t.parents( 'tr' ) ).data();

            Utils.showConfirm( "Sicuro di voler rifiutare questa ricetta?", this.rifiutaRicetta.bind( this, dati ) );
        },

        confermaApprovaRicetta: function ( e )
        {
            var t = $( e.target ),
                dati = this.recipes_grid.row( t.parents( 'tr' ) ).data();

            Utils.showConfirm( "Sicuro di voler approvare questa ricetta?", this.approvaRicetta.bind( this, dati ) );
        },

        setGridListeners: function ()
        {
            AdminLTEManager.controllaPermessi();

            $( "td [data-toggle='popover']" ).popover( "destroy" );
            $( "td [data-toggle='popover']" ).popover();

            $( 'input[type="number"]' ).unbind( "change" );
            $( 'input[type="number"]' ).on( "change", this.ricettaSelezionata.bind( this ) );

            $( "[data-toggle='tooltip']" ).tooltip();

            $( "button.modifica-note" ).unbind( "click", this.mostraModalRicetta.bind( this, true ) );
            $( "button.modifica-note" ).click( this.mostraModalRicetta.bind( this, true ) );

            $( "button.dettagli-ricetta" ).unbind( "click", this.mostraModalRicetta.bind( this, false ) );
            $( "button.dettagli-ricetta" ).click( this.mostraModalRicetta.bind( this, false ) );

            $( "button.rifiuta-ricetta" ).unbind( "click", this.confermaRifiutaRicetta.bind( this ) );
            $( "button.rifiuta-ricetta" ).click( this.confermaRifiutaRicetta.bind( this ) );

            $( "button.approva-ricetta" ).unbind( "click", this.confermaApprovaRicetta.bind( this ) );
            $( "button.approva-ricetta" ).click( this.confermaApprovaRicetta.bind( this ) );

            this.selezionaRicette();
        },

        erroreDataTable: function ( e, settings )
        {
            if ( !settings.jqXHR || !settings.jqXHR.responseText )
            {
                console.log( e, settings );
                return false;
            }

            var real_error = settings.jqXHR.responseText.replace( /^([\S\s]*?)\{"[\S\s]*/i, "$1" );
            real_error = real_error.replace( "\n", "<br>" );
            Utils.showError( real_error );
        },

        renderRisultati: function ( data, type, row )
        {
            if ( data )
            {
                var ret = data.split( ";" ).join( "<br>" );

                if ( row.id_unico_risultato_ricetta !== null )
                    ret = row.tipo_ricetta.substr( 0, 1 )
                        .toUpperCase() + Utils.pad( row.id_unico_risultato_ricetta, Constants.ID_RICETTA_PAG ) + "<br>" + ret;

                return ret;
            }
            else
                return "";
        },

        renderComps: function ( data, type, row )
        {
            var ret = data;

            if ( row.tipo_ricetta === "Programmazione" )
                ret = data.replace( /Z\=(\d);\s/g, "Z=$1<br>" );
            else
                ret = data.replace( /;/g, "<br>" );

            return ret;
        },

        renderNote: function ( data, type, row )
        {
            var denc_data = Utils.unStripHMTLTag( decodeURIComponent( data ) );
            denc_data = denc_data === "null" ? "" : denc_data;

            return $.fn.dataTable.render.ellipsis( 20, false, true, true )( denc_data, type, row );
        },

        renderApprovato: function ( data, type, row )
        {
            var ret = "In elaborazione...",
                data = parseInt( data );

            if ( data === -1 )
                ret = "Rifiutato";
            else if ( data === 1 )
                ret = "Approvato";

            return ret;
        },

        renderGiaStampata: function ( data, type, row )
        {
            var stampata = parseInt( row.gia_stampata, 10 ) === 1,
                checked = stampata ? "checked" : "";

            return stampata ? "S&Igrave;" : "NO";
        },

        renderCheckStampa: function ( data, type, row )
        {
            return "<div class=\"input-group\">" +
                "<input type='number' min='0' step='1' value='0' class='form-control' id='ck_" + row.id_ricetta + "'>" +
                "</div>";
        },

        creaPulsantiAzioni: function ( data, type, row )
        {
            var pulsanti = "";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default dettagli-ricetta modificaRicetta ' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Dettagli Ricetta'><i class='fa fa-eye'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default modifica-note modificaRicetta ' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Modifica Note'><i class='fa fa-pencil'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default inizialmente-nascosto modificaRicetta rifiuta-ricetta' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Rifiuta Ricetta'><i class='fa fa-remove'></i></button>";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default inizialmente-nascosto modificaRicetta  approva-ricetta' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Approva Ricetta'><i class='fa fa-check'></i></button>";

            return pulsanti;
        },

        creaDataTable: function ()
        {
            var columns = [];

            columns.push( {
                title: "Stampa",
                render: this.renderCheckStampa.bind( this )
            } );

            columns.push( {
                title: "Gi&agrave; Stampata",
                render: this.renderGiaStampata.bind( this )
            } );
            columns.push( {
                title: "Giocatore",
                data: "nome_giocatore"
            } );
            columns.push( {
                title: "Personaggio",
                data: "nome_personaggio"
            } );
            columns.push( {
                title: "Data Creazione",
                data: "data_inserimento_it"
            } );
            columns.push( {
                title: "Nome Ricetta",
                data: "nome_ricetta"
            } );
            columns.push( {
                title: "Tipo",
                data: "tipo_ricetta"
            } );
            columns.push( {
                title: "Qta In Ravshop",
                data: "disponibilita_ravshop_ricetta"
            } );
            columns.push( {
                title: "Costo Ravshop",
                data: "costo_attuale_ricetta"
            } );
            columns.push( {
                title: "Azioni",
                render: this.creaPulsantiAzioni.bind( this )
            } );

            this.recipes_grid = $( '#griglia_ricette' )
                .on( "error.dt", this.erroreDataTable.bind( this ) )
                .on( "draw.dt", this.setGridListeners.bind( this ) )
                .DataTable( {
                    processing: true,
                    serverSide: true,
                    dom: "<'row'<'col-sm-6'lB><'col-sm-6'f>>" +
                        "<'row'<'col-sm-12 table-responsive'tr>>" +
                        "<'row'<'col-sm-5'i><'col-sm-7'p>>",
                    buttons: ["reload"],
                    language: Constants.DATA_TABLE_LANGUAGE,
                    ajax: function ( data, callback )
                    {
                        Utils.requestData(
                            Constants.API_GET_RICETTE,
                            "GET",
                            data,
                            callback
                        );
                    },
                    columns: columns,
                    //lengthMenu: [ 5, 10, 25, 50, 75, 100 ],
                    order: [[2, 'desc']]
                } );
        },

        recuperaDatiLocali: function ()
        {
            this.user_info = JSON.parse( window.localStorage.getItem( "user" ) );
        },

        setListeners: function ()
        {
            $( 'input[type="checkbox"]' ).iCheck( "destroy" );
            $( 'input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
            $( "[data-toggle='tooltip']" ).tooltip();
            $( "input[name='pubblico_ricetta']" ).on( "ifChanged", this.pubblicaSuRavshop.bind( this ) );

            $( "#btn_stampaRicette" ).click( this.stampaCartellini.bind( this ) );
            $( "#btn_resettaContatoriTecnico" ).click( this.resettaContatori.bind( this ) );
        }
    };
}();

$( function ()
{
    RecipesManager.init();
} );
