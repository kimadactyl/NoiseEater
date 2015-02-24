require(["jquery", "peaks", "foundation"], function ($, Peaks) {
  // Foundation JavaScript
  // Documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation();

  var p = Peaks.init({
    container: document.querySelector('#peaks-container'),
    mediaElement: document.querySelector('audio'),
    zoomLevels: [512, 1024, 2048, 4096],
    waveformBuilderOptions: {
      scale: 128,
      scale_adjuster: 127
    }
  });

  p.on('segments.ready', function(){
    // do something when segments are ready to be displayed
  });
});
