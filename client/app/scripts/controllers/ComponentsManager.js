/**
 * Created by Miroku on 11/03/2018.
 */
var ComponentsManager = function ()
{
    return {
        init: function ()
        {
            this.componenti_selezionati = {};

            this.setListeners();
            this.impostaTabellaTecnico();
            this.impostaTabellaChimico();
        },

        resettaContatori: function ( e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" );

            this.componenti_selezionati[table_id] = {};
            window.localStorage.removeItem( "componenti_da_stampare" );

            $( "#" + table_id ).find( "input[type='number']" ).val( 0 );
        },

        stampaCartellini: function ( e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" ),
                componenti = this.componenti_selezionati[table_id];

            if ( Object.keys( componenti ).length === 0 )
            {
                var tipo_comp = table_id.replace( "tabella_", "" );
                Utils.showError( "Non è stato selezionato nessun componente " + tipo_comp + " da stampare." );
                return false;
            }

            window.localStorage.removeItem( "cartellini_da_stampare" );
            window.localStorage.setItem( "cartellini_da_stampare", JSON.stringify( { componente_crafting: componenti } ) );
            window.open( Constants.STAMPA_CARTELLINI_PAGE, "Stampa Oggetti" );
        },

        creaComponente: function ( tipo, e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" ),
                datatable = this[table_id],
                dati = datatable.row( t.parents( "tr" ) ).data();

            $( "#modal_modifica_componente_" + table_id ).find( "form" ).trigger( "reset" );
            $( "#modal_modifica_componente_" + table_id ).find( "form" ).removeClass( "new-component", "edit-component" );
            $( "#modal_modifica_componente_" + table_id ).find( "form" ).addClass( "new-component" );
            $( "#modal_modifica_componente_" + table_id ).find( "[name='id_componente']" ).parents( ".form-group" ).removeClass( "inizialmente-nascosto" );
            $( "#modal_modifica_componente_" + table_id ).find( '.icheck input[type="checkbox"]' ).iCheck( "destroy" );
            $( "#modal_modifica_componente_" + table_id ).find( '.icheck input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
            $( "#modal_modifica_componente_tabella_tecnico" ).find( "[name='tipo_componente']" ).trigger( "change" );
            $( "#modal_modifica_componente_" + table_id ).find( ".compat_attuali" ).html( "" );
            $( "#modal_modifica_componente_" + table_id ).modal( "show" );
        },

        componenteSelezionato: function ( e )
        {
            var t = $( e.target ),
                num = parseInt( t.val(), 10 ),
                table_id = t.parents( "table" ).attr( "id" ),
                datatable = this[table_id],
                dati = datatable.row( t.parents( "tr" ) ).data();

            if ( num > 0 )
                this.componenti_selezionati[table_id][dati.id_componente] = num;
            else
                delete this.componenti_selezionati[table_id][dati.id_componente];
        },

        selezionaComponente: function ( e )
        {
            $( "input[type='number']" ).val( 0 );

            for ( var t in this.componenti_selezionati )
                for ( var c in this.componenti_selezionati[t] )
                    $( "#ck_" + c ).val( this.componenti_selezionati[t][c] );
        },

        renderAzioni: function ( data, type, row )
        {
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

        renderCheckStampa: function ( data, type, row )
        {
            return "<div class=\"input-group\">" +
                "<input type='number' min='0' step='1' value='0' class='form-control' style='width:70px' id='ck_" + row.id_componente + "'>" +
                "</div>";
        },

        controllaErroriForm: function ( form_obj )
        {
            var errori = [];

            if ( form_obj.id_componente === "" )
                errori.push( "L'ID del componente non pu&ograve; essere vuoto." );
            if ( form_obj.nome_componente === "" )
                errori.push( "Il nome del componente non pu&ograve; essere vuoto." );

            if ( errori.length > 0 )
                Utils.showError( "Sono stati trovati errori durante l'invio dei dati del componente:<br><ol><li>" + errori.join( "</li><li>" ) + "</li></ol>", null, false );

            return errori.length > 0;
        },

        componenteModificato: function ( modal, tabella )
        {
            modal.modal( "hide" );
            tabella.ajax.reload( null, false );
            Utils.resetSubmitBtn();
        },

        inviaNuovoComponente: function ( data, modal, table_id )
        {
            var tosend = data;

            tosend.tipo_crafting_componente = table_id.replace( "tabella_", "" );

            if ( tosend.tipo_applicativo_componente instanceof Array )
                tosend.tipo_applicativo_componente = tosend.tipo_applicativo_componente.join( "," );

            Utils.requestData(
                Constants.API_POST_NUOVO_COMPONENTE,
                "POST",
                { params: tosend },
                "Componente inserito con successo.",
                null,
                this.componenteModificato.bind( this, modal, this[table_id] )
            );
        },

        inviaModificheComponente: function ( data, modal, table_id )
        {
            Utils.requestData(
                Constants.API_POST_EDIT_COMPONENT,
                "POST",
                { id: data.id_componente, modifiche: data },
                "Componente modificato con successo.",
                null,
                this.componenteModificato.bind( this, modal, this[table_id] )
            );
        },

        inviaDati: function ( e )
        {
            var t = $( e.currentTarget ),
                modal = t.parents( ".modal" ),
                table_id = modal.attr( "id" ).replace( "modal_modifica_componente_", "" ),
                form = t.parents( ".modal" ).find( "form" ),
                data = Utils.getFormData( form ),
                isNew = form.hasClass( "new-component" );

            if ( this.controllaErroriForm( data ) )
                return false;

            if ( isNew )
                this.inviaNuovoComponente( data, modal, table_id )
            else
                this.inviaModificheComponente( data, modal, table_id )
        },

        mostraSceltaApplicativo: function ( e )
        {
            var t = $( e.target );

            //if ( t.val() === "applicativo" || t.val() === "struttura" )
            $( "#modal_modifica_componente_tabella_tecnico" ).find( ".tipo_applicativo_componente" ).show( 500 ).removeClass( "inizialmente-nascosto" );
            /*else
            {
                $( "#modal_modifica_componente_tabella_tecnico" ).find( ".tipo_applicativo_componente" ).hide( 500 );
                $( "#modal_modifica_componente_tabella_tecnico" ).find( ".tipo_applicativo_componente option" ).prop( "selected", false )
            }*/
        },

        mostraModalModifica: function ( e )
        {
            var t = $( e.target ),
                table_id = t.parents( "table" ).attr( "id" ),
                datatable = this[table_id],
                dati = datatable.row( t.parents( "tr" ) ).data(),
                modal = $( "#modal_modifica_componente_" + table_id );

            modal.find( "form" )[0].reset();
            modal.find( "form" ).removeClass( "new-component", "edit-component" );
            modal.find( "form" ).addClass( "edit-component" );
            modal.find( "input[type='checkbox']" ).iCheck( "uncheck" );
            modal.find( ".compat_attuali" ).html( "" );

            for ( var d in dati )
            {
                if ( d === "tipo_applicativo_componente" && dati[d] !== null )
                {
                    $.each( dati[d].split( "," ), function ( i, e )
                    {
                        var v = e.replace( "'", "\\'" )
                        modal.find( "[name='" + d + "'] option[value='" + v + "']" ).prop( "selected", true );
                        modal.find( ".compat_attuali" ).append( "<span>" + v + "<br></span>" );
                    } );
                }
                else if ( d === "visibile_ravshop_componente" )
                {
                    var checkState = parseInt( dati[d], 10 ) === 1 ? "check" : "uncheck";
                    modal.find( "[name='" + d + "']" ).iCheck( checkState );
                }
                else
                {
                    var val = /\d+,\d+/.test( dati[d] ) ? parseFloat( dati[d].replace( ",", "." ) ) : dati[d];
                    modal.find( "[name='" + d + "']" ).val( val );
                }
            }
            $( "#modal_modifica_componente_tabella_tecnico" ).find( "[name='tipo_componente']" ).trigger( "change" );
            modal.find( "[name='costo_attuale_componente_old']" ).val( dati.costo_attuale_componente );
            modal.modal( "show" );
        },

        eliminaComponente: function ( id_comp, modal, table_id )
        {
            Utils.requestData(
                Constants.API_POST_REMOVE_COMPONENT,
                "POST",
                { id: id_comp },
                "Componente eliminato con successo.",
                null,
                this.componenteModificato.bind( this, modal, this[table_id] )
            );
        },

        mostraConfermaElimina: function ( e )
        {
            var t = $( e.currentTarget ),
                modal = t.parents( ".modal" ),
                table_id = t.parents( "table" ).attr( "id" ),
                datatable = this[table_id],
                dati = datatable.row( t.parents( "tr" ) ).data();

            Utils.showConfirm( "Sicuro di voler eliminare il componente <strong>" + dati.id_componente + "</strong>?<br>" +
                "ATTENZIONE:<br>Ogni ricetta che contiene questo componente verr&agrave; eliminata a sua volta.", this.eliminaComponente.bind( this, dati.id_componente, modal, table_id ), true );
        },

        setGridListeners: function ()
        {
            AdminLTEManager.controllaPermessi();

            $( "td [data-toggle='popover']" ).popover( "destroy" );
            $( "td [data-toggle='popover']" ).popover();

            $( "[data-toggle='tooltip']" ).tooltip( "destroy" );
            $( "[data-toggle='tooltip']" ).tooltip();

            $( "td > button.modifica" ).unbind( "click" );
            $( "td > button.modifica" ).click( this.mostraModalModifica.bind( this ) );

            $( "td > button.elimina" ).unbind( "click" );
            $( "td > button.elimina" ).click( this.mostraConfermaElimina.bind( this ) );

            $( "td > button.stampa-cartellino" ).unbind( "click", this.stampaCartellini.bind( this ) );
            $( "td > button.stampa-cartellino" ).click( this.stampaCartellini.bind( this ) );

            $( 'input[type="number"]' ).unbind( "change" );
            $( 'input[type="number"]' ).on( "change", this.componenteSelezionato.bind( this ) );

            this.selezionaComponente();
        },

        erroreDataTable: function ( e, settings )
        {
            if ( !settings.jqXHR || !settings.jqXHR.responseText )
            {
                console.log( "DataTable error:", e, settings );
                return false;
            }

            var real_error = settings.jqXHR.responseText.replace( /^([\S\s]*?)\{"[\S\s]*/i, "$1" );
            real_error = real_error.replace( "\n", "<br>" );
            Utils.showError( real_error );
        },

        impostaTabellaTecnico: function ()
        {
            var columns = [];

            this.componenti_selezionati.tabella_tecnico = {};

            columns.push( {
                title: "Stampa",
                render: this.renderCheckStampa.bind( this )
            } );
            columns.push( {
                title: "ID",
                data: "id_componente"
            } );
            columns.push( {
                title: "Nome",
                data: "nome_componente"
            } );
            columns.push( {
                title: "Descrizione",
                data: "descrizione_componente"
            } );
            columns.push( {
                title: "Tipo",
                data: "tipo_componente"
            } );
            columns.push( {
                title: "Energia",
                data: "energia_componente"
            } );
            columns.push( {
                title: "Volume",
                data: "volume_componente"
            } );
            columns.push( {
                title: "Costo",
                data: "costo_attuale_componente"
            } );
            columns.push( {
                title: "Effetti",
                data: "effetto_sicuro_componente"
            } );
            columns.push( {
                title: "Azioni",
                render: this.renderAzioni.bind( this ),
                orderable: false
            } );

            this.tabella_tecnico = $( '#tabella_tecnico' )
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
                            Constants.API_GET_COMPONENTI_AVANZATO,
                            "GET",
                            $.extend( data, { tipo: "tecnico" } ),
                            callback
                        );
                    },
                    columns: columns,
                    order: [[1, 'asc']]
                } );
        },

        impostaTabellaChimico: function ()
        {
            var columns = [];

            this.componenti_selezionati.tabella_chimico = {};

            columns.push( {
                title: "Stampa",
                render: this.renderCheckStampa.bind( this )
            } );
            columns.push( {
                title: "ID",
                data: "id_componente"
            } );
            columns.push( {
                title: "Tipo",
                data: "tipo_componente"
            } );
            columns.push( {
                title: "Nome",
                data: "nome_componente"
            } );
            columns.push( {
                title: "Descrizione",
                data: "descrizione_componente"
            } );
            columns.push( {
                title: "Val Curativo",
                data: "curativo_primario_componente"
            } );
            columns.push( {
                title: "Val Tossico",
                data: "tossico_primario_componente",
                type: "num"
            } );
            columns.push( {
                title: "Val Psicotropo",
                data: "psicotropo_primario_componente",
                type: "num"
            } );
            columns.push( {
                title: "Fattore Dipendeza",
                data: "possibilita_dipendeza_componente",
                type: "num"
            } );
            columns.push( {
                title: "Costo",
                data: "costo_attuale_componente",
                type: "num"
            } );
            columns.push( {
                title: "Azioni",
                render: this.renderAzioni.bind( this ),
                orderable: false
            } );

            this.tabella_chimico = $( '#tabella_chimico' )
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
                            Constants.API_GET_COMPONENTI_AVANZATO,
                            "GET",
                            $.extend( data, { tipo: "chimico" } ),
                            callback
                        );
                    },
                    columns: columns,
                    order: [[1, 'asc']]
                } );
        },

        setListeners: function ()
        {
            $( "#btn_creaComponentiTecnico" ).click( this.creaComponente.bind( this, "tecnico" ) );
            $( "#btn_creaComponentiChimico" ).click( this.creaComponente.bind( this, "chimico" ) );
            $( "#btn_stampaRicetteTecnico" ).click( this.stampaCartellini.bind( this ) );
            $( "#btn_stampaRicetteChimico" ).click( this.stampaCartellini.bind( this ) );
            $( "#btn_resettaContatoriTecnico" ).click( this.resettaContatori.bind( this ) );
            $( "#btn_resettaContatoriChimico" ).click( this.resettaContatori.bind( this ) );
            $( "#btn_invia_modifiche_tabella_tecnico" ).click( this.inviaDati.bind( this ) );
            $( "#btn_invia_modifiche_tabella_chimico" ).click( this.inviaDati.bind( this ) );
            $( "#modal_modifica_componente_tabella_tecnico" ).find( "[name='tipo_componente']" ).on( "change", this.mostraSceltaApplicativo.bind( this ) );

            $( '.icheck input[type="checkbox"]' ).iCheck( "destroy" );
            $( '.icheck input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
        }
    };
}();

$( function ()
{
    ComponentsManager.init();
} );