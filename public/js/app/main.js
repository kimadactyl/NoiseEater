require(["jquery", "peaks", "foundation"], function ($, Peaks) {
  // Foundation JavaScript
  // Documentation can be found at: http://foundation.zurb.com/docs
  $(document).foundation({
    slider: {
      on_change: function(){
        thresh = $('#threshold-slider').attr('data-slider');
        console.log("fndisfd");
        $("#time-history-table tbody > tr").each(function() {
          value = $(this).find(":nth-child(3)").html();
          if(thresh >= parseFloat(value)) {
            $(this).css("background-color", "yellow");
          } else {
            $(this).css("background-color", "transparent");
          }
        })
      }
    }
  });

  url = window.location.pathname;
  url = url.split("/")
  url = url[2];

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
