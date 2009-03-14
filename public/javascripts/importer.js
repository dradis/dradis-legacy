Ext.ns('dradis');
Ext.ns('dradis.importer');

dradis.importer.combo = Ext.extend(Ext.form.ComboBox, {
  displayField: 'name',
  valueField: 'name',
  allowBlank:false,
  mode:'local',
 
  initComponent: function(){
    //var config = {};
    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    //Ext.apply(this, config);
    //Ext.apply(this.initialConfig, config); 
      
    // Before parent code

    // Call parent (required)
    dradis.importer.combo.superclass.initComponent.apply(this, arguments);

    this.store = new Ext.data.JsonStore({ 
      url:this.initialConfig.url,
      fields:['name']
    });
  }
});

dradis.importer.setCascading = function(parentCombo, childCombo) {
  childCombo.setDisabled(!parentCombo.isValid());
  parentCombo.on('change', function() {
    childCombo.lastQuery = null;
    childCombo.clearValue();
    childCombo.setDisabled(!parentCombo.isValid());
  });

  childCombo.on('focus', function() {
    if(!childCombo.disabled) {
      var parentValue = parentCombo.getValue();
      var childParams = childCombo.store.baseParams;
      if(parentValue != childParams.ScopeId) {
        childParams.ScopeId = parentValue;
        childCombo.clearValue();
        childCombo.lastQuery = null;
        if(childCombo.mode != 'local') {
          childCombo.store.load();
        }
      }
    }
  });
};


dradis.NotesImporter = Ext.extend(Ext.Panel, {
    // Prototype Defaults, can be overridden by user's config object
    title: 'Import from...',
    layout:'form',
    bodyStyle:'padding:10px',
    defaults:{anchor:'100%'},
    fields:{},
 
    initComponent: function(){
        // Called during component initialization
        var config = {
          items:[
            this.fields.sources = new dradis.importer.combo({ 
                                        fieldLabel:'External Source', 
                                        url:'/import/sources/list.json'
                                      }),
            this.fields.filters = new dradis.importer.combo({
                                        fieldLabel:'Filter', 
                                        url:'/import/filters/list.json',
                                        mode:'remote',
                                        disabled:true
                                      }),
            {xtype:'textfield', fieldLabel:'Search for', disabled:true},
            {
              xtype:'grid', 
              fieldLabel:'Results',
              columns: [ {header:'Title'}, {header:'Description'} ],
              store: new Ext.data.SimpleStore({ fields:['Title', 'Description'], data:[ ['',''], ['',''], ['','']]}),
              autoExpandColumn:'1',
              disabled: true
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
        dradis.NotesImporter.superclass.initComponent.apply(this, arguments);
 
        // After parent code
        // e.g. install event handlers on rendered component
        dradis.importer.setCascading(this.fields.sources, this.fields.filters);
    },
 
    // Override other inherited methods 
    updateSources: function(node_id){ 
      this.fields.sources.store.load();
    }
});
 
// register xtype to allow for lazy initialization
Ext.reg('noteimporter', dradis.NotesImporter);

