require(["jquery"], function($) {
  var getTime = function() {
    $.ajax({
      url: "/waitingtime/" + id,
      dataType: "html",
      success: function(data) {
        $('.queue').html(data);
      }
    })    
  };

  setInterval(function () {
    getTime();
  }, 10000);

  getTime();

})