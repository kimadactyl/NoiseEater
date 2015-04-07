define(["jquery"], function ($) {

  var fileInput = $('#audiofile');
  $('#hiddenarea').hide();

  fileInput.change(function(){
      $('#droparea').text(fileInput.val());
      $('#hiddenarea').slideDown("slow");
  })

  $('#droparea').click(function(){
      fileInput.click();
  })

});