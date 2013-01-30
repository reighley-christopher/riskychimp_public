function showElement(selector) {
  $(selector).show();
}

function hideElement(selector) {
  $(selector).hide();
}

$(document).ready(function() {
  $(document).bind('ajaxSend', function() {
    $('.ajax-loader').css('visibility', 'visible');
    $('.ajax-loader').show();
  }).bind('ajaxComplete', function() {
    $('.ajax-loader').css('visibility', 'hidden');
    $('.ajax-loader').hide();
  })
})
