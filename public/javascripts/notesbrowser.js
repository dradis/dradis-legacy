Ext.ns('dradis');


// ------------------------------------------ Note record & XML data store

// this could be inline, but we want to define the Note record
// type so we can add records dynamically
var Note = Ext.data.Record.create([
  {name: 'text', type: 'string'}, 
  {name: 'author', type: 'string'}, 
  {name: 'category', mapping: 'category-id'}, 
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
  )
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
                              lazyRender: true,
                              lazyInit: false,
                              mode: 'local',
                              selectOnFocus: true,
                              store: [ 'category #1', 'category #2', 'category #3']
                  })
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
                            category: 2, 
                            author: 'etd', 
                            updated: Date.parseDate('2008-10-27T12:00:00+01:00', 'c')
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
            store: ['high', 'low', 'medium'],
            triggerAction: 'all',
            emptyText:'select a category...',
            selectOnFocus:true,
          }
        ],

        items: [
          grid
        ]

    });
    dradis.NotesBrowser.superclass.constructor.apply(this, arguments);
};

Ext.extend(dradis.NotesBrowser, Ext.Panel, {
  updateNotes: function(note_id){ 
    var conn = grid.getStore().proxy.conn;
    conn.url = '/nodes/' + note_id + '/notes.xml';
    store.load();
  }
});

Ext.reg('notesbrowser', dradis.NotesBrowser);
