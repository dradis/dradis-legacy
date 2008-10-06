Ext.ns('dradis');


// ------------------------------------------------ XML data store & grid

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
    // date format: 2008-04-10T12:30:29+01:00
    [ 'text', 'author', { name: 'updated-at', type: 'date', dateFormat: 'c'}  ]
  )
});

var expander = new Ext.grid.RowExpander({
  tpl: new Ext.Template( '<p><b>Full text</b>:</p>', '<pre>{text:htmlEncode}</pre>')
});

var grid = new Ext.grid.GridPanel({
  store: store,
  columns: [
    //{id:'company',header: "Company", width: 60, sortable: true, dataIndex: 'company'},
    expander,
    {header: 'Text', width: 180, sortable: false, dataIndex: 'text', renderer:Ext.util.Format.htmlEncode},
    {header: 'Author', width: 40, sortable: true, dataIndex: 'author', renderer:Ext.util.Format.htmlEncode},
    {header: "Last Updated", width: 20, sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y h:i'), dataIndex: 'updated-at'}
  ],

  //view: new Ext.grid.GroupingView({
  //    forceFit:true,
  //    groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
  //}),
  viewConfig: { forceFit: true },

  border: false,
  autoHeight: true,
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
            iconCls:'add'
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
