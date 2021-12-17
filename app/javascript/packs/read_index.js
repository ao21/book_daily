document.addEventListener('turbolinks:load', function () {
  var hideList = 'table#js-ReadIndex__table tbody#js-ReadIndex__reads tr:nth-of-type(n+6)';
  $(hideList).hide();
  $('#js-ReadIndex__reads-more').on('click', function () {
    $(hideList).toggle();
    if ($(hideList).css('display') == 'none') {
      $('#js-ReadIndex__reads-more').text('more...');
    } else {
      $('#js-ReadIndex__reads-more').text('close');
    }
    return false;
  });

  var num = $('table#js-ReadIndex__table tbody#js-ReadIndex__reads').children('tr').length;
  if (num < 6) {
    $('#js-ReadIndex__reads-more').hide();
  }
});
