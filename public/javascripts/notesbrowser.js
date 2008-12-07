


// ------------------------------------------ data stores

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
      updatecategory(record, function(new_id){ categoriesDS.load(); } );
    },
    datachanged: function(store){
      categoriesMenu.removeAll();
      var item; // the menu item
      store.each(function(record){
        item = new Ext.menu.Item({
                    text: record.data.name,
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
                    },
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

// this could be inline, but we want to define the Note record
// type so we can add records dynamically
var Note = Ext.data.Record.create([
  {name: 'text', type: 'string'}, 
  {name: 'author', type: 'string'}, 
  {name: 'category', mapping: 'category-id'}, 
  {name: 'node', mapping: 'node-id'}, 
  // date format: 2008-04-10T12:30:29+01:00
  { name: 'updated', mapping: 'updated-at', type: 'date', dateFormat: 'c'}
  ]);


// create the Data Store
var store = new Ext.data.Store({
  // load using HTTP
  url: '/nodes/1/notes.xml',

  // the return will be XML, so lets set up a reader
  reader: new Ext.data.XmlReader(
    {// format of the XML
      // records will have an "Item" tag
      record: 'note',
      id: 'id',
    }, 
    // records for the grid
    Note
  ),
  listeners: {
    add: function(store, records, index) {
      var note = records[index];
      addnote(note, function(new_id){ note.id = new_id })
    },
    update: function(store, record, operation){
      var p = record.data;
      p.authenticity_token = dradis.token;
      Ext.Ajax.request({
        url: '/json/note_update?id='+record.id,
        params: p, 
        success: function(response, options) {
          dradisstatus.setStatus({ 
            text: 'Data sent to the server',
            clear: 5000
          });
        },
        failure: function(response, options) {
          dradisstatus.setStatus({
            text: 'An error occured with the Ajax request',
            iconCls: 'error',
            clear: 5000
          });
        },
      })

    },
    loadexception: function(proxy, options, response, error) {
      dradisstatus.setStatus({
        text: 'Error loading notes from server',
        iconCls: 'error',
        clear: 5000
      });
      console.log('error loading records from server:');
      console.log("\tfile: "+error.fileName);
      console.log("\tline: "+error.lineNumber);
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
      dataIndex: 'category', 
      renderer:Ext.util.Format.htmlEncode,
      editor: new Ext.form.ComboBox({
                              id: 'category-id',
                              lazyRender: true,
                              store: categoriesDS,
                              displayField: 'name',
                              valueField: 'id',
                              allowBlank: false,
                              mode: 'local',
                              triggerAction: 'all',
                  }),
      renderer: function(value, metadata, record, rowIndex, colIndex, store) {
                  var idx = categoriesDS.find('id', value);
                  return categoriesDS.getAt(idx).get('name');
                  },
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
      renderer: Ext.util.Format.dateRenderer('m/d/Y h:i'), 
      dataIndex: 'updated',
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
              var n = new Note( {
                            text: 'New note', 
                            category: 1, 
                            node: notesbrowser.selectedNode,
                            author: dradis.author, 
                            updated: Date()//.parseDate('2008-10-27T12:00:00+01:00', 'c')
              });
              grid.stopEditing();
              store.insert(0, n);
              grid.startEditing(0,1);
            }
          }, 
          '-', 
          {
            text:'note categories',
            tooltip:'Manage note categories',
            iconCls:'options',
            menu: categoriesMenu,
          },
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
    conn.url = '/nodes/' + node_id + '/notes.xml';
    conn.method = 'GET';
    categoriesDS.load();
    store.load();
  }
});

Ext.reg('notesbrowser', dradis.NotesBrowser);
