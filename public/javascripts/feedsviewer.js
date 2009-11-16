// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.feeds');

dradis.feeds.Panel=Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  title:'Feeds',

  initComponent: function(){
    // Called during component initialization
    var config ={
        region: 'south',
        collapsible: true,
        collapsed: true,
        split: true,
        height: 150,
        minHeight: 100,
        header: true
      //props (non-overridable)
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
  }

  // other methods/actions
});

Ext.reg('feeds', dradis.feeds.Panel);
