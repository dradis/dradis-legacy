$(function(){
  $('body.upload form').ajaxForm({dataType: 'script'});

  $(':file').change(function(){
    jobId = jobId + 1;
    $('#console').empty();
    $('#filename').text(this.value);
    $('#spinner').show();
    $('#result').data('id',  jobId);
    $('#result').show();
    $('#item_id').val(jobId);
    $(this).closest('form').submit();
  });

  $('#available').click(function(){
    $('#plugins').toggle();
    return false;
  });
});

var parsing = false;
function updateConsole() {
  if (!parsing) { return; }

  var upload_id = $("#result").data('id');
  var after;

  if ( $(".log").length > 0 ) {  
    after = $("#console p:last-child").data('id');
  } else {
    after = '0';
  }
  $.getScript( 'upload/status?item_id=' + upload_id + '&after=' + after );
}
