$(document).ready(function() {
  $('.popover-markup>.trigger').popover({
    html: true,
    title: function () {
        return $(this).parent().find('.head').html();
    },
    content: function () {
        return $(this).parent().find('.content').html();
    },
  });

  $('body').on('click', function (e) {
      $('[data-toggle="popover"]').each(function () {
          //the 'is' for buttons that trigger popups
          //the 'has' for icons within a button that triggers a popup
          if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
              $(this).popover('hide');
          }
      });
  });

  function scrollToAnchor(aid){
    var aTag = $("a[name='id"+ aid +"']");
    $('.music-list').animate({scrollTop: aTag.offset().top},'slow');
  }

  $(".music-list").show(function() {
    var id = $('.player:first').data('source-id');
    scrollToAnchor(id);
  });

});
