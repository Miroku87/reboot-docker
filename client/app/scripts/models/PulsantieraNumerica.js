/**
 * Created by Miroku on 29/03/2018.
 */
var PulsantieraNumerica = PulsantieraNumerica || function ()
{
    function PulsantieraNumerica( settings )
    {
        this.settings = { valore_max: Infinity, valore_min: -Infinity };
        this.settings = $.extend( this.settings, settings );
        this.target = $( this.settings.target );
        this.pulsantiera = $( this.settings.pulsantiera );

        if ( !this.target.is( "input[type='number']" ) )
            throw new Error( "Il target deve essere un input di tipo number." );

        _setListeners.call( this );
    }

    PulsantieraNumerica.prototype = Object.create( Object.prototype );
    PulsantieraNumerica.prototype.constructor = PulsantieraNumerica;

    function _aggiungiValore( val )
    {
        var new_val = parseFloat( this.target.val() ) + val;

        if ( new_val > this.settings.valore_max )
            new_val = this.settings.valore_max;

        if ( new_val < this.settings.valore_min )
            new_val = this.settings.valore_min;

        this.target.val( new_val );
    }

    function _setListeners()
    {
        this.pulsantiera.find( ".meno10" ).click( _aggiungiValore.bind( this, -10 ) );
        this.pulsantiera.find( ".meno1" ).click( _aggiungiValore.bind( this, -1 ) );
        this.pulsantiera.find( ".piu1" ).click( _aggiungiValore.bind( this, 1 ) );
        this.pulsantiera.find( ".piu10" ).click( _aggiungiValore.bind( this, 10 ) );
    }

    return PulsantieraNumerica;
}();

/*
$(function () {
    PulsantieraNumerica.init();
});*/
