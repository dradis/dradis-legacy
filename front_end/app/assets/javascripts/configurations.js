jQuery.ajaxSetup({ 
  beforeSend: function(xhr) { 
    xhr.setRequestHeader("Accept", "text/javascript"); 
    var token = $("meta[name='csrf-token']").attr("content");
    xhr.setRequestHeader("X-CSRF-Token", token);
  }
});

$('tbody td.value input')
  .live('blur', function() {
    $(this).removeClass('editing');
  })
  .live('change', function() {
  var config_id = $(this).attr('id').match(/config_([0-9]*)_/)[1];
  var post_path = $(this).parents('form').attr('action');
  var ajax_opts = {
    context: $(this),
    data: { config: { value: $(this).val() } },
    dataType: 'json',
    type: 'post',
    
    complete: function() { $(this).removeClass('saving'); },
    error: function(xhr, status, error) { $(this).addClass('failed'); },
    success: function(data, status, xhr) { $(this).addClass('saved'); }
  };

  if(config_id == "") {
    $.extend(true, ajax_opts, {
      data: { config: { name: $(this).siblings('input#config__name').val() } },
      url: post_path,
      
      success: function(data, status, xhr) {
        $(this)
          .attr('id', 'config_' + data.id + '_value')
          .attr('name', 'config[' + data.id + '][value]');
        $(this).siblings('input#config__name').remove();
        $(this).parents('td').siblings('td.status').text('user set');
      } });
  } else {
    $.extend(true, ajax_opts, { data: { '_method': 'put' }, url: post_path + '/' + config_id });
  }

  $(this).addClass('saving');
  $.ajax(ajax_opts);
})
  .live('keydown', function(e) {
    $(this)
      .addClass('editing')
      .removeClass('saved', 'failed');
  })
