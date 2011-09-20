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

function statusUpdate(lastUpdate){
  console.log(this);
  Ext.Ajax.request({
    url: 'logs.json',
    method: 'GET',
    params: {after: this.after},
    scope: this, // make sure the task config is available in the callsbacks
    success: function(response, options){
      var updates = Ext.decode(response.responseText);

      Ext.each(updates, function(update) {
        // Category-related events are not important as changing to a new node
        // will refresh the list of categories anyway
        if (update.resource == 'category') {
          console.log('skipping category event');
          return;
        }

        if (update.resource == 'note') {
          // If there is a note-related event but for a different node we are not
          // interested
          if (update.record.node_id != this.current_node) {
            console.log('skipping note update for different node');
            return;
          }
          console.log('marking notes browser view as dirty');
          notesbrowser.markDirty();
        }

        // Skip node events for the time being
        if (update.resource == 'node') {
          console.log('skipping node event');
          return;
        }
      }, this);

      // from now on, only request updates after the last one we just received
      if (updates.length > 0) {
        this.after = updates[updates.length - 1].id;
      }
    },
    failure: function(response, options){
      dradisstatus.setStatus({text: 'An error occured while loading new updates', iconCls: 'error', clear: 5000});
    }
  });
}