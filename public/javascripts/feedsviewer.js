// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.feeds');

dradis.feeds.Panel=Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  title:'Feeds',
  frame: true,
  layout: 'fit',
  region: 'south',
  template:  new Ext.XTemplate(
    '<tpl for=".">',
        '<div style="border-bottom: 1px solid #6592CB;"><span style="font-weight:bold">{title}</span> {stamp}</div>',
    '</tpl>',
    '<div class="x-clear"></div>'
  ),
  dataStore: new Ext.data.JsonStore({
    url: '/feeds.json',
    fields: [
        'id', 'action', 'user', 'actioned_at', 'resource', 'value', 'created_at', 'updated_at', 'title', 'stamp'
    ]

  }),



  initComponent: function(){
    // Called during component initialization
    var config ={
        
        collapsible: true,
        collapsed: true,
        height: 150,
        minHeight: 100,
        header: true,
        titleCollapse: false,
        items: new Ext.DataView({
            store: this.dataStore,
            tpl: this.template,
            autoHeight:true,
            multiSelect: true,
            overClass:'x-view-over',
            itemSelector:'div.thumb-wrap',
            emptyText: 'No feeds to display'
        })

    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);
    this.dataStore.load();
        
    // Before parent code
    
    // Call parent (required)
    dradis.feeds.Panel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
  }

  // other methods/actions
});

Ext.reg('feeds', dradis.feeds.Panel);
