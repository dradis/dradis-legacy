
Ext.ns('dradis.attachments');

dradis.attachments.defaultTemplate= new Ext.XTemplate(
'<tpl for=".">',
  '<div class="thumb-wrap" id="{filename}" style="border:1px solid #ccc">',
    '<div class="thumb"><img src="/images/mimetypes/image.png" title="{filename}"></div>',
    '<span class="x-editable">{filename}</span>',
    '<div>{size}</div>',
  '</div>',
'</tpl>',
'<div class="x-clear"></div>'
);

dradis.attachments.deleteAttachment = function () {
    if (attachmentsviewer.fields.dv.getSelectionCount() > 0) {
        for (x in attachmentsviewer.fields.dv.getSelectedRecords) {
           
        }
    }
}

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  id:'attachments-view',
  title:'Attachments',
  frame:true,
  fields: {},
  currentNode:1,

  initComponent: function(){
    // Called during component initialization
    var config ={
      tbar: [
          {
            text:'upload file',
            tooltip:'Upload a new attachment to this element',
            iconCls:'add'
          },
          {
            text:'delete selected',
            tooltip:'Delete the selected items',
            iconCls:'del',
            handler: dradis.attachments.deleteAttachment
          }
      ],
      items: 
        this.fields.dv = new Ext.DataView({
                                            store: new Ext.data.JsonStore({ 
                                              url:'/nodes/1/attachments.json',
                                              fields:['filename', 'size', 'created_at']
                                            }),
                                            tpl: dradis.attachments.defaultTemplate,
                                            multiSelect: true,
                                            overClass:'x-view-over',
                                            itemSelector:'div.thumb-wrap',
                                            emptyText: 'No attachments to display',
                                            plugins: [
                                              new Ext.DataView.DragSelector(),
                                              new Ext.DataView.LabelEditor({dataIndex: 'filename'})
                                            ]

        })
      
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.attachments.ViewerPanel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    this.fields.dv.on('dblclick', function(dv, index, node, ev){ 
      window.location = '/nodes/' + this.currentNode + '/attachments/' + node.id;
    }, this),
    this.fields.dv.on('contextmenu', function(dv, index, node, ev){  })
  },
  updateAttachments:function(node_id){
    var conn = this.fields.dv.store.proxy.conn;
    conn.url = '/nodes/' + node_id + '/attachments.json';
    this.fields.dv.store.load();
    this.currentNode = node_id;
  }
});
