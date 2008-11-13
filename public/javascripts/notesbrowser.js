Ext.ns('dradis');


// ------------------------------------------ data stores

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
              )
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
    // TODO: think REST please!!!
    add: function(store, records, index) {
      var p = records[index].data;
      p.authenticity_token = dradis.token;
      Ext.Ajax.request({
        url: '/json/note_create',
        params: p, 
        //{ note: Ext.encode(records[index].data) },
        success: function(response, options) {
          dradisstatus.setStatus({ 
            text: 'New note sent to the server',
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
      sortable: false, 
      dataIndex: 'category', 
      renderer:Ext.util.Format.htmlEncode,
      editor: new Ext.form.ComboBox({
                              id: 'category-id',
                              lazyRender: true,
                              selectOnFocus: true,
                              store: categoriesDS,
                              displayField: 'name',
                              valueField: 'id',
                              allowBlank: false,
                              mode: 'local',
                              //hideTrigger: true,
                              selectOnFocus: false,
                  }),
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
                            author: 'etd', 
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
            iconCls:'options'
          },
          '-',
          'filter notes by: ',
          {
            xtype: 'combo',
            store: categoriesDS,
            triggerAction: 'all',
            emptyText:'select a category...',
            selectOnFocus:true,
            displayField: 'name'
          }
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
