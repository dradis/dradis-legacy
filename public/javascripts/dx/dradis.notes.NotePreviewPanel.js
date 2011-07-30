// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.notes');

dradis.notes.NotePreviewPanel=Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  region: 'center',
  autoScroll: true,
  border: true,
  bodyCssClass: 'preview',
  rawText: '',

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.notes.NotePreviewPanel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
  },

  // other methods/actions
  clear:function(){ 
    if (this.body) {
      this.body.update('');
    }
  },

  update:function(rawText){
    if (rawText != this.rawText)
    {
      this.body.update('<div class="loading-indicator">Loading...</div>');
      Ext.Ajax.request({
        url: 'home/textilize/index.json', 
        params: { text: rawText },
        scope: this,
        success:function(response, options){
          var html = Ext.decode(response.responseText).html;
          this.body.update(html);
          this.rawText = rawText;
        },
        failure:function(response,options){
          dradisstatus.setStatus({
            text: 'Could not get a text preview',
            iconCls: 'error',
            clear: 5000
          });
        }
      });
    }
  }

});

Ext.reg('notepreview', dradis.notes.NotePreviewPanel); 
