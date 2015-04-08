define(["jquery", "foundation", "peaks"], function($,foundation,Peaks) {
  // $(document).foundation({
  //   // Slider for report pages
  //   slider: {
  //     on_change: function(){
  //       thresh = $('#threshold-slider').attr('data-slider');
  //       $("#time-history-table tbody > tr").each(function() {
  //         value = $(this).find(":nth-child(4)").html();
  //         if(thresh >= parseFloat(value)) {
  //           $(this).css("background-color", "yellow");
  //         } else {
  //           $(this).css("background-color", "transparent");
  //         }
  //       })
  //     }
  //   }
  // });


  /* ======= Octopus ======= */

  var octopus = {
    init: function() {
      timehistoryView.init();
      sliderView.init();
      noisefreeView.init();
      waveformView.init();
    },

    getTimeHistory: function() {
      return model.timeHistory;
    },

    getThreshold: function() {
      return model.threshold;
    }
  };


  /* ======= Views ======= */

  var timehistoryView = {
    init: function() {
      this.tableElem = document.getElementById('time-history-table').getElementsByTagName('tbody')[0];
      this.render();
    },

    render: function() {
      // For each time history, make a tr
      octopus.getTimeHistory().forEach(function(row) {
        // Our row
        var newRow = timehistoryView.tableElem.insertRow();

        // For each, make the cells
        for (var c in row) {
          var cell = newRow.insertCell();
          cell.textContent = row[c];
        };
        
        // if(row["QDeg"] < octopus.getThreshold()) {
        //   newRow.css("background-color", "yellow");
        // };

      })
    }
  }

  var waveformView = {
    init: function() {
      // TODO: refactor considering we are now using validation string urls
      url = window.location.pathname;
      url = url.split("/")
      url = url[2];

      // Peaks regions
      this.peaksElem = Peaks.init({
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

      this.render();
    },

    render: function() {
      this.peaksElem.on('segments.ready', function(){
        // do something when segments are ready to be displayed
        this.peaksElem.segments.add(regions);
      });
    }
  }


  var noisefreeView = {
    init: function() {
      
    }
  }

  var sliderView = {
    init: function() {

    }
  }

  $( document ).ready(function() {
    octopus.init();
  }) ;
});