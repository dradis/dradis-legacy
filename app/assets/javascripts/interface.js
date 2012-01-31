
// Ext.BLANK_IMAGE_URL = '/assets/default/s.gif';
//Ext.state.Manager.setProvider(new Ext.state.CookieProvider);

// ------------------------------------------------------- smart Ajax polling
var pollingTask = { run: statusUpdate, interval: 10000, after: 0, current_node: 0 };

// ------------------------------------------------------- custom ExtJS widgets
var plugins = new dradis.plugins.PluginManager();
var uploaders = new dradis.plugins.UploadFormWindow();
var nodestree = new dradis.NodesTree();

// For the time being keep the old Notes tab while we create a better alternative
var notesbrowser = new dradis.notes.NotesBrowserPanel();
notesbrowser.title = 'Old notes';
var newnotes = new Ext.Panel({ title: 'New notes' });

var importer = new dradis.importer.Panel();
var attachments = new dradis.attachments.AttachmentsPanel();
var feedsWindow = new dradis.feeds.FeedsWindow();

importer.setImportStore( plugins.getImportPluginsStore() );


var dradistabs = new Ext.TabPanel({
  region: 'center',
  tabPosition: 'bottom',
  activeTab: 0,
  border: false,
  deferredRender: false,
  disabled: true,
  //margins: '0 5 0 0',
  items: [
    notesbrowser,
    newnotes,
    importer,
    attachments
  ]

});

var dradisoverview = new Ext.Panel({
  region: 'center',
  contentEl: 'first_render'
})

var dradisstatus = new Ext.ux.StatusBar({
    id: 'dradis-status',
    defaultText: '',
    items: [
      {
        text:'what\'s new in this version?',
        enableToggle:true,
        listeners:{
          toggle:function(){
            if ( dradistabs.items.length != 5 ) {
              this.welcome = new Ext.Panel({ 
                                  contentEl:'first_render', 
                                  title: 'What\'s new?', 
                                  autoScroll: true, 
                                  bodyStyle: 'background: #FFF url(/images/logo_small.png) no-repeat right bottom;'
                                });
              dradistabs.add(this.welcome);
              dradistabs.setActiveTab(this.welcome);
            } else {
              dradistabs.remove(this.welcome, false);
            }
          }
        }
      },
      {
        id: 'rss-icon',
        iconCls: 'rss-off',
        listeners: {
            click:function(){
                feedsWindow.refresh();
                feedsWindow.show();
                feedsWindow.center();
            }
        }
      }

    ]
});


/*
 * ------------------------------------------------------- custom ExtJS widgets
 * Events thrown by the different widgets are handleded in this object and 
 * notifications are passed to other widgets of the interface were appropriate.
 * ----------------------------------------------------------------------------
 */
nodestree.on('nodeclick', function(node_id){
  pollingTask.current_node = node_id;
  notesbrowser.updateNotes(node_id);
  newnotes.body.load('nodes/' + node_id + '/notes');
  attachments.updateAttachments(node_id);
  dradistabs.enable();
  if (dradistabs.getActiveTab() === null) {
    dradistabs.setActiveTab(0);
  }
});

nodestree.on('notesdrop', function(drop_ev) {
  var notes = drop_ev.data.selections; 
  var node_id = drop_ev.target.id;

  for(var i = 0, len = notes.length; i < len; i++){
    notesbrowser.moveNoteToNode(notes[i].id, node_id);
  }
});

update_attachments_tab = function(store){
  if (store.data.length > 0) {
    attachments.setTitle('Attachments (!)');
  } else {
    attachments.setTitle('Attachments');
  }
};
attachments.on('load', update_attachments_tab);
attachments.on('remove', update_attachments_tab);

importer.on('importrecord',function(record){ 
    notesbrowser.addNote(record.data.description ); 
    dradistabs.activate(notesbrowser);
});

uploaders.on('uploadsuccess', function(){
  dradistabs.disable();
  nodestree.refresh();
});

uploaders.on('uploadfailure', function(response){
  var msg = Ext.util.Format.htmlEncode( unescape(response.error).replace(/\+/g, " ")  );
  var trace = "";
  for (line in response.backtrace) {
    trace += Ext.util.Format.htmlEncode( unescape(response.backtrace[line]).replace(/\+/g, " ") ) + "\n";
  }

  // FIXME: Convert this into an Ext Template
  Ext.Msg.show({
    title: 'There was an error processing the upload',
    msg: '<p>We could not process the upload.</p><p>Error message was:</p>' +
         '<textarea cols="80">' + msg  + '</textarea>' +
         '<p>The stack trace was:</p>' +
         '<textarea cols="80" rows="10">' + trace + '</textarea>' + 
         '<p>What to do now:</p>' +
         '<ul>' + 
         '<li>- Go through the plugin\'s documentation.</li>' +
         '<li>- Ask in the <a href="http://dradisframework.org/community/" target="_blank">community forums</a> or the <a href="http://dradisframework.org/mailing_lists.html" target="_blank">mailing lists</a></li>' +
         '<li>- If all else fails, please consider submitting a <a href="http://sourceforge.net/tracker/?func=add&group_id=209736&atid=1010917" target="_blank">bug report</a>.</li>' +
         '</ul>',
    buttons: Ext.Msg.OK,
    icon: Ext.Msg.WARNING
  });
});


/*
 * onReady gets called when the page is rendered, all the files are loaded and
 * we are ready to rock!
 */
Ext.onReady(function() {
  Ext.QuickTips.init();
  
  var centerelement;

  if (dradis.firstrender == true) {
    centerelement = dradisoverview;
  } else {
    centerelement = dradistabs;
  }

  var vp = new Ext.Viewport({
    layout: 'border',
    items: [
      {
        region: 'north',
        autoHeight: true,
        border: false,
        margins: '0 0 5 0',
        bbar: new Ext.Toolbar({
          cls: 'x-panel-header',
          items: [ 
            {
              text: 'import from file...', 
              tooltip: 'import other tool\'s output into dradis',
              iconCls:'icon-form-magnify',
              menu: {
                items: [
                  {
                    text: 'new importer (with real-time feedback)',
                    handler: function() {
                      window.open('upload');
                    }
                  },
                  {
                    text: 'old importer (soon-to-be deprecated)',
                    handler: function() { 
                      uploaders.show(); 
                      uploaders.center();
                    }
                  }

                ]
              }
            },
           {
              text: 'export',
              tooltip: 'export dradis contents to external sources',
              iconCls: 'export',
              menu: plugins.exportPluginsMenu()
            },
            '->',
            {
              xtype: 'tbtext',
              html: '<h1>' + dradis.version + '- <a href="configurations" target="_blank">configuration</a> | <a href="logout">logout</a> | <a href="mailto:feedback@dradisframework.org?subject=' + dradis.version + '%20feedback">feedback</a></h1>'
            }
          ]
        })
      },
      nodestree,
      dradistabs,
      new Ext.Panel({
        region: 'south',
        border: false,
        welcome:{},
        bbar: dradisstatus
      })
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

  if (dradis.firstrender){
    dradisstatus.items.get(0).toggle();
  }

  // This is how rails provides feedback, through the flash[:notice] and 
  // flash[:error] variables. Checkout the ./app/views/postauth.html.erb
  // to locate the corresponding <div> elements
  var notice = Ext.getDom('notice');
  if ( notice != null){
    Ext.Msg.show({
      title: 'Notice', 
      msg: notice.innerHTML,
      buttons: Ext.Msg.OK,
      icon: Ext.Msg.INFO
    });
  }
  var error = Ext.getDom('error');
  if ( error != null){
    Ext.Msg.show({
      title: 'Error', 
      msg: error.innerHTML,
      buttons: Ext.Msg.OK,
      icon: Ext.Msg.ERROR
    });

  }

  // Only install the Ajax callbacks once the ViewPort has been rendered, 
  // otherwise the first Ajax call may return before the dradisstatus has been
  // rendered and cause an exception
  vp.on('afterrender', function(){
    // --- all-purpose general Ajax handlers to update the Status bar message
    Ext.Ajax.on('beforerequest', function(){ dradisstatus.showBusy(); }); 
    Ext.Ajax.on('requestcomplete', function(){ dradisstatus.clearStatus({useDefaults:true}); }); 

  });

  var csrf_token =  Ext.select('meta[name=csrf-token]').item(0).getAttribute('content');
  Ext.Ajax.defaultHeaders = { 'X-CSRF-Token': csrf_token };

  // we need to add this two here instead of inside the widget files because we
  // have to wait until the DOM is loaded to access the <meta> tags.
  attachments.fields.uploader.uploader.baseParams['authenticity_token'] = csrf_token;
  uploaders.fields.form.add( new Ext.form.Hidden({name:'authenticity_token', value: csrf_token}) );

  pollingTask.after = dradis.last_audit;
  // Delay status polling 20 secs so the initial GUI and Ajax calls are already
  // rendered and completed.
  new Ext.util.DelayedTask(function(){
    Ext.TaskMgr.start(pollingTask);
  }).delay(15000);
  
  plugins.refresh();
});
