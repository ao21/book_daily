const { normalizeTickInterval } = require('highcharts');

document.addEventListener('turbolinks:load', function () {
  $(document).on('change', function () {
    var start = $('#started_on').val();
    var finish = $('#finished_on').val();
    var dateStart = Date.parse(start);
    var dateFinish = Date.parse(finish);
    var pageCount = $('#page').data('page-id');
    var days = dateFinish - dateStart;

    if (days < 0) {
      var resultDays = 'N/A';
      var resultPages = 'N/A';
    } else {
      if (days == 0) {
        var resultDays = 0;
        var resultPages = pageCount;
      } else if (days / 86400000 >= pageCount) {
        var resultDays = pageCount;
        var resultPages = 1;
      } else {
        var resultDays = days / 86400000;
        var resultPages = Math.ceil(pageCount / resultDays);
      }
    }

    $('#days').html(resultDays + ' 日');
    $('#page').html(resultPages + ' ページ');
  });
});
