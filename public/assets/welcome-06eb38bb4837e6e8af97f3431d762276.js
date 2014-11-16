$(document).ready(function(){
  (function poll(){
    setTimeout(function(){
      $.ajax({
        url: "/api/images/latest",
        success: function(data, status, jqXHR) {
          $("#image").html('<img src="' + data + '"/>');
        },
        complete: poll
      });
    }, 1000);
  })();
});
