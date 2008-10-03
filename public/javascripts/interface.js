
Ext.BLANK_IMAGE_URL = '/images/default/s.gif';

// ----------------------------------------- header: title + toolbar
dradis.HeaderPanel = function(config){
  Ext.apply(this, {
    border: false,
    layout:'anchor',
    region:'north',
    margins: '0 0 5 0',
    autoHeight: true,
    title: 'dradis v2.0',
    tbar: [ {text: 'logout', handler: function(){ window.location = '/logout'; }, tooltip: 'End session'} ],
  });
  
  dradis.HeaderPanel.superclass.constructor.apply(this, arguments);
};

Ext.extend( dradis.HeaderPanel, Ext.Panel, {} );
Ext.reg('headerpanel', dradis.HeaderPanel);

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
      { xtype: 'headerpanel' },
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
