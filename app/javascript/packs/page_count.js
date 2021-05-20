document.addEventListener("turbolinks:load", function() {
  $(document).on( "change", function () {
      var s = $("#page_start").val();
      var e = $("#page_end").val();
      var si = parseInt(s);
      var ei = parseInt(e);

      var result = ei - si;

      $("#result").val(result);
    });
});