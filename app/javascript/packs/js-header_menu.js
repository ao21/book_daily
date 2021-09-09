document.addEventListener('turbolinks:load', function () {
  $('.js-HeaderMenu__toggle').on('click', function () {
    $('.js-HeaderMenu__toggle-icon, .js-HeaderMenu__content').toggleClass('show');
    return false;
  });

  $(document).on('click touchend', function (event) {
    if (!$(event.target).closest('.js-HeaderMenu__content').length) {
      $('.js-HeaderMenu__toggle-icon, .js-HeaderMenu__content').removeClass('show');
    }
  });
});
