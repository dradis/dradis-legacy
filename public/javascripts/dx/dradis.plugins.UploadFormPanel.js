Ext.ns('dradis');
Ext.ns('dradis.plugins');

dradis.plugins.UploadFormPanel=Ext.extend(Ext.FormPanel, {
  //props (overridable by caller)
  frame: true,
  labelWidth: 75,
  manager: null, // a reference to the app's plugin manager

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      width: 300,
      height: 100,

      //bodyStyle: 'padding:0 10px 0;',
      items:[ 
        {
          xtype:'combo',
          fieldLabel:'Available formats',
          displayField:'name',
          valueField:'format',
          allowBlank:false,
          mode:'local',
          store: this.manager.getUploadPluginsStore(),
          anchor: '100%'
        },
        {
          xtype:'fileuploadfield',
          fieldLabel: 'Select a file',
          anchor: '100%'
        }
      ],
      buttons:[
        {text:'Upload'},
        {
          text:'Cancel',
          scope: this,
          handler: function(){
            this.fireEvent('cancel');
          }
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
    dradis.plugins.UploadFormPanel.superclass.initComponent.apply(this, arguments);

    this.addEvents('cancel');

    // After parent code
    // e.g. install event handlers on rendered component
    this.manager.getUploadPluginsStore().on('datachanged', function(store) {
      // TODO: do we really need this? The plugin list doesn't change until 
      // the server restarts...
    }, this);

  }

});


dradis.plugins.UploadFormWindow=Ext.extend(Ext.Window, {
  //props (overridable by caller)
  title:'Import from file',
  width: 290,
  height: 150,
  fields:{},

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      layout: 'fit',
      minWidth: 290,
      minHeight: 150,
      
      items: [
        this.fields.form = new dradis.plugins.UploadFormPanel({manager: plugins})
      ]
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.plugins.UploadFormWindow.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    this.fields.form.on('cancel', function(){
      this.close();
    }, this);
  }

  // other methods/actions
});

