// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.notes');

/**************************************************************** Categories */
dradis.notes.CategoriesManager = Ext.extend(Ext.Component, {
  //props (overridable by caller)
  store: new Ext.data.JsonStore({
    url: '/categories.json',
    root: 'data',
    fields: ['id', 'name'],
    autoSave: true,
    restful: true,
    writer: new Ext.data.JsonWriter()
  }),

  menu: new Ext.menu.Menu({store: this.store}),

  renderer: function(value, metadata, record, rowIndex, colIndex, store) {
    var idx = this.store.find('id', value);
    return this.store.getAt(idx).get('name');
  },

  editor: function() {
    return new Ext.form.ComboBox({
    id: 'category-id',
    lazyRender: true,
    store: this.store,
    displayField: 'name',
    valueField: 'id',
    allowBlank: false,
    mode: 'local',
    triggerAction: 'all'
    });
  },


  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
    }

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);
    // Before parent code

    // Call parent (required)
    dradis.notes.CategoriesManager.superclass.initComponent.apply(this, arguments);
     
    // After parent code
    // e.g. install event handlers on rendered component
    this.addEvents('refresh');

    this.store.on('datachanged', this.onDataChanged, this);
  },

  // other methods/actions
  load: function(){ 
    this.store.load(); 
  },

  onDataChanged: function(){
    var item;
    
    var handlers = {
      edit: this.editRecord
    };
    this.menu.removeAll();      
    this.store.each(function(record){
      item = new Ext.menu.Item({ 
        text: Ext.util.Format.htmlEncode(record.get('name')),
        menu: new Ext.menu.Menu({
          record: record,
          items: [
            { 
              text: 'Edit', 
              iconCls: 'Edit',
              scope: this,
              handler: function(){
                Ext.MessageBox.prompt( 'Edit Category',
                  'Please enter the new category name:',
                  function(btn, text){
                    var cat = text.trim();
                    if ((btn == 'ok')&&(cat.length > 0)) {
                      record.set('name', cat);
                      this.onDataChanged();
                    }
                  },
                  this,
                  false,
                  record.data.name
                );
              }
            },
            { 
              text: 'Delete', 
              iconCls: 'Del', 
              scope: this,
              handler: function(){ 
                this.store.remove( record );
                this.onDataChanged();
              } 
            }
          ]
        })
      });
      this.menu.add(item);
    }, this);
    this.menu.addSeparator();
    this.menu.add({
      text: 'add category...',
      iconCls: 'add',
      scope: this,
      handler: function(){
        Ext.MessageBox.prompt( 'New Category',
          'Please enter the new category name:',
          function(btn, text){
            var cat = text.trim();
            if ((btn == 'ok')&&(cat.length > 0)) {
              this.store.insert(
                this.store.getTotalCount(),
                new this.store.recordType({name: cat }));
              this.onDataChanged();
            }
          }, 
          this);
      }
    });

    this.fireEvent('refresh');
  }

});

/********************************************************************** Grid */
dradis.notes.Grid=Ext.extend(Ext.grid.EditorGridPanel, {
  //props (overridable by caller)
  height: 150,
  region: 'north',
  split: true,
  enableDragDrop: true,
  ddGroup: 'gridDDGroup',
  sm: new Ext.grid.RowSelectionModel(),
  categories: undefined,

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      store: new Ext.data.GroupingStore({
        url: '/nodes/1/notes.json',
        reader: new Ext.data.JsonReader({ 
          root: 'data',
          fields: [
            'text', 'category_id', 'author', 'node_id',
            {name: 'updated_at', type: 'date', dateFormat: 'c'}
          ]
        }),
        writer: new Ext.data.JsonWriter(),
        baseParams: { authenticity_token: dradis.token },
        restful: true,
        autoSave: true,
        sortInfo:{ field: 'text', direction: 'ASC' },
        groupField: 'category_id'
      }),
      columns: [
        {
          id:'text',
          header: 'Text', 
          width: 180, 
          sortable: true, 
          dataIndex: 'text',
          renderer: Ext.util.Format.htmlEncode
        },
        {
          header: 'Category', 
          width: 40, 
          sortable: true, 
          dataIndex: 'category_id',
          renderer: { fn: this.categories.renderer, scope: this.categories },
          editor: this.categories.editor()
        },
        {
          header: 'Author', 
          width: 20, 
          sortable: true, 
          dataIndex: 'author',
          renderer: Ext.util.Format.htmlEncode,
          editor:  new Ext.form.TextField({allowBlank: false})
        },
        {
          header: 'Last Updated', 
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
      autoExpandColumn: 'text',
      view: new Ext.grid.GroupingView({ forceFit: true }),
      contextMenu: new Ext.menu.Menu({
          grid: this,
          record: undefined,
          items: [  { text: 'Delete Note', iconCls: 'del' } ],
          listeners: {
            itemclick: function(item){
              item.parentMenu.grid.getStore().remove( item.parentMenu.record );
            }
          }
      })
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.notes.Grid.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    this.on('celldblclick', function(grid, row, cell, evt){
      if (cell == 0) {
        var record = grid.getStore().getAt(row);
        this.fireEvent('editnote', record);
      }
    });

    this.on('rowcontextmenu', function(grid, row, evt){
      evt.stopEvent(); // avoid the user's browser context menu
      this.contextMenu.record = grid.getStore().getAt(row);
      this.contextMenu.showAt(evt.getXY());
    }, this);
  },

  // other methods/actions
  moveNoteToNode:function(noteId, nodeId){
    var note = this.store.getById(noteId);
    note.set('node_id', nodeId);
  },

  addNote:function(nodeId, noteText){
    this.store.proxy.conn.url = '/nodes/' + nodeId + '/notes.json';
    var record = new this.store.recordType({
      text: noteText,
      author: dradis.author,
      category_id: 1,
      updated_at: Date() 
    });
    this.store.insert(0, record);
  },

  load: function(node_id){
    var conn = this.store.proxy.conn;
    conn.url = '/nodes/' + node_id + '/notes.json';
    this.store.load();
  }
});



/*********************************************************** NotesBrowserPanel */
dradis.notes.NotesBrowserPanel=Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  title:'Notes',
  fields: {},
  selectedNode: 0,
  editor: new dradis.notes.NoteEditorWindow(),  // NoteEditorWindow
  note: undefined,                              // current note (for edit)
  categories: new dradis.notes.CategoriesManager(),

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      layout: 'border',
      border: false,
      tbar: new Ext.Toolbar({
        style: 'border: none;',
        items: [
          { 
            text: 'add note', 
            tooltip:'Add a new note to this element',
            iconCls: 'add', 
            scope: this,
            handler: this.onAddNote
          },
          '-',
          { 
            text: 'note categories', 
            tooltip:'Manage note categories',
            iconCls: 'options',
            menu: this.categories.menu
          },
          '-',
          { 
            iconCls: 'x-tbar-loading',
            tooltip: 'Refresh the list of notes',
            scope: this,
            handler: this.onRefresh
          }
        ]
      }),
      items: [
        this.fields.grid = new dradis.notes.Grid({ categories: this.categories }),
        this.fields.preview = new dradis.notes.NotePreviewPanel()
      ]
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.notes.NotesBrowserPanel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component

    //------------------------------------------------------------- grid events
    this.fields.grid.on('rowclick', function(grid, row, evt){
      var record = grid.getStore().getAt(row);
      this.fields.preview.update( record.get('text') );
    }, this);

    this.fields.grid.on('editnote', function(record){
      this.note = record;
      this.editor.show();
      this.editor.load(record);
      this.editor.center();
    }, this);

    //----------------------------------------------------------- editor events
    this.editor.on('save', function(newValue){
      if (this.note === undefined) {
        this.fields.grid.addNote(this.selectedNode, newValue);
      } else {
        this.note.set('text', newValue);
        this.fields.preview.update(newValue);
      }
      this.note = undefined;
    }, this);

    //------------------------------------------------------- categories events
    this.categories.on('refresh', function(){ 
      this.fields.grid.load(this.selectedNode);
      this.fields.preview.clear();
    }, this);
  },

  // Toolbar button handlers
  onAddNote: function(){
      this.note = undefined;
      this.editor.clear();
      this.editor.show();
      this.editor.center();
  },

  onRefresh: function(){
    this.updateNotes( this.selectedNode );
  }, 

  // other methods/actions
  updateNotes: function(node_id){
    this.selectedNode = node_id;
    this.categories.load();
    this.fields.grid.load(node_id);
    this.fields.preview.clear();
  },

  addNote: function(text){
    this.fields.grid.addNote( this.selectedNode, text );
  },

  moveNoteToNode: function(noteId, nodeId){
    this.fields.grid.moveNoteToNode(noteId, nodeId);
    this.updateNotes(this.selectedNode);
  }
});



Ext.reg('notespanel', dradis.notes.NotesBrowserPanel); 
