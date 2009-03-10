Ext.ns('dradis');

var importsourcesDS = new Ext.data.JsonStore({ 
                            url:'/import/list/sources.json', 
                            fields: ['name'] 
                      });

dradis.NotesImporter = Ext.extend(Ext.Panel, {
    // Prototype Defaults, can be overridden by user's config object
    title: 'Import from...',
    layout:'form',
    bodyStyle:'padding:10px',
    defaults:{anchor:'100%'},
 
    initComponent: function(){
        // Called during component initialization
        var config = {
          items:[
            {
              xtype:'combo', 
              fieldLabel:'External Source',
              store: importsourcesDS,
              displayField: 'name',
              valueField: 'name',
              mode:'local',
              listeners:{
                change: function(){ 
                  this.fireEvent('sourcechange', this, 1, 2); 
                }
              }
            },
            {xtype:'combo', fieldLabel:'Filter', disabled:true},
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
    },
 
    // Override other inherited methods 
    updateSources: function(node_id){ 
      importsourcesDS.load();
    }
});
 
// register xtype to allow for lazy initialization
Ext.reg('noteimporter', dradis.NotesImporter);

