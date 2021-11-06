/**
 * Created by Miroku on 11/03/2018.
 */
var ComponentsManager = function ()
{
    var SEPARATORE = "££";

    return {
        init: function ()
        {
            this.componenti_selezionati = {};
            this.componenti_da_modificare = {}

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

        resettaBulkEdit: function ( e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" );

            this.componenti_da_modificare[table_id] = {};

            $( "#" + table_id ).find( ".icheck" ).iCheck( "uncheck" );
        },

        apriBulkEdit: function ( e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" );

            if ( Object.keys( this.componenti_da_modificare[table_id] ).length > 1 )
                this.mostraModalModifica( e, true );
            else
                Utils.showMessage( "Bisogna spuntare almeno 2 componenti." );
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
                dati = datatable.row( t.parents( "tr" ) ).data(),
                modal = $( "#modal_modifica_componente_" + table_id );

            modal.find( "form" ).addClass( "new-component" );
            modal.modal( "show" );
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

        renderTipoApp: function ( data )
        {
            if ( data !== null )
                return data.replaceAll( ",", ", " )
            else
                return data
        },

        renderAzioni: function ()
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
            var errori = [],
                is_bulk_edit = form_obj.bulk_edit === "true";

            if ( form_obj.id_componente === "" && !is_bulk_edit )
                errori.push( "L'ID del componente non pu&ograve; essere vuoto." );
            if ( form_obj.nome_componente === "" && !is_bulk_edit )
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

            delete tosend.old_id
            delete tosend.bulk_edit

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
            var id = data.old_id,
                url = Constants.API_POST_EDIT_COMPONENT,
                msg = "Componente modificato con successo.",
                dati = this.componenti_da_modificare[table_id];

            if ( data.bulk_edit === "true" && Object.keys( dati ).length > 0 )
            {
                id = Object.keys( dati ).map( function ( id ) { return id + SEPARATORE + dati[id].nome_componente } );
                url = Constants.API_POST_BULK_EDIT_COMPONENTS;
                comps = Object.keys( dati ).map(
                    function ( id )
                    {
                        return dati[id].nome_componente + " (" + id + ")";
                    }
                );

                msg = "I seguenti componenti sono stati modificati con successo:<br>" + comps.join( ", " )

                delete data.bulk_edit
                delete data.id_componente
                delete data.nome_componente
                delete data.descrizione_componente
            }

            delete data.old_id
            delete data.bulk_edit

            Utils.requestData(
                url,
                "POST",
                { id: id, modifiche: data },
                msg,
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
                data = Utils.getFormData( form, true ),
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

            $( "#modal_modifica_componente_tabella_tecnico" )
                .find( ".tipo_applicativo_componente" )
                .show( 500 )
                .removeClass( "inizialmente-nascosto" );
        },

        recuperaListaCompSpuntati: function ( table_id )
        {
            return Object.keys( this.componenti_da_modificare[table_id] ).map(
                function ( id )
                {
                    return this.componenti_da_modificare[table_id][id].nome_componente + " (" + id + "), ";
                }.bind( this ) ).join( ", " );
        },

        recuperaIDCompSpuntati: function ( table_id, prefix )
        {
            return Object.keys( this.componenti_da_modificare[table_id] ).map(
                function ( id )
                {
                    return prefix + id
                } );
        },

        onModalHide: function ( e ) 
        {
            var modal = $( e.target );

            modal.find( "form" ).trigger( "reset" );
            modal.find( "form" ).removeClass( "new-component", "edit-component" );
            modal.find( "input[type='checkbox']" ).iCheck( "uncheck" );
            modal.find( ".compat_attuali" ).html( "" );
            modal.find( ".form-group" ).show()
            modal.find( ".bulk-edit-msg" ).hide();
            modal.find( ".bulk-edit-msg .lista-componenti" ).text( "" )
            modal.find( "input[name='bulk_edit']" ).val( "false" )
            modal.find( "input[name='old_id']" ).val( "" )

            modal.find( '.icheck input[type="checkbox"]' ).iCheck( "destroy" );
            modal.find( '.icheck input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );
            modal.find( "[name='tipo_componente']" ).trigger( "change" );
        },

        riempiCampiModifica: function ( modal, dati )
        {
            modal.find( "input[name='old_id']" ).val( dati.id_componente )

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
                    if ( dati[d] == "" )
                    {
                        modal.find( "[name='" + d + "']" ).val("")
                        modal.find( "[name='" + d + "']" ).attr("placeholder","[valori differenti]")
                    } 
                    else 
                    {
                        var val = /\d+,\d+/.test( dati[d] ) ? parseFloat( dati[d].replace( ",", "." ) ) : dati[d];
                        modal.find( "[name='" + d + "']" ).val( val );
                    }
                }
            }

            modal.find( "[name='costo_attuale_componente_old']" ).val( dati.costo_attuale_componente );
        },

        riempiCampiModificaDiGruppo: function ( modal, dati )
        {
            var primoID = Object.keys( dati )[0],
                valUguali = JSON.parse( JSON.stringify( dati[primoID] ) );

            for ( var campo in valUguali ) 
            {
                var primo = dati[primoID][campo],
                    tuttiUguali = true;

                for ( var d in dati )
                {
                    if ( dati[d][campo] !== primo )
                    {
                        tuttiUguali = false;
                        break;
                    }
                }

                if ( tuttiUguali )
                    valUguali[campo] = primo;
                else
                    valUguali[campo] = "";
            }

            this.riempiCampiModifica( modal, valUguali );
        },

        mostraModalModifica: function ( e, bulk_edit )
        {
            var t = $( e.target ),
                table_id = t.parents( ".box-body" ).find( "table" ).attr( "id" ),
                datatable = this[table_id],
                modal = $( "#modal_modifica_componente_" + table_id ),
                bulk_edit = typeof bulk_edit !== "undefined" ? bulk_edit === true : false;

            modal.find( "form" ).addClass( "edit-component" );

            if ( bulk_edit ) 
            {
                modal.find( "[name='id_componente']" ).parents( ".form-group" ).hide();
                modal.find( "[name='nome_componente']" ).parents( ".form-group" ).hide();
                modal.find( "[name='descrizione_componente']" ).parents( ".form-group" ).hide();
                modal.find( ".bulk-edit-msg .lista-componenti" ).text( this.recuperaListaCompSpuntati( table_id ) )
                modal.find( ".bulk-edit-msg" ).show();
                modal.find( "input[name='bulk_edit']" ).val( "true" )

                this.riempiCampiModificaDiGruppo( modal, this.componenti_da_modificare[table_id] )
            }
            else 
            {
                var dati = datatable.row( t.parents( "tr" ) ).data();
                this.riempiCampiModifica( modal, dati )
            }

            $( "#modal_modifica_componente_tabella_tecnico" ).find( "[name='tipo_componente']" ).trigger( "change" );
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

        salvaComponenteDaModificare: function ( e )
        {
            var t = $( e.currentTarget ),
                table_id = t.parents( "table" ).attr( "id" ),
                datatable = this[table_id],
                dati = datatable.row( t.parents( "tr" ) ).data(),
                key = dati.id_componente;// + SEPARATORE + dati.nome_componente;

            if ( t.is( ":checked" ) )
                this.componenti_da_modificare[table_id][key] = dati
            else
            {
                if ( typeof this.componenti_da_modificare[table_id][key] !== "undefined" )
                    delete this.componenti_da_modificare[table_id][key]
            }
        },

        creaCheckBoxBulkEdit: function ( data, type, row, meta )
        {
            var table_id = meta.settings.sTableId,
                checked = typeof this.componenti_da_modificare[table_id][row.id_componente] !== "undefined" ? "checked" : "";

            return "<div class='checkbox icheck'>" +
                "<input type='checkbox' " +
                "class='modificaComponente' " +
                checked + ">" +
                "</div>";
        },

        setGridListeners: function ()
        {
            AdminLTEManager.controllaPermessi();

            $( 'input[type="checkbox"]' ).iCheck( "destroy" );
            $( 'input[type="checkbox"]' ).iCheck( {
                checkboxClass: 'icheckbox_square-blue'
            } );

            $( "td input.modificaComponente" ).unbind( "ifChanged", this.salvaComponenteDaModificare.bind( this ) );
            $( "td input.modificaComponente" ).on( "ifChanged", this.salvaComponenteDaModificare.bind( this ) );

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

            $( 'td > input[type="number"]' ).unbind( "change" );
            $( 'td > input[type="number"]' ).on( "change", this.componenteSelezionato.bind( this ) );

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
            var columns = [],
                id = "tabella_tecnico";

            this.componenti_da_modificare[id] = {};
            this.componenti_selezionati[id] = {};

            columns.push( {
                title: "Stampa",
                render: this.renderCheckStampa.bind( this )
            } );
            columns.push( {
                title: "Modifica",
                render: this.creaCheckBoxBulkEdit.bind( this ),
                className: 'text-center modificaComponente',
                orderable: false
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
                title: "Tipo App",
                data: "tipo_applicativo_componente",
                render: this.renderTipoApp.bind( this ),
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

            this.tabella_tecnico = $( '#' + id )
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
                    rowId: function ( data )
                    {
                        return 'comp_' + data.id_componente;
                    },
                    order: [[2, 'asc']]
                } );
        },

        impostaTabellaChimico: function ()
        {
            var columns = [],
                id = "tabella_chimico";

            this.componenti_da_modificare[id] = {};
            this.componenti_selezionati[id] = {};

            columns.push( {
                title: "Stampa",
                render: this.renderCheckStampa.bind( this )
            } );
            columns.push( {
                title: "Modifica",
                render: this.creaCheckBoxBulkEdit.bind( this ),
                className: 'text-center modificaComponente',
                orderable: false
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

            this.tabella_chimico = $( '#' + id )
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
                    rowId: function ( data )
                    {
                        return 'comp_' + data.id_componente;
                    },
                    order: [[2, 'asc']]
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
            $( "#btn_apriBulkEditChimico" ).click( this.apriBulkEdit.bind( this ) );
            $( "#btn_apriBulkEditTecnico" ).click( this.apriBulkEdit.bind( this ) );
            $( "#btn_resettaBulkEditChimico" ).click( this.resettaBulkEdit.bind( this ) );
            $( "#btn_resettaBulkEditTecnico" ).click( this.resettaBulkEdit.bind( this ) );

            $( "#modal_modifica_componente_tabella_tecnico" ).find( "[name='tipo_componente']" ).on( "change", this.mostraSceltaApplicativo.bind( this ) );
            $( "#modal_modifica_componente_tabella_tecnico" ).on( "hidden.bs.modal", this.onModalHide.bind( this ) );
            $( "#modal_modifica_componente_tabella_chimico" ).on( "hidden.bs.modal", this.onModalHide.bind( this ) );

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