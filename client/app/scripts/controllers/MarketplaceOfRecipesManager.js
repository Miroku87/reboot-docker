var MarketplaceManager = function ()
{
    return {
        init: function ()
        {
            $( "#box_carrello" ).width( $( "#box_carrello" ).parent().width() );
            $( "#box_carrello" ).css( "max-height", $( ".content-wrapper" ).height() - 41 - 51 - 20 );
            //$( "#sconto_msg" ).text( $( "#sconto_msg" ).text().replace( /\{X}/g, Constants.CARTELLINI_PER_PAG ).replace( /\{Y}/g, Constants.SCONTO_MERCATO ) );

            this.pg_info = JSON.parse( window.localStorage.getItem( "logged_pg" ) );
            this.placeholder_credito = $( "#riga_credito" ).find( "td:nth-child(2)" ).html();
            this.carrello_oggetti = {};

            if ( !this.pg_info )
            {
                $( "#paga" ).wrap( "<div data-toggle='tooltip' data-title='Devi essere loggato con un personaggio.'></div>" );
                $( "#paga" ).attr( "disabled", true );
            }

            this.setListeners();
            this.impostaTabellaRicette();
        },

        mostraCreditoResiduo: function ( e )
        {
            if ( this.pg_info )
                $( "#riga_credito" ).find( "td:nth-child(2)" ).html( this.pg_info.credito_personaggio + "  <i class='fa fa-btc'></i>" );
        },

        nascondiCreditoResiduo: function ( e )
        {
            $( "#riga_credito" ).find( "td:nth-child(2)" ).html( this.placeholder_credito );
        },

        faiPartireStampa: function ( e )
        {
            $( "#pagina_stampa" )[0].contentWindow.print();
        },

        prendiDatiPGAggiornati: function ( dati_pg )
        {
            this.pg_info = dati_pg;
        },

        stampa: function ( dati_pg )
        {
            AdminLTEManager.aggiornaDatiPG( this.prendiDatiPGAggiornati.bind( this ) );
            Utils.resetSubmitBtn();

            var page = $( $( "#pagina_stampa" )[0].contentDocument ).find( "body" ),
                totale = $( "#riga_totale > td:nth-child(2)" ).text(),
                data = ( new Date() ).toLocaleString( 'it-IT', { timeZone: 'UTC' } ),
                codice = Utils.generaCodiceAntiFrode(),
                prodotti = $( "#carrello tr" )
                    .toArray()
                    .filter( function ( el ) { return !isNaN( parseInt( $( el ).attr( "id" ), 10 ) ); } )
                    .map( function ( el )
                    {
                        return {
                            nome: $( el ).find( "td:nth-of-type(1)" ).text(),
                            qta: parseInt( $( el ).find( "td:nth-of-type(2)" ).text(), 10 ),
                            costo: parseInt( $( el ).find( "td:nth-of-type(3)" ).text(), 10 )
                        };
                    } );

            page.find( ".data_ordine" ).text( data );
            page.find( ".numero_ordine" ).text( codice );
            page.find( ".totale_ordine" ).text( totale + " Bit" );

            page.find( ".template-articolo" ).parent().find( "tr" ).not( ".template-articolo" ).remove();

            for ( var p in prodotti )
            {
                var riga = page.find( ".template-articolo" ).clone();
                riga.removeClass( "template-articolo" );
                riga.css( "display", "table-row" )
                riga.find( ".nome_articolo" ).text( prodotti[p].nome );
                riga.find( ".qta_articolo" ).text( prodotti[p].qta );
                riga.find( ".costo_articolo" ).text( prodotti[p].costo + " Bit" );

                page.find( ".template-articolo" ).parent().append( riga );
            }

            setTimeout( function ()
            {
                this.faiPartireStampa();
            }.bind( this ), 200 );
        },

        paga: function ( e )
        {
            if ( Object.keys( this.carrello_oggetti ).length === 0 )
            {
                Utils.showError( "Non ci sono articoli nel carrello." );
                return false;
            }

            Utils.requestData(
                Constants.API_COMPRA_OGGETTI,
                "POST",
                { ids: this.carrello_oggetti },
                "Pagamento avvenuto con successo.<br>Premi 'CHIUDI' per stampare la ricevuta.",
                null,
                this.stampa.bind( this )
            );
        },

        // controllaQtaPerSconto: function ()
        // {
        //     var qta_tot = $( "#carrello tr:not(tr[id*='riga']) > td:nth-child(2)" )
        //         .toArray()
        //         .map( function ( el ) { return parseInt( el.innerText, 10 ) || 0; } )
        //         .reduce( function ( acc, val ) { return acc + val; } ),
        //         sconto = qta_tot % Constants.QTA_PER_SCONTO_MERCATO === 0 ? Constants.SCONTO_MERCATO : 0;

        //     $( "#riga_sconto > td:nth-child(2)" ).text( sconto + "%" );
        // },

        calcolaTotaleCarrello: function ()
        {
            var sconto = 0,//parseInt( $( "#riga_sconto > td:nth-child(2)" ).text(), 10 ) / 100 || 0,
                tot = $( "#carrello tr > td:nth-child(3)" )
                    .toArray()
                    .map( function ( el ) { return parseInt( el.innerText, 10 ) || 0; } )
                    .reduce( function ( acc, val ) { return acc + val; } ),
                tot_scontato = tot - ( tot * sconto );

            $( "#riga_totale > td:nth-child(2)" ).text( tot_scontato );
        },

        aumentaQtaProdotto: function ( e )
        {
            var t = $( e.target ),
                riga = t.parents( "tr" ),
                id_prodotto = riga.find( "td:nth-child(1)" ).text().replace( /\D/g, "" ),
                qta = parseInt( riga.find( "td:nth-child(2)" ).text(), 10 ) || 0,
                vecchio_tot = parseInt( riga.find( "td:nth-child(3)" ).text(), 10 ) || 0,
                costo = vecchio_tot / qta,
                indice = Utils.indexOfArrayOfObjects( this.carrello_oggetti, "id", id_prodotto );

            riga.hide();
            riga.find( "td:nth-child(2)" ).text( qta + 1 );
            riga.find( "td:nth-child(3)" ).text( vecchio_tot + costo );
            riga.show( 500 );

            if ( this.carrello_oggetti[id_prodotto] )
                this.carrello_oggetti[id_prodotto]++;
            else
                this.carrello_oggetti[id_prodotto] = 1;

            //this.controllaQtaPerSconto();
            this.calcolaTotaleCarrello();
        },

        diminuisciQtaProdotto: function ( e )
        {
            var t = $( e.target ),
                riga = t.parents( "tr" ),
                id_prodotto = riga.find( "td:nth-child(1)" ).text().replace( /\D/g, "" ),
                qta = parseInt( riga.find( "td:nth-child(2)" ).text(), 10 ) || 0,
                vecchio_tot = parseInt( riga.find( "td:nth-child(3)" ).text(), 10 ) || 0,
                costo = vecchio_tot / qta;

            if ( qta - 1 <= 0 )
                riga.remove();
            else
            {
                riga.hide();
                riga.find( "td:nth-child(2)" ).text( qta - 1 );
                riga.find( "td:nth-child(3)" ).text( vecchio_tot - costo );
                riga.show( 500 );
            }

            if ( this.carrello_oggetti[id_prodotto] && this.carrello_oggetti[id_prodotto] > 1 )
                this.carrello_oggetti[id_prodotto]--;
            else if ( this.carrello_oggetti[id_prodotto] && this.carrello_oggetti[id_prodotto] === 1 )
                delete this.carrello_oggetti[id_prodotto];

            //this.controllaQtaPerSconto();
            this.calcolaTotaleCarrello();
        },

        impostaPulsantiCarrello: function ()
        {
            $( "td > button.add-item" ).unbind( "click" );
            $( "td > button.add-item" ).click( this.aumentaQtaProdotto.bind( this ) );

            $( "td > button.remove-item" ).unbind( "click" );
            $( "td > button.remove-item" ).click( this.diminuisciQtaProdotto.bind( this ) );
        },

        oggettoInCarrello: function ( e )
        {
            var t = $( e.target ),
                datatable = this[t.parents( "table" ).attr( "id" )],
                dati = datatable.row( t.parents( "tr" ) ).data(),
                id_prodotto = dati.id_ricetta,
                costo = parseInt( dati.costo_attuale_ricetta, 10 ),
                col_car = $( "#carrello" ).find( "#" + id_prodotto + " td:first-child" );

            if ( col_car.length === 0 )
            {
                var riga = $( "<tr></tr>" );
                riga.attr( "id", id_prodotto );
                riga.append( "<td>" + id_prodotto + " - " + dati.nome_ricetta + "</td>" );
                riga.append( "<td>1</td>" );
                riga.append( "<td>" + costo + "</td>" );
                riga.append(
                    $( "<td></td>" )
                        .append( "<button type='button' class='btn btn-xs btn-default remove-item'><i class='fa fa-minus'></i></button>" )
                        .append( "&nbsp;" )
                        .append( "<button type='button' class='btn btn-xs btn-default add-item'><i class='fa fa-plus'></i></button>" )
                );
                riga.hide();

                $( "#riga_totale" ).before( riga );
                riga.show( 500 );

                this.carrello_oggetti[id_prodotto] = 1;
            }
            else
                this.aumentaQtaProdotto( { target: col_car } );

            //this.controllaQtaPerSconto();
            this.calcolaTotaleCarrello();
            this.impostaPulsantiCarrello();
        },

        setGridListeners: function ()
        {
            AdminLTEManager.controllaPermessi();

            $( "td [data-toggle='popover']" ).popover( "destroy" );
            $( "td [data-toggle='popover']" ).popover();

            $( "[data-toggle='tooltip']" ).tooltip( "destroy" );
            $( "[data-toggle='tooltip']" ).tooltip();

            $( "td > button.carrello" ).unbind( "click" );
            $( "td > button.carrello" ).click( this.oggettoInCarrello.bind( this ) );
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

        renderVariazioni: function ( data, type, row )
        {
            var variazione = 0,
                caret = "left",
                text_color = "yellow";

            if ( row.costo_vecchio_ricetta && parseInt( row.costo_vecchio_ricetta ) !== 0 )
                variazione = ( ( parseInt( row.costo_attuale_ricetta ) - parseInt( row.costo_vecchio_ricetta ) ) / parseInt( row.costo_vecchio_ricetta ) ) * 100;
            else
                variazione = 100;

            if ( variazione > 0 )
            {
                caret = "up";
                text_color = "red";
            }
            else if ( variazione < 0 )
            {
                caret = "down";
                text_color = "green";
            }

            return "<span class='description-percentage text-" + text_color + "'>" +
                "<i class='fa fa-caret-" + caret + "'></i> " + variazione.toFixed( 2 ) + " %</span>";
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

        renderAzioni: function ( data, type, row )
        {
            var pulsanti = "";

            pulsanti += "<button type='button' " +
                "class='btn btn-xs btn-default carrello' " +
                "data-toggle='tooltip' " +
                "data-placement='top' " +
                "title='Aggiungi al Carrello'><i class='fa fa-cart-plus'></i></button>";

            return pulsanti;
        },

        impostaTabellaRicette: function ()
        {
            var columns = [];

            columns.push( {
                title: "Nome Oggetto",
                data: "nome_ricetta"
            } );
            columns.push( {
                title: "Tipo",
                data: "tipo_ricetta"
            } );
            columns.push( {
                title: "Effetto&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                data: "risultato_ricetta",
                render: this.renderRisultati.bind( this )
            } );
            columns.push( {
                title: "Qta Disponibili",
                data: "disponibilita_ravshop_ricetta"
            } );
            columns.push( {
                title: "Costo",
                data: "costo_attuale_ricetta"
            } );
            columns.push( {
                title: "Variazioni",
                render: this.renderVariazioni.bind( this ),
                orderable: false
            } );
            columns.push( {
                title: "Azioni",
                render: this.renderAzioni.bind( this )
            } );

            this.tabella_ricette = $( '#tabella_ricette' )
                .on( "error.dt", this.erroreDataTable.bind( this ) )
                .on( "draw.dt", this.setGridListeners.bind( this ) )
                .DataTable( {
                    language: Constants.DATA_TABLE_LANGUAGE,
                    ajax: function ( data, callback )
                    {
                        Utils.requestData(
                            Constants.API_GET_RICETTE_PER_RAVSHOP,
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

        pageResize: function ()
        {
            $( "#box_carrello" ).width( $( "#box_carrello" ).parent().width() );
        },

        setListeners: function ()
        {
            $( window ).resize( this.pageResize.bind( this ) );
            $( "#paga" ).click( this.paga.bind( this ) );
            $( "#riga_credito" ).find( "td:nth-child(2)" ).mousedown( this.mostraCreditoResiduo.bind( this ) );
            $( document ).mouseup( this.nascondiCreditoResiduo.bind( this ) );
        }
    };
}();

$( function ()
{
    MarketplaceManager.init();
} );

