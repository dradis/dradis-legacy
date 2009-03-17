
Ext.ns('dradis.attachments');

dradis.attachments.ViewerPanel=Ext.extend(Ext.Panel, {
  title:'Attachments',
  layout:'fit',
  //frame:true,

  initComponent: function(){
    // Called during component initialization
    var config ={
      items: new Ext.DataView({
        store: new Ext.data.SimpleStore({ fields:['title', 'description'], data:[ ['foo','bar'], ['id','star'] ]}),
        tpl: new Ext.XTemplate('<tpl for="."><div class="thumb-wrap">{title}:<div class="thumb"></div><span class="x-editable">{description}</span></div></tpl><div class="x-clear"></div>'),
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
