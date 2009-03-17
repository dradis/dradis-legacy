
Ext.ns('dradis.attachments');

dradis.attachments.defaultTemplate= new Ext.XTemplate(
'<tpl for=".">',
  '<div class="thumb-wrap" id="{title}" style="border:1px solid #ccc">',
  '<div class="thumb"></div>',
  '<span class="x-editable">{description}</span></div>',
'</tpl>',
'<div class="x-clear"></div>'
);

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  title:'Attachments',
  layout:'fit',

  initComponent: function(){
    // Called during component initialization
    var config ={
      items: new Ext.DataView({
        store: new Ext.data.SimpleStore({ 
                                          fields:['filename', 'description'], 
                                          data:[ ['foo','bar'], ['id','star'] ]
        }),
        tpl: dradis.attachments.defaultTemplate,
        autoHeight:true,
        multiSelect: true,
        itemSelector:'div.thumb-wrap',
        emptyText: 'No attachments to display'
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
  }
});
