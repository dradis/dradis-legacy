// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.feeds');

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
      layout: 'fit',
      minWidth: 300,
      minHeight: 150,
      items: [
        
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