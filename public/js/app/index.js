require(["jquery", "foundation"], function($) {

  $(document).ready(function() {
    $(this).foundation()
    $('.selected').hide();

    var fileInput = $('#audiofile');

    fileInput.change(function(){
      $('.notselected').hide();
      $('#droparea .selected span').text(fileInput.val().split('\\').pop());
      $('#hiddenarea').slideDown("slow");
      $('.selected').show();

      $('html, body').animate({
        scrollTop: $("#uploadform").offset().top
      }, 500);
    })

    $('#droparea').click(function(){
      fileInput.click();
    })

    $('#moreless .selected').click(function() {
      $('#uploadform').trigger("reset");
      $('.notselected').show();
      $('.selected').hide();
    });
  });

 });