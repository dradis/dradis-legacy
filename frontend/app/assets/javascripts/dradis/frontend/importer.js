Ext.ns('dradis');
Ext.ns('dradis.importer');

dradis.importer.Combo = Ext.extend(Ext.form.ComboBox, {
  displayField: 'display',
  valueField: 'value',
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
    dradis.importer.Combo.superclass.initComponent.apply(this, arguments);

    this.store = new Ext.data.JsonStore({ 
      url:this.initialConfig.url,
      fields:['display', 'value']
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
      if(parentValue != childParams.scope) {
        childParams.scope = parentValue;
        childCombo.clearValue();
        childCombo.lastQuery = null;
        if(childCombo.mode != 'local') {
          childCombo.store.load();
        }
      }
    }
  });
};


dradis.importer.Panel = Ext.extend(Ext.Panel, {
    // Prototype Defaults, can be overridden by user's config object
    title: 'Import note...',
    layout:'form',
    bodyStyle:'padding:10px',
    defaults:{anchor:'100%'},
    fields:{},
 
    initComponent: function(){
        // Called during component initialization
        var config = {
          items:[
            this.fields.sources = new dradis.importer.Combo({ 
                                        fieldLabel:'External Source', 
                                        url:'import/sources/list.json'
                                      }),
            this.fields.filters = new dradis.importer.Combo({
                                        fieldLabel:'Filter', 
                                        url:'import/filters/list.json',
                                        mode:'remote',
                                        disabled:true
                                      }),
            this.fields.input = new Ext.form.TextField({
                                      fieldLabel:'Search for', 
                                      allowBlank:false,
                                      disabled:true
                                    }),
            this.fields.results = new Ext.grid.GridPanel({
              fieldLabel:'Results',
              columns: [ {header:'Title'}, {header:'Description', id:'description'} ],
              store: new Ext.data.JsonStore({
                url:'import/query/results.json',
                fields:['title','description']
              }),
              autoExpandColumn:'description',
              autoHeight:false,
              height: 300,
              disabled: true
            })
          ]          
        };
 
        // Config object has already been applied to 'this' so properties can 
        // be overriden here or new properties (e.g. items, tools, buttons) 
        // can be added, eg:
        Ext.apply(this, config);
        Ext.apply(this.initialConfig, config); 
        
        // Before parent code
 
        // Call parent (required)
        dradis.importer.Panel.superclass.initComponent.apply(this, arguments);
 
        // After parent code
        // e.g. install event handlers on rendered component
        dradis.importer.setCascading(this.fields.sources, this.fields.filters);

        this.addEvents('importrecord');
        //------------------------------------ event handlers

        // When the Filters combo changes, disable/enable the Search field
        this.fields.filters.on('change', function(combo, newValue, oldValue){
          if (!combo.isValid() || (newValue == 'invalid')){
            this.fields.input.setDisabled(true);
          } else {
            this.fields.input.setDisabled(false);
          }
        }, this);

        // When the user hits Enter in the search field, we should launch the
        // query in an Ajax call.
        this.fields.input.on('specialkey',function(field, ev){
          if ( field.isValid() && (ev.getKey() == ev.ENTER)){
            this.updateResults();
          }
        }, this);

        this.fields.results.on('rowcontextmenu',function(grid, row, ev){
          var menu = new Ext.menu.Menu({
            row: row,
            items:[ 
              {
                text:'import this', 
                iconCls:'add',
                scope: this,
                handler:function(item, ev){
                  this.fireEvent('importrecord', this.fields.results.store.getAt(item.parentMenu.row));
                }
              } 
            ]
          });
          menu.showAt(ev.getXY());
          ev.stopEvent();
        }, this);
    },
 
    // Override other inherited methods 
    setImportStore: function(new_store){
      this.fields.sources.store = new_store;
    },

    updateResults: function(){
      this.fields.results.store.removeAll();
      this.fields.results.store.load({
        params:{
          scope:this.fields.sources.getValue(),
          filter:this.fields.filters.getValue(),
          query:this.fields.input.getValue()
        },
        callback:function(records, options, success){
          if (this.fields.results.store.getCount() > 0){
            this.fields.results.setDisabled(false);
          }
        },
        scope:this
      });	
    }
});
 
// register xtype to allow for lazy initialization
Ext.reg('noteimporter', dradis.importer.Panel);

