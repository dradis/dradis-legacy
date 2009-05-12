
Ext.ns('dradis.attachments');

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  id:'attachments-view',
  title:'Attachments',
  frame:false,
  fields: {},
  layout:'border',
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
      update:function(store, record, operation){
        dradis.ajax.request({
          url: '/nodes/' + this.currentNode + '/attachments/' + record.modified.filename,
          method: 'POST',
          record: record,
          params: {
            '_method' : 'put',
            rename: record.get('filename')
          },
          listeners:{
            success:function(response, options){ options.record.commit(true); },
            failure:function(response, options){ options.record.reject(true); }
          }
        });

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
            text:'delete selected',
            tooltip:'Delete the selected items',
            iconCls:'del',
            scope: this,
            handler: function(){
              if (this.fields.dv.getSelectionCount() > 0) {
                var selection = this.fields.dv.getSelectedRecords();
                for (var i=0; i < selection.length; i++) {
                 this.fields.dv.store.remove(selection[i]);
                }
              }
            }
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
      items:[ 
        this.fields.uploader = new Ext.Panel({ 
                                            region:'west',
                                            split:'true',
                                            collapsible:true,
                                            title:'upload',
                                            width:'20%'
        }),
        this.fields.dv = new Ext.DataView({
                                            region:'center',
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
      ]
      
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
      window.open('/nodes/' + dv.store.currentNode + '/attachments/' + node.id);
    }, this);
    
    this.fields.dv.on('contextmenu', function(dv, index, node, ev){  
      dv.select(node);
      var menu = new Ext.menu.Menu({
        dataView: dv,
        items:[ 
          {
            text:'Delete File', 
            iconCls:'del',
            handler:function(item, ev){
              var dv = this.parentMenu.dataView;
              dv.store.remove( dv.getSelectedRecords()[0] );
            }
          } 
        ]
      });
      menu.showAt(ev.getXY());
      ev.stopEvent();
    });

  },
  updateAttachments:function(node_id){
    this.fields.dv.store.load({nodeId: node_id});
  },
  refresh:function(){
    this.fields.dv.store.load();
  }
});
