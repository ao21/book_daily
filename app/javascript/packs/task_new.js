const { normalizeTickInterval } = require('highcharts');

document.addEventListener('turbolinks:load', function () {
  $(document).on('change', function () {
    var start = $('#started_on').val();
    var finish = $('#finished_on').val();
    var dateStart = Date.parse(start);
    var dateFinish = Date.parse(finish);
    var pageCount = $('#page').data('page-id');
    var days = (dateFinish - dateStart) / 86400000 + 1;

    if (days <= 0) {
      var resultDays = 'N/A';
      var resultPages = 'N/A';
    } else {
      if (days == 1) {
        var resultDays = 1;
        var resultPages = pageCount;
      } else if (days >= pageCount) {
        var resultDays = pageCount;
        var resultPages = 1;
      } else {
        var resultDays = days;
        var resultPages = Math.ceil(pageCount / resultDays);
      }
    }

    $('#days').html(resultDays + ' 日');
    $('#page').html(resultPages + ' ページ');
  });
});
