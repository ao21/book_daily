document.addEventListener("turbolinks:load", function(){
  $(document).on( "change", function () {
    var start = $("#started_on").val();
    var finish = $("#finished_on").val();
    var dateStart = Date.parse(start);
    var dateFinish = Date.parse(finish);

    var result = (dateFinish - dateStart) / 86400000;

    $('.days').html(result);
  });
});