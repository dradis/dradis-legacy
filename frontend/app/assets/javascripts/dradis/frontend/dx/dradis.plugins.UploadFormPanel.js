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
      fileUpload:true,
      url: 'upload/import/',
      defaults:{
        allowBlank:false,
        anchor:'100%'
      },
      //bodyStyle: 'padding:0 10px 0;',
      items:[ 
        {
          xtype:'combo',
          fieldLabel:'Available formats',
          displayField:'name',
          valueField:'plugin',
          name:'uploader',
          hiddenName:'uploader',
          mode:'local',
          store: this.manager.getUploadPluginsStore()
        },
        {
          xtype:'fileuploadfield',
          id:'form-file',
          emptyText:'Select a file',
          buttonText:'',
          fieldLabel: 'Select a file',
          name:'file',
          buttonCfg:{ iconCls:'icon-form-magnify' }
        }
      ],
      buttons:[
        {
          text:'Upload',
          scope:this,
          handler:function() { this.onUpload(); }
        },
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

    this.addEvents('cancel', 'uploadsuccess', 'uploadfailure');

    // After parent code
    // e.g. install event handlers on rendered component
    this.manager.getUploadPluginsStore().on('datachanged', function(store) {
      // TODO: do we really need this? The plugin list doesn't change until 
      // the server restarts...
    }, this);

  },
  onUpload: function(){
    if(this.getForm().isValid()){
      // FIXME: The proper way of handling this would be to subclass 
      // Ext.form.Action to use dradis.ajax instead of Ext.ajax...

      this.getForm().submit({
        waitMsg: 'Uploading file...',
        scope: this,
        success: function(form, action){
          this.fireEvent('uploadsuccess');
        },
        failure: function(form, action){
          var response;
          response = Ext.util.JSON.decode( action.response.responseText );
          this.fireEvent('uploadfailure', response);
        } 
      });
    }
  }
});


dradis.plugins.UploadFormWindow=Ext.extend(Ext.Window, {
  //props (overridable by caller)
  title:'Import from file',
  width: 290,
  height: 150,
  modal:true,
  closeAction:'hide',
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

    // We relay the events fired by the form so the interface can handle it, 
    // but internally we also provide a handler that closes the window.
    this.relayEvents( this.fields.form, ['cancel', 'uploadsuccess', 'uploadfailure']);

    this.fields.form.on('uploadsuccess', function(){
      this.hide();
    }, this);

    this.fields.form.on('uploadfailure', function(){
      this.hide();
    }, this);

    this.fields.form.on('cancel', function(){
      this.hide();
    }, this);

  }

  // other methods/actions
});

