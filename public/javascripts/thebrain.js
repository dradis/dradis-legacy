// TODO: think REST please!!!
// TODO: this should be an object, not functions

//------------------------------------------------------------------------ nodes
function addnode(node, callback) {
  var parent = node.parentNode;
  var p = { 
    label: node.text 
  };
  if (parent.id != 'root-node') {
    p.parent_id = parent.id
  }
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/node_create',
    params: p, 
    success: function(response, options) {
                   dradisstatus.setStatus({ 
                        text: 'New node sent to the server',
                        clear: 5000
                   });
              dradis.revision += 1; 
              callback(response.responseText);
    },
    failure: function(response, options) {
                   dradisstatus.setStatus({
                        text: 'An error occured with the Ajax request',
                        iconCls: 'error',
                        clear: 5000
                   });
    }
  });
}

function delnode(node, callback){
  var p = { id: node.id };
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/node_delete',
    params: p, 
    success: function(response, options) {
      dradisstatus.setStatus({ 
        text: 'Node removed from the server',
        clear: 5000
      });
      dradis.revision += 1; 
    },
    failure: function(response, options) {
      dradisstatus.setStatus({
        text: 'An error occured with the Ajax request',
        iconCls: 'error',
        clear: 5000
      });
    }
  });

}

function updatenode(node, callback){
  var p = { id: node.id, label: node.text };
  if (node.parentNode.parentNode !== null) {
    p.parent_id = node.parentNode.id;
  }
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/node_update',
    params: p, 
    success: function(response, options) {
      dradisstatus.setStatus({ 
        text: 'Node label edited',
        clear: 5000
      });
      dradis.revision += 1; 
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


//------------------------------------------------------------------------ revision poller

function checkrevision(interval) {
  // prevent further requests
  // this may be better done with Ext's TaskRunner
  if (dradis.revision == -1) { return; }

  Ext.Ajax.request({
    url: '/configurations/revision.xml',
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
  if (options.params) {
    ajax_params.params.authenticity_token = dradis.token;
  }

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
