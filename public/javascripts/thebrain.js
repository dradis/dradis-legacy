// TODO: think REST please!!!

//------------------------------------------------------------------------ nodes
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

function delnode(node, callback){
  console.log('deleting node!');
}

function updatenode(node, callback){
  console.log('update node!');
}

//------------------------------------------------------------------------ notes 
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

function delnote(note, callback){
  var p = note.data; 
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/note_delete?id=' + note.id,
    params: p, 
    success: function(response, options) {
               dradisstatus.setStatus({ 
                 text: 'Note successfully deleted.',
                 clear: 5000
               });
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

function updatenote(note, callback){
  var p = note.data;
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/note_update?id='+note.id,
    params: p, 
    success: function(response, options) {
      dradisstatus.setStatus({ 
        text: 'Data sent to the server',
        clear: 5000
      });
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

//------------------------------------------------------------------------ categories 
function addcategory(category, callback) {
  var p = category.data; 
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/category_create',
    params: p, 
    success: function(response, options) {
              dradisstatus.setStatus({ 
                text: 'New category sent to the server',
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

function delcategory(category, callback) {
  var p = category.data; 
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/category_delete',
    params: p, 
    success: function(response, options) {
              var msg = response.responseText;
              if (msg == 'noerror') {
                dradisstatus.setStatus({ 
                  text: 'Category successfully deleted.',
                  clear: 5000
                });
              } else {
                dradisstatus.setStatus({
                  text: msg,
                  //iconCls: 'error',
                  clear: 10000
                });

              }
              // callback even if an error existed: restore the DS
              callback(msg);
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

function updatecategory(category, callback){
  var p = category.data; 
  p.authenticity_token = dradis.token;
  Ext.Ajax.request({
    url: '/json/category_update',
    params: p, 
    success: function(response, options) {
              var msg = response.responseText;
              if (msg == 'noerror') {
                dradisstatus.setStatus({ 
                  text: 'Category successfully updated.',
                  clear: 5000
                });
              } else {
                dradisstatus.setStatus({
                  text: msg,
                  //iconCls: 'error',
                  clear: 10000
                });

              }
              // callback even if an error existed: restore the DS
              callback(msg);
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


