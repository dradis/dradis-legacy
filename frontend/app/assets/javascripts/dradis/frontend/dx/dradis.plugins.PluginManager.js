Ext.ns('dradis');
Ext.ns('dradis.plugins');

Ext.ns('dradis.plugins.import');
Ext.ns('dradis.plugins.export');
Ext.ns('dradis.plugins.upload');

/*
 * This class is used to keep track of the installed plugins in the server. At 
 * some point it will manage import/export/upload plugins. It does this by 
 * creating DataStore object that pull from the server the list of available
 * plugins and providing helper methods an objects for the other widgets to use.
 */
dradis.plugins.PluginManager = function(){
  var exporters = new Ext.menu.Menu({});
  var exportPluginsDS = new Ext.data.JsonStore({
    url:'export/list/plugins.json',
    fields: ['name', 'actions'],
    listeners:{
      datachanged: function(store){
        exporters.removeAll();
        var item; // the menu item
        store.each(function(record){
          item = new Ext.menu.Item({ text: Ext.util.Format.htmlEncode(record.data.name) });
          if (record.data.actions.length == 0) 
          { 
            item.disabled = true; 
          } else if (record.data.actions.length == 1)
          {
            item.on('click', function(){ window.location.href = 'export/'+record.data.actions[0]; });
          } else
          {
            item.menu = new Ext.menu.Menu({});
            var action;
            var label;
            for ( var i =0; i<record.data.actions.length; i++){
              action = record.data.actions[i];
              label = Ext.util.Format.capitalize( action.replace(/_/g, ' ') );
              item.menu.add( new Ext.menu.Item({ text: label, url: 'export/' + action, handler: function(){ window.location.href = this.url; } }) );
            };
          }
          exporters.add(item);
        });
      }
    }
  });
  var uploadPluginsDS = new Ext.data.JsonStore({
    url:'upload/list/plugins.json',
    fields: ['name', 'plugin']
  });


  /*
   * A menu containing all the available Export plugins
   */
  this.exportPluginsMenu = function(){
    return exporters;
  }

  /*
   * To access the internal +upload+ plugins data store
   */
  this.getUploadPluginsStore = function(){ return uploadPluginsDS; }

  var importPluginsDS = new Ext.data.JsonStore({
    url:'import/sources/list.json',
    fields: ['value', 'display']
  });

  /*
   * To access the internal +upload+ plugins data store
   */
  this.getImportPluginsStore = function(){ return importPluginsDS; }



  /*
   * Get a new list of installed plugins from the server. You should not forget
   * that rails only refreshes the plugin list upon server restart.
   */
  this.refresh = function(){
    exportPluginsDS.load();
    uploadPluginsDS.load();
    importPluginsDS.load();
  }

};

