document.addEventListener('turbolinks:load', function () {
  $(function () {
    var search_form = $('#js-SearchForm');
    search_form.submit(function () {
      var keyword = $('input[id=keyword]').val();
      if (keyword.match(/^[ 　\r\n\t]*$/)) {
        return false;
      }
    });
  });
});
