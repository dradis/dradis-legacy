// TODO: this should be an object, not functions

//------------------------------------------------------------------------ revision poller
function statusUpdate(lastUpdate){
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
          //console.log('skipping category event');
          return;
        }

        if (update.resource == 'note') {
          // If there is a note-related event but for a different node we are not
          // interested
          if (update.record.node_id != this.current_node) {
            //console.log('skipping note update for different node');
            return;
          }
          //console.log('marking notes browser view as dirty');
          notesbrowser.markDirty();
        }

        // Skip node events for the time being
        if (update.resource == 'node') {
          //console.log('Processing new node :' + update.action + ' event');
          var parent = nodestree.getNodeById(update.record.parent_id || 'root-node');
          if (parent){
            //console.log('Parent found: ' + parent.id);
            if (parent.isLoaded()) {
              var node;
              switch (update.action) {
                case 'create':
                  node = new Ext.tree.AsyncTreeNode({
                    id: update.record.id,
                    text: update.record.label,
                    iconCls: 'icon-node-' + ['default','host'][update.record.type_id]
                  });
                  parent.appendChild(node);
                  break
                case 'update':
                  node = parent.findChild('id', update.record.id);
                  console.log(node);
                  var oldText = node.text;
                  var text = update.record.label;
                  node.text = node.attributes.text = text;
                  node.ui.onTextChange(node, text, oldText);
                  node.setIconCls('icon-node-' + ['default','host'][update.record.type_id]);
                  break;
                case 'destroy':
                  node = parent.findChild('id', update.record.id);
                  node.remove(true);
                  break;
              }
            } else {
              //console.log('Parent node not yet loaded. Nothing to be done.');
            }
          } else{
            //console.log('Parent node not yet found in tree. Nothing to be done.');
          }
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