require(["jquery", "peaks", "foundation"], function ($, Peaks) {
  // Foundation JavaScript
  // Documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation();

  var p = Peaks.init({
    container: document.querySelector('#peaks-container'),
    mediaElement: document.querySelector('audio'),
    dataUri: '/audio/28/waveform.json'
  });

  p.on('segments.ready', function(){
    // do something when segments are ready to be displayed
  });
});
