define(["peaks"], function(Peaks) {
  // TODO: refactor considering we are now using validation string urls
  url = window.location.pathname;
  url = url.split("/")
  url = url[2];

  // Peaks regions
  var p = Peaks.init({
    container: document.querySelector('#peaks-container'),
    mediaElement: document.querySelector('audio'),
    // logger: console.error.bind(console),
    // zoomLevels: [512, 1024, 2048, 4096],
    // waveformBuilderOptions: {
    //   scale: 128,
    //   scale_adjuster: 127
    // },
    dataUri: {
      arraybuffer: '/audio/' + url + '/waves.dat'
    }
  });

  p.on('segments.ready', function(){
    // do something when segments are ready to be displayed
    p.segments.add(regions);
  });
});
