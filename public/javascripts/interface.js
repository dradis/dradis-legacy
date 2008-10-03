
Ext.BLANK_IMAGE_URL = '/images/default/s.gif';
//Ext.ns('dradis');

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
      notesbrowser.updateNotes(n.attributes.id); 
      if (dradistabs.getActiveTab() == null) {
        dradistabs.setActiveTab(0);
      }
    }
  }
});

Ext.reg('dradisnodes', dradis.NodesTree);

// ----------------------------------------- notes 

var notesbrowser = new dradis.NotesBrowser();
var dradistabs = new Ext.TabPanel({
  region: 'center',
  tabPosition: 'bottom',
  deferredRender: false,
  items: [
    notesbrowser,
    { contentEl: 'properties', title: 'Properties'}
  ],
});

// ----------------------------------------- status bar
var dradisstatus = new Ext.StatusBar({
  region: 'south',
  defaultText: ''
});
Ext.Ajax.on('beforerequest', function(){ dradisstatus.showBusy(); }); 
Ext.Ajax.on('requestcomplete', function(){ dradisstatus.clearStatus({useDefaults:true}); }); 



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
      dradistabs,
      dradisstatus
        //{
        // console? do we need this?
        //region: 'south',
        //title: 'Information',
        //ollapsible: true,
        //html: 'Information goes here',
        //split: true,
        //height: 100,
        //minHeight: 100
        //xtype: 'statusbar'
        //}
    ]
  });
  store.load();
  vp.doLayout();

});
