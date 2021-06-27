document.addEventListener("turbolinks:load", function(){
  $(document).on( "change", function () {
    var start = $("#started_on").val();
    var finish = $("#finished_on").val();
    var dateStart = Date.parse(start);
    var dateFinish = Date.parse(finish);
    var pageCount = $("#page").data("page-id");

    var resultDays = (dateFinish - dateStart) / 86400000;
    var resultPages = Math.ceil( pageCount / resultDays );

    $("#days").html(resultDays);
    $("#page").html(resultPages);
  });
});