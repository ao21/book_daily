document.addEventListener('turbolinks:load', function(){
  $(document).on( 'change', '#finished_on', function() {
    var start = $('#started_on').val();
    var finish = $( this ).val();
    var dateStart = Date.parse(start);
    var dateFinish = Date.parse(finish);

    var result = (dateFinish - dateStart) / 86400000;

    $('.result').html(result)
  });
});