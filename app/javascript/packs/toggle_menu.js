document.addEventListener('turbolinks:load', function () {
  $('.js-list-menu').each(function () {
    $(this).on('click', function () {
      $('+.js-list-submenu', this).slideToggle();
      return false;
    });
  });
});
