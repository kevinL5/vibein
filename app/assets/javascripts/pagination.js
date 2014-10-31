$(function() {
  $(".pagination a").on('click', function() {
    $(".pagination").html("Page is loading...");
    $.getScript(this.href);
    scrollTop();
    return false;
  });
});

function scrollTop() {
$(".music-list").scrollTop(0);
}