document.addEventListener('turbolinks:load', function () {
  $('.js-HeaderMenu__toggle').each(function () {
    $(this).on('click', function () {
      $('.js-HeaderMenu__toggle-icon, .js-HeaderMenu__content').toggleClass('show');
    });
  });
});
