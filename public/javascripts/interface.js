// ----------------------------------------- app config
Ext.BLANK_IMAGE_URL = '/images/default/s.gif';
Ext.ns('dradis');
 
// ----------------------------------------- header: title + toolbar
//dradis.HeaderPanel = new Ext.Panel({
dradisheader = new Ext.Panel({
  border: false,
  layout:'anchor',
  region:'north',
  //cls: 'docs-header',
  //height:60,
  margins: '0 0 5 0',
  autoHeight: true,
  items: [
    {
      xtype:'box',
      el:'header',
      border:false,
      //anchor: 'none -25'
    }, 
    new Ext.Toolbar(
      {
        border: false,
        //autoHeight: true,
        items: [ 
          {
            text: 'logout', 
            handler: function(){ window.location = '/logout';},
            tooltip: {text:'End session'}
          } 
        ]
      })
    ]
});

//Ext.reg('dradisheader', dradis.HeaderPanel);

// ----------------------------------------- tree

dradis.NodesTree = Ext.extend(Ext.tree.TreePanel, {
  width: 200,
  autoScroll: true,
  split: true,
  useArrows:true,
  autoScroll:true,
  animate:true,
  enableDD:true,
  loader: new Ext.tree.TreeLoader({
    url: 'json/nodes',
    requestMethod: 'GET'
  }),
  root: new Ext.tree.AsyncTreeNode({
    expanded: true,
    }),
  rootVisible: false,
  listeners: {
    click: function(n) {
      Ext.Msg.alert('Navigation Tree Click', 'You clicked: "' + n.attributes.text + '"');
    }
  }
});

Ext.reg('dradisnodes', dradis.NodesTree);

// ----------------------------------------- notes 



Ext.onReady(function() {
  Ext.QuickTips.init();

  var vp = new Ext.Viewport({
    layout: 'border',
    items: [
      dradisheader,
      { // left-hand side, the tree
        region: 'west',
        collapsible: true,
        //title: 'Navigation',
        xtype: 'dradisnodes',
      }, 
      { // center panel view
        region: 'center',
        xtype: 'tabpanel',
        tabPosition: 'bottom',
        items: [{
            title: 'Notes',
            html: 'The first tab\'s content. Others may be added dynamically'
          },{
            title: 'Properties'
          }]
      }, {
        // console? do we need this?
        region: 'south',
        //title: 'Information',
        //ollapsible: true,
        //html: 'Information goes here',
        //split: true,
        //height: 100,
        //minHeight: 100
        xtype: 'statusbar'
      }]
  });
  vp.doLayout();

});
