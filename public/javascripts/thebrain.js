// TODO: think REST please!!!
function addnode(node, callback) {
  var parent = node.parentNode;
  console.log( 'thebrain: addnode' );
  console.log( node.id );
  console.log( node.text );
  console.log( parent.id );
  var p = { 
    label: node.text, 
  }
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
              callback(response.responseText);
    },
    failure: function(response, options) {
                   dradisstatus.setStatus({
                        text: 'An error occured with the Ajax request',
                        iconCls: 'error',
                        clear: 5000
                   });
    },
  });

  console.log( 'thebrain: /addnode' );
}

function addnote(note, callback) {
  var p = note.data;
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/note_create',
    params: p, 
    success: function(response, options) {
              dradisstatus.setStatus({ 
                text: 'New note sent to the server',
                clear: 5000
              });
              callback(response.responseText);
    },
    failure: function(response, options) {
              dradisstatus.setStatus({
                text: 'An error occured with the Ajax request',
                iconCls: 'error',
                clear: 5000
              });
    },
  })

}
