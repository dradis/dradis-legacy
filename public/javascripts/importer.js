Ext.ns('dradis');

dradis.NotesImporter = Ext.extend(Ext.Panel, {
    // Prototype Defaults, can be overridden by user's config object
    title: 'Import from...',
 
    initComponent: function(){
        // Called during component initialization
 
        // Config object has already been applied to 'this' so properties can 
        // be overriden here or new properties (e.g. items, tools, buttons) 
        // can be added, eg:
        Ext.apply(this, {
            propA: 3
        });
 
        // Before parent code
 
        // Call parent (required)
        dradis.NotesImporter.superclass.initComponent.apply(this, arguments);
 
        // After parent code
        // e.g. install event handlers on rendered component
    },
 
    // Override other inherited methods 
});
 
// register xtype to allow for lazy initialization
Ext.reg('noteimporter', dradis.NotesImporter);

