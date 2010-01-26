// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.feeds');

dradis.feeds.DataView=Ext.extend(Ext.DataView, {
    tpl:  new Ext.XTemplate(
      '<tpl for=".">',
          '<div style="border-bottom: 1px solid #6592CB;"><span style="font-weight:bold">{title}</span> {stamp}</div>',
      '</tpl>',
      '<div class="x-clear"></div>'
    ),
    store: store = new Ext.data.JsonStore({
      url: '/feeds.json',
      fields: [
          'id', 'action', 'user', 'actioned_at', 'resource', 'value', 'created_at', 'updated_at', 'title', 'stamp'
      ]
    }),
    autoHeight:true,
    multiSelect: true,
    overClass:'x-view-over',
    itemSelector:'div.thumb-wrap',
    emptyText: 'No feeds to display',
    initComponent: function(){
      this.store.load();
      // Call parent (required)
      dradis.feeds.DataView.superclass.initComponent.apply(this, arguments);
    }
})

dradis.feeds.Panel=Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  title:'Feeds',
  frame: true,
  border: false,
  layout: 'fit',
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
      region: 'east',
      collapsible: true,
      //collapsed: true,
      width: 150,
      minWidth: 100,
      header: true,
      titleCollapse: false,
      items: new dradis.feeds.DataView({
      })
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);
        
    // Before parent code
    
    // Call parent (required)
    dradis.feeds.Panel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
  },

  // The refresh method is used to updated the RSS feeds to the latest info
  refresh: function() {
    dradis.feeds.DataView.prototype.store.load();
  }
  // other methods/actions
});

// Refresh the RSS feeds every 10seconds
//FIXME: This creates the callback even if no object has been created!
//Ext.TaskMgr.start({ run: dradis.feeds.Panel.prototype.refresh, interval: 10000 });
Ext.reg('feeds', dradis.feeds.Panel);
