requirejs.config({
  baseUrl: '/js',
  paths: {
    jquery: 'vendor/jquery/dist/jquery',
    foundation: 'vendor/foundation/js/foundation',
    peaks: 'vendor/peaks.js/src/main',
    EventEmitter: 'vendor/eventemitter2/lib/eventemitter2',
    Kinetic: 'vendor/kineticjs/kinetic',
    'waveform-data': 'vendor/waveform-data/dist/waveform-data.min',
  },
  shim: {
    'foundation': {
      deps: ['jquery'],
      exports: 'foundation'
    }
  }
});