document.addEventListener('turbolinks:load', function () {
  $('#js-Header__toggle').on('click', function () {
    $('#js-Header__toggle, #js-Header__content, #js-Header__list').toggleClass('show');
    return false;
  });

  if ($('#js-Header__toggle, #js-Header__content, #js-Header__list').hasClass('show')) {
    $(document).on('click touchend', function (event) {
      if (!$(event.target).closest('#js-Header__list, #js-Header__toggle').length) {
        $('#js-Header__toggle, #js-Header__content, #js-Header__list').removeClass('show');
        return false;
      }
    });
  }
});
