jQuery.ajaxSetup({
  'beforeSend': function (xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
});

$(function(){
  $('form').ajaxForm({dataType: 'script'});

  $(':file').change(function(){
    $('#files').empty();
    var itemId = new Date().getTime();
    $('#files').prepend('<div data-id="' + itemId + '" class="file">\n<div><strong>Filename</strong>: ' + this.value + ' <span><img style="margin:0;" src="/images/loading.gif" /></span></div>\n<div><strong>Size</strong>: </div>\n<div id="console"></div></div>');
    $('#item_id').val(itemId);
    $(this).closest('form').submit();
  });

  $('#available').click(function(){
    $('#plugins').toggle();
  });
});

var parsing = false;
function updateConsole() {
  if (!parsing) { return; }

  var upload_id = $("#files div:last-child").attr('data-id');
  var after;

  if ( $(".log").length > 0 ) {  
    after = $("#console p:last-child").attr('data-id');
  } else {
    after = '0';
  }
  $.getScript( '/upload/status?item_id=' + upload_id + '&after=' + after );
  setTimeout(updateConsole, 2000);
}
