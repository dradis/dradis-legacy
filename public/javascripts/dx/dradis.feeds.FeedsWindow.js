// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.feeds');

dradis.feeds.DataView=Ext.extend(Ext.DataView, {
    tpl:  new Ext.XTemplate(
      '<tpl for=".">',
          '<div class="topic"><b>{title}</b><span class="author">{stamp}</span><div class="description">{value}</div></div>',
      '</tpl>',
      '<div class="x-clear"></div>'
    ),
    store: store = new Ext.data.JsonStore({
      url: '/feeds.json',
      fields: [
          'id', 'action', 'user', 'actioned_at', 'resource', 'value', 
          'created_at', 'updated_at', 'title', 'stamp', 'description'
      ]
    }),
    overClass:'x-view-over',
    itemSelector:'div.thumb-wrap',
    emptyText: 'No feeds to display',
    initComponent: function(){
      this.store.load();
      // Call parent (required)
      dradis.feeds.DataView.superclass.initComponent.apply(this, arguments);
    }
})

dradis.feeds.FeedsWindow=Ext.extend(Ext.Window, {
  //props (overridable by caller)
  title:'Feeds viewer',
  width: 640,
  height: 480,
  modal: true,
  maximizable: true,
  closeAction: 'hide',
  fields: {},

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      layout:'border',
      minWidth: 300,
      minHeight: 150,
      items: [
        this.fields.panel = {
          region: 'center',
          autoScroll: true,
          items: [ new dradis.feeds.DataView() ]
        }
      ],
      buttons:[
        {
          text:'Close',
          scope: this,
          handler: function(){ this.hide(); }
        }
      ]
    };

    // Config object has already been applied to 'this' so properties can
    // be overriden here or new properties (e.g. items, tools, buttons)
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);

    // Before parent code

    // Call parent (required)
    dradis.feeds.FeedsWindow.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    //this.relayEvents(this.fields.panel, ['close']);

    //this.fields.panel.on('close', function(){ this.hide(); }, this );
  }

  // other methods/actions
  //load: function(record){
  //  this.fields.panel.load(record);
  //},

  //clear: function(){ this.fields.panel.clear(); }
});


Ext.reg('feedswindow', dradis.feeds.FeedsWindow);
