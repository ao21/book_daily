document.addEventListener('turbolinks:load', function () {
  $('.js-menu-item-link').each(function () {
    $(this).on('click', function () {
      $('+.submenu', this).slideToggle();
      return false;
    });
  });
});
