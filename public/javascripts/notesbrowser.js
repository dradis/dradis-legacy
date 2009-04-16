


// ------------------------------------------ data stores

var exportPluginsMenu = new Ext.menu.Menu({});
var exportPluginsDS = new Ext.data.JsonStore({
  url:'/export/list/plugins.json',
  fields: ['name', 'actions'],
  listeners:{
    datachanged: function(store){
      exportPluginsMenu.removeAll();
      var item; // the menu item
      store.each(function(record){
        item = new Ext.menu.Item({ text: Ext.util.Format.htmlEncode(record.data.name) });
        if (record.data.actions.length == 0) 
        { 
          item.disabled = true; 
        } else if (record.data.actions.length == 1)
        {
          item.on('click', function(){ window.location = '/export/'+record.data.actions[0]; });
        } else
        {
          item.menu = new Ext.menu.Menu({});
          var action;
          var label;
          for ( var i =0; i<record.data.actions.length; i++){
            action = record.data.actions[i];
            label = Ext.util.Format.capitalize( action.replace(/_/g, ' ') );
            item.menu.add( new Ext.menu.Item({ text: label, url: '/export/' + action, handler: function(){ window.location = this.url; } }) );
          };
        }
        exportPluginsMenu.add(item);
      });
    }
  }
});

var categoriesMenu = new Ext.menu.Menu({});
var categoriesDS = new Ext.data.Store({
  proxy: new Ext.data.HttpProxy(
                new Ext.data.Connection({
                      url: '/categories.xml',
                      method: 'GET'
                    })
              ),
  reader: new Ext.data.XmlReader(
                { record: 'category', id: 'id'},
                [ 
                  { name: 'id', type: 'string' },
                  { name: 'name', type: 'string' }
                ]
              ),
  listeners: {
    add: function(store,records,index){
      var cat = records[index];
      addcategory(cat, function(new_id){ categoriesDS.load(); });
    },
    remove: function(store, record, index){
      delcategory(record, function(new_id){ categoriesDS.load(); } );
    },
    update: function(store, record, operation){
      updatecategory(record, function(new_id){ 
        categoriesDS.load(); 
        // after renaiming a category, repaint the grid
        grid.getStore().load(); 
      });
    },
    datachanged: function(store){
      categoriesMenu.removeAll();
      var item; // the menu item
      store.each(function(record){
        item = new Ext.menu.Item({
                    text: Ext.util.Format.htmlEncode(record.data.name),
                    menu: {
                      items:[
                        { text: 'edit', 
                          iconCls: 'edit',
                          handler: function(){
                            Ext.MessageBox.prompt( 'Edit Category', 
                                  'Please enter the new category name:', 
                                  function(btn, text){ 
                                    var cat = text.trim();
                                    if ((btn == 'ok')&&(cat.length > 0)) {
                                      record.set('name', cat);
                                    }
                                  },
                                  undefined,
                                  false,
                                  record.data.name
                            );

                          }
                        },
                        { text: 'delete', 
                          iconCls: 'del', 
                          handler: function(){
                            categoriesDS.remove( record );
                          }
                        }
                      ]
                    }
                });
        categoriesMenu.add( item );
      });
      categoriesMenu.addSeparator();
      categoriesMenu.add({ 
        text: 'add category...', 
        iconCls: 'add',
        handler: function(){ 
          Ext.MessageBox.prompt( 'New Category', 
                                  'Please enter the new category name:', 
                                  function(btn, text){ 
                                    var cat = text.trim();
                                    if ((btn == 'ok')&&(cat.length > 0)) {
                                      categoriesDS.insert(0,new Ext.data.Record({name: cat })); 
                                    }
                                });
        }
      });
    }
  }
});


// ------------------------------------------ Note record & XML data store

// create the Data Store
var store = new Ext.data.JsonStore({
  // load using HTTP
  url: '/nodes/1/notes.json',
  id:'id',
  fields:['text', 'author', 'category_id', 'node_id', 'updated_at', 'created_at'],
  listeners: {
    add: function(store, records, index) {
      var note = records[index];
      addnote(note, function(new_id){ note.id = new_id })
    },
    update: function(store, record, operation){
      updatenote(record);
    },
    remove: function(store, record, index) {
      delnote(record);
    },
    loadexception: function(proxy, options, response, error) {
      dradisstatus.setStatus({
        text: 'Error loading notes from server',
        iconCls: 'error',
        clear: 5000
      });
    }
  }
});

// ------------------------------------------------------------------ grid
var expander = new Ext.grid.RowExpander({
  tpl: new Ext.Template( '<p><b>Full text</b>:</p>', '<pre>{text:htmlEncode}</pre>')
});

var grid = new Ext.grid.EditorGridPanel({
  store: store,
  autoExpandColumn: 'text',
  columns: [
    //{id:'company',header: "Company", width: 60, sortable: true, dataIndex: 'company'},
    expander,
    {
      header: 'Text', 
      width: 180, 
      sortable: false, 
      dataIndex: 'text', 
      renderer:Ext.util.Format.htmlEncode,
      editor:  new Ext.form.TextArea( {allowBlank: false, cls: 'talleditor', grow: true, growMin: 120} ),
      listeners: {
        beforeedit: function(e) 
        {
          alert('about to edit!');
          return true;
        },
        afteredit: function(e) 
        {
          alert('after edit!');
          return true;
        }

      }


    },
    {
      header: 'Category', 
      width: 40, 
      sortable: true, 
      dataIndex: 'category_id', 
      renderer:Ext.util.Format.htmlEncode,
      editor: new Ext.form.ComboBox({
                              id: 'category-id',
                              lazyRender: true,
                              store: categoriesDS,
                              displayField: 'name',
                              valueField: 'id',
                              allowBlank: false,
                              mode: 'local',
                              triggerAction: 'all'
                  }),
      renderer: function(value, metadata, record, rowIndex, colIndex, store) {
                  var idx = categoriesDS.find('id', value);
                  return categoriesDS.getAt(idx).get('name');
                  }
    },
    {
      header: 'Author', 
      width: 20, 
      sortable: true, 
      dataIndex: 'author', 
      renderer:Ext.util.Format.htmlEncode,
      editor: new Ext.form.TextField({allowBlank: false})
    },
    {
      header: "Last Updated", 
      width: 30, 
      sortable: true, 
      renderer: Ext.util.Format.dateRenderer('d M Y h:i'), 
      dataIndex: 'updated_at',
      editor: new Ext.form.DateField({
                format: 'm/d/y h:i',
                minValue: '01/01/08'
            })

      }
  ],

  //view: new Ext.grid.GroupingView({
  //    forceFit:true,
  //    groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
  //}),
  viewConfig: { forceFit: true },
  contextMenu: new Ext.menu.Menu({
                     items: [ {id: 'delete-note', text: 'Delete Note', iconCls: 'del'} ],
                     listeners: { 
                       itemclick: function(item) {
                         switch (item.id) {
                           case 'delete-note':
                             item.parentMenu.contextStore.remove( item.parentMenu.contextRecord );
                             break;
                         }
                       }
                     }
  }),
  listeners: { 
    beforeedit: function(e){
      expander.collapseRow(e.row);
    },
    rowcontextmenu: function(grid, row, e) {
      e.stopEvent();
      c = grid.contextMenu;
      c.contextStore = grid.store;
      c.contextRecord = grid.store.getAt(row);
      c.showAt( e.getXY() );
    }
  }, 

  border: false,
  //autoHeight: true,
  height: 600,
  iconCls: 'icon-grid',
  plugins: expander
});

// ------------------------------------------------ Panel: toolbar + grid 
// Constructor
dradis.NotesBrowser = function(config) {
    Ext.apply(this, {
        selectedNode: 0,
        title: 'Notes',
        layout: 'anchor',
        border: false,
        margins: '0 0 5 0',
        tbar: [  
          {
            text:'add note',
            tooltip:'Add a new note to this element',
            iconCls:'add',
            handler: function() {
              var new_note = new Ext.data.Record({
                text: 'text', 
                author: dradis.author, 
                category_id: 1, 
                node_id: notesbrowser.selectedNode, 
                updated_at: Date(),
                created_at: Date()
              });
              grid.stopEditing();
              store.insert(0, new_note);
              grid.startEditing(0,1);
            }
          }, 
          '-', 
          {
            text:'note categories',
            tooltip:'Manage note categories',
            iconCls:'options',
            menu: categoriesMenu
          },
          '-',
          {
            text: 'export',
            tooltip: 'export dradis contents to external sources',
            iconCls: 'export',
            menu: exportPluginsMenu
           }
          /*
          '-',
          'filter notes by: ',
          {
            xtype: 'combo',
            store: categoriesDS,
            mode: 'local',
            triggerAction: 'all',
            emptyText:'select a category...',
            selectOnFocus:true,
            displayField: 'name',
            valueField: 'id',
            forceSelection: true,
            listeners: {
              change: function(field, new_value, old_value) {
                        if (new_value.length == 0) {
                          store.clearFilter(false);
                        } else {
                          store.filter('category', new_value);
                        }
                      }
            }
          },
          {
            text: 'clear',
            disabled: true,
            handler: function(btn, e) {
              store.clearFilter(false);
              btn.disable();
            }
          },
          '-'
          */
        ],

        items: [
          grid
        ]

    });
    dradis.NotesBrowser.superclass.constructor.apply(this, arguments);
};

Ext.extend(dradis.NotesBrowser, Ext.Panel, {
  updateNotes: function(node_id){ 
    this.selectedNode = node_id;
    var conn = grid.getStore().proxy.conn;
    conn.url = '/nodes/' + node_id + '/notes.json';
    conn.method = 'GET';
    categoriesDS.load();
    exportPluginsDS.load();
    store.load();
  },
  addNote: function(text){
    var new_note = new  Ext.data.Record({
                        text: text, 
                        category_id: 1, 
                        node_id: notesbrowser.selectedNode,
                        author: dradis.author, 
                        updated_at: Date(),
                        created_at: Date()
                      });
    grid.stopEditing();
    store.insert(0, new_note);
    grid.startEditing(0,1);
  }
});
Ext.reg('notesbrowser', dradis.NotesBrowser);
