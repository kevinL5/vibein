$(document).ready(function() {
  $('.search-box .getFullSearch').on('click', function(e) {
      $('.search-full').addClass("active"); //you can list several class names
      e.preventDefault();
  });

  $('.search-close').on('click', function(e) {
      $('.search-full').removeClass("active"); //you can list several class names
      e.preventDefault();
  });
});