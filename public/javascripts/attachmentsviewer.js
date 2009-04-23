
Ext.ns('dradis.attachments');

dradis.attachments.defaultTemplate= new Ext.XTemplate(
'<tpl for=".">',
  '<div class="thumb-wrap" id="{filename}" style="border:1px solid #ccc; text-align: center;">',
    '<div class="thumb"><img src="/images/mimetypes/image.png" title="Double click to open {filename}"></div>',
    '<span class="x-editable">{filename}</span>',
    '<div>{sizeString}</div>',
  '</div>',
'</tpl>',
'<div class="x-clear"></div>'
);

dradis.attachments.deleteAttachment = function () {
    if (attachmentsviewer.fields.dv.getSelectionCount() > 0) {
        var selection = attachmentsviewer.fields.dv.getSelectedRecords();
        for (x in selection) {
            var filename = selection[x].get('filename');
            Ext.Ajax.request({
                url: '/nodes/' + attachmentsviewer.currentNode + '/attachments/' + filename,
                method: 'POST',
                params: {'_method' : 'delete', 'authenticity_token' : dradis.token},
                success: function () {attachmentsviewer.fields.dv.store.reload();},
                failure: function () {Ext.Msg.alert('Error', 'The selected file could not be deleted')}
            })
        }
    }
}

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  id:'attachments-view',
  title:'Attachments',
  frame:true,
  fields: {},
  currentNode:1,
  layout:'fit',

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
                                              url:'/nodes/' + this.currentNode + '/attachments.json',
                                              fields:['filename', 'size', 'created_at']
                                            }),
                                            tpl: dradis.attachments.defaultTemplate,
                                            prepareData: function(data){
                                              data.sizeString = Ext.util.Format.fileSize(data.size);
                                              return data;
                                            },
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
      window.open('/nodes/' + this.currentNode + '/attachments/' + node.id);
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
