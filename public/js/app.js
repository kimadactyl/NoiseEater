requirejs.config({
  baseUrl: '/js/vendor',
  paths: {
    jquery: 'jquery/dist/jquery',
    foundation: 'foundation/js/foundation',
    peaks: 'peaks.js/src/main',
    EventEmitter: 'eventemitter2/lib/eventemitter2',
    Kinetic: 'kineticjs/kinetic',
    'waveform-data': 'waveform-data/dist/waveform-data.min',
    app: '../app'
  }
});

requirejs(['app/main']);