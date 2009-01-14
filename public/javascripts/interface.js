
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
    tbar: [ 
      {xtype: 'tbfill' }, 
      {text: 'logout', handler: function(){ window.location = '/logout'; }, tooltip: 'End session'} 
    ]
  });
  
  dradis.HeaderPanel.superclass.constructor.apply(this, arguments);
};

Ext.extend( dradis.HeaderPanel, Ext.Panel, {} );
Ext.reg('headerpanel', dradis.HeaderPanel);


var nodestree = new dradis.NodesTree();
var notesbrowser = new dradis.NotesBrowser();

var dradistabs = new Ext.TabPanel({
  region: 'center',
  tabPosition: 'bottom',
  deferredRender: false,
  items: [
    notesbrowser,
    { contentEl: 'properties', title: 'Properties'}
  ]

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
      {
        region: 'north',
        html: '<h1 class="x-panel-header" style="text-align: right;">dradis v2.0 (<a href="/logout">logout</a>)</h1>',
        autoHeight: true,
        border: false,
        margins: '0 0 5 0'
      },
      //{ xtype: 'headerpanel' },
      { // left-hand side, the tree
        region: 'west',
        collapsible: true,
        //title: 'Navigation',
        xtype: 'nodestree'
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
  vp.doLayout();
  Ext.TaskMgr.start({ run: checkrevision, interval: 10000 });
});
