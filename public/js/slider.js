define(["jquery", "foundation"], function($,foundation) {
  $(document).foundation({
    // Slider for report pages
    slider: {
      on_change: function(){
        thresh = $('#threshold-slider').attr('data-slider');
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
});