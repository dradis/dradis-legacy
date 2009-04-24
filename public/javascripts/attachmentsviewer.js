
Ext.ns('dradis.attachments');

dradis.attachments.deleteAttachment = function () {
    if (attachmentsviewer.fields.dv.getSelectionCount() > 0) {
        var selection = attachmentsviewer.fields.dv.getSelectedRecords();
        for (var i=0; i < selection.length; i++) {
          attachmentsviewer.fields.dv.store.remove(selection[i]);
        }
    }
}

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  id:'attachments-view',
  title:'Attachments',
  frame:false,
  fields: {},
  layout:'fit',
  template: new Ext.XTemplate( 
    '<tpl for=".">',
      '<div class="thumb-wrap" id="{filename}" style="border:1px solid #ccc; text-align: center;">',
        '<div class="thumb"><img src="/images/mimetypes/{fileType}.png" title="Double click to open {filename}"></div>',
        '<span class="x-editable">{filename}</span>',
        '<div>{sizeString}</div>',
      '</div>',
    '</tpl>', '<div class="x-clear"></div>' 
  ),
  dataStore: new Ext.data.JsonStore({
    currentNode:1,
    url:'/nodes/' + this.currentNode + '/attachments.json',
    fields:['filename', 'size', 'created_at'],
    listeners:{
      beforeload:function(store, options){
        if (options.nodeId)
        {
          this.proxy.conn.url = '/nodes/' + options.nodeId + '/attachments.json';
          this.currentNode = options.nodeId;
        }
      },
      remove:function(store, record, index){
        dradis.ajax.request({
          url: '/nodes/' + this.currentNode + '/attachments/' + record.get('filename'),
          method: 'POST',
          params: {'_method' : 'delete'}
        });
      }
    }
  }),


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
          },
          '-',
          {
            tooltip: 'Refresh the list of attachments',
            iconCls:'x-tbar-loading',
            scope: this,
            handler: function(){
              this.refresh();
            }
          }
      ],
      items: 
        this.fields.dv = new Ext.DataView({
                                            store: this.dataStore,
                                            tpl: this.template,
                                            prepareData: function(data){
                                              data.sizeString = Ext.util.Format.fileSize(data.size);
                                              data.fileType = 'image';
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
    this.fields.dv.store.load({nodeId: node_id});
  },
  refresh:function(){
    this.fields.dv.store.load();
  }
});
