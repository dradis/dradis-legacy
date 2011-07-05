// TODO: this should be an object, not functions

//------------------------------------------------------------------------ revision poller

function checkrevision(interval) {
  // prevent further requests
  // this may be better done with Ext's TaskRunner
  if (dradis.revision == -1) { return; }

  Ext.Ajax.request({
    url: 'configurations/1.xml',
    method: 'get',
    success: function(response, options) {
              var msg = response.responseText;
              // how ugly is this?
              rev = msg.match(/<value>(.*)<\/value>/);
              if (dradis.revision != eval(rev[1])) {
                dradisstatus.setStatus({ 
                  text: 'There is a new revision in the server. Please refresh.'
                });

                // prevent further requests
                // this may be better done with Ext's TaskRunner
                dradis.revision = -1;

                Ext.TaskMgr.stopAll();
              }
    },
    failure: function(response, options) {
              dradisstatus.setStatus({
                text: 'An error occured with the Ajax request',
                iconCls: 'error',
                clear: 5000
              });
    }
  })

}

Ext.ns('dradis.ajax');

// Try to unify the way we do Ajax calls
dradis.ajax.request = function(options){
  // request parameters
  var ajax_params = options;

  // callbacks
  ajax_params.success = function(response, options) {
    if (options.listeners && options.listeners.success){
      options.listeners.success(response, options);
    }
  }
  ajax_params.failure = function(response, options) {
    var msg = 'Ajax error: '+response.statusText+' ('+response.status+') for ';
    msg = msg + options.url 
    dradisstatus.setStatus({
      text:msg,
      //iconCls: 'error',
      clear: 10000
    });
    if (options.listeners && options.listeners.failure){
      options.listeners.failure(response, options);
    }

  }
  Ext.Ajax.request(ajax_params);
};
