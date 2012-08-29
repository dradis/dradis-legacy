// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.notes');

/********************************************************************* Panel */
dradis.notes.NoteEditorPanel=Ext.extend(Ext.TabPanel, {
  //props (overridable by caller)
  fields: {},

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      deferredRender: false,
      border: false,
      items:[
        this.fields.editor = new Ext.form.TextArea({
          id: 'editor',
          title: 'Write',
          autoScroll: true,
          border: true,
          enableKeyEvents: true
        }),
        this.fields.preview = new dradis.notes.NotePreviewPanel({
          title: 'Preview'
        }),
        this.fields.attachments = new dradis.attachments.Viewer({
          title: 'Attachments',
          store: this.attachmentsStore
        })
      ],
      buttonAlign: 'left',
      buttons:[
        {
          xtype: 'tbtext',
          html: '<a href="javascript:dradis.notes.NoteEditorWindow.formatCheatSheet();">Formatting cheat sheet</a>',
        },
        '->',
        {
          text:'Save',
          scope:this,
          handler:function() { this.fireEvent('save', this.fields.editor.getValue()); }
        },
        {
          text:'Cancel',
          scope: this,
          handler: function(){ this.clear(); this.fireEvent('cancel'); }
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
    dradis.notes.NoteEditorPanel.superclass.initComponent.apply(this, arguments);

    this.addEvents('save', 'cancel');

    // After parent code
    // e.g. install event handlers on rendered component
    this.on( 'beforetabchange', function(panel, newTab, currentTab){
      if (newTab == this.fields.preview)
      {
        this.fields.preview.update(this.fields.editor.getValue());
      }
    });
  },

  // other methods/actions
  load: function(record){
    this.fields.editor.setValue( record.get('text') );
    this.fields.preview.update( record.get('text') );
    this.fields.attachments.load( record.get('node_id') );
  },

  clear: function(){
    this.fields.editor.setValue('');
    this.fields.preview.clear();
  }
});

/******************************************************************** Window */
dradis.notes.NoteEditorWindow=Ext.extend(Ext.Window, {
  //props (overridable by caller)
  title:'Note Editor',
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
        this.fields.panel = new dradis.notes.NoteEditorPanel()
      ]
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.notes.NoteEditorWindow.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    this.relayEvents(this.fields.panel, ['cancel', 'save']);

    this.fields.panel.on('cancel', function(){ this.hide(); }, this );

    this.fields.panel.on('save', function(){ this.hide(); }, this );

    this.on('beforeshow', function(){ 
      this.fields.panel.activate('editor');
      this.fields.panel.fields.editor.focus(false, 500)
    }, this);
  },

  // other methods/actions
  load: function(record){
    this.fields.panel.load(record);
  },

  clear: function(){ this.fields.panel.clear(); }
});

// Static method to show the formatting cheat sheet
dradis.notes.NoteEditorWindow.formatCheatSheet = function(){
  var modal = new Ext.Window({
    closeAction: 'hide',
    height: 400,
    layout: 'fit',
    modal: true,
    resizable: false,
    title: 'Formatting Cheat Sheet',
    width: 800,
    items: [
      {
        xtype: 'panel',
        contentEl: 'formatting-cheat-sheet'
      }
    ]
  });
  modal.show();
}



Ext.reg('noteeditor', dradis.notes.NoteEditorWindow); 
