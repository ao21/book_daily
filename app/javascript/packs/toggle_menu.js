document.addEventListener('turbolinks:load', function () {
  $('.js-link-menu').each(function () {
    $(this).on('click', function () {
      $('+.submenu', this).slideToggle();
      return false;
    });
  });
});
