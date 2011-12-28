// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.notes');

/**************************************************************** Categories */
dradis.notes.CategoriesManager = Ext.extend(Ext.Component, {
  //props (overridable by caller)
  store: new Ext.data.JsonStore({
    url: 'categories.json',
    root: 'data',
    fields: ['id', 'name'],
    autoSave: true,
    restful: true,
    writer: new Ext.data.JsonWriter()
  }),

  menu: new Ext.menu.Menu({store: this.store}),

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

    this.store.on('add', this.added, this)
  },

  // other methods/actions
  load: function(){ 
    this.store.load(); 
  },

  added: function(store){
    store.reload();
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
                new this.store.recordType({name: cat}));
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
        url: 'nodes/1/notes.json',
        reader: new Ext.data.JsonReader({ 
          root: 'data',
          fields: [
            'text', 'category_id', 'author', 'node_id',
            {name: 'updated_at', type: 'date', dateFormat: 'c'}
          ]
        }),
        writer: new Ext.data.JsonWriter(),
        restful: true,
        autoSave: true,
        sortInfo:{ field: 'text', direction: 'ASC' },
        groupField: 'category_id'
      }),
      columns: [
        {
          id:'text',
          header: 'Summary',
          width: '100%',
          sortable: true, 
          dataIndex: 'text',
          renderer: this.textRenderer
          //renderer: Ext.util.Format.htmlEncode
        },
        {
          header: 'Category', 
          hidden: true,
          sortable: true, 
          dataIndex: 'category_id',
          scope: this.categories,
          renderer: this.categoryRenderer,
          editor: this.categories.editor()
        }/*,
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
        */
      ],
      autoExpandColumn: 'text',
      view: new Ext.grid.GroupingView({ forceFit: true }),
      contextMenu: new Ext.menu.Menu({
          grid: this,
          record: undefined,
          items: [
            { text: 'Assign to...', iconCls: 'options', menu:{ items:[] } },
            { text: 'Delete Note', iconCls: 'del' }
          ],
          listeners: {
            itemclick: function(item){
              var s1 = item.parentMenu.grid.getStore();
              var s2 = item.parentMenu.grid.store;
              item.parentMenu.grid.getStore().remove( item.parentMenu.record );
              item.parentMenu.grid.fireEvent('modified');
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
    this.addEvents('editnote', 'modified');

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

  textRenderer: function(value, metadata, record, rowIndex, colIndex, store) {
    var template = new Ext.XTemplate(
      '<tpl for=".">',
        '<div>',
          '{value}',
          '<div style="text-align: right; font-size: 90%; color: #ccc;">',
            '<div style="float: left;">{author}</div>',
            '{date}',
          '</div>',
        '</div>',
      '</tpl>', '<div class="x-clear"></div>'
    );
    var regexp = /#\[Title\]#\n(.*)/;
    var matchArray;
    if (matchArray = regexp.exec(value))
    {
      value = matchArray[1];
    }
    var values = {
      value: Ext.util.Format.htmlEncode(value),
      author: Ext.util.Format.htmlEncode(record.get('author')),
      date: Ext.util.Format.date( record.get('updated_at'), 'd M Y h:i')
    };
    return template.apply(values);
  },
  categoryRenderer: function(value, metadata, record, rowIndex, colIndex, store) {
    var idx = notesbrowser.categories.store.find('id', value);
    return notesbrowser.categories.store.getAt(idx).get('name');
  },


  // other methods/actions
  moveNoteToNode:function(noteId, nodeId){
    var note = this.store.getById(noteId);
    note.set('node_id', nodeId);
  },

  addNote:function(nodeId, noteText){
    this.store.proxy.conn.url = 'nodes/' + nodeId + '/notes.json';
    var record = new this.store.recordType({
      text: noteText,
      author: dradis.author,
      category_id: 1,
      updated_at: Date() 
    });
    this.store.insert(0, record);
    this.store.commitChanges();
  },

  load: function(node_id){
    this.store.proxy.setUrl( 'nodes/' + node_id + '/notes.json', true );
    this.store.load();
  },

  updateContextMenu: function(){
    var categoriesMenu = this.contextMenu.get(0).menu;
    categoriesMenu.removeAll();
    this.categories.store.each(function(record){
      item = new Ext.menu.Item({
        text: Ext.util.Format.htmlEncode(record.get('name')),
        categoryId: record.get('id'),
        scope: this,
        handler: function(item, evt){
          var record = item.parentMenu.parentMenu.record;
          var grid = item.parentMenu.parentMenu.grid;
          record.set('category_id', item.categoryId);
          grid.getView().refresh();
        }
      });
      this.add(item);
    }, categoriesMenu);
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
  dirtyView: false,

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
        this.fields.grid = new dradis.notes.Grid({ categories: this.categories, region: 'west', width: '20%' }),
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
    this.fields.grid.selModel.on('selectionchange', function(grid){
      if (grid.selections.length > 0) {
        // For the time being if multiple rows are selected, preview the last
        // one. Maybe in the future we should preview multiple notes.
        var last_selected = grid.selections.length - 1;
        this.fields.preview.update( grid.selections.items[last_selected].get('text') );
      }
    }, this);

    this.fields.grid.on('editnote', function(record){
      this.note = record;
      this.editor.show();
      this.editor.load(record);
      this.editor.center();
    }, this);

    this.fields.grid.on('modified', function(){
      this.fields.preview.clear();
    }, this);

    //----------------------------------------------------------- editor events
    this.editor.on('save', function(newValue){
      if (this.note === undefined) {
        this.fields.grid.addNote(this.selectedNode, newValue);
        this.fields.preview.clear();
      } else {
        this.note.set('text', newValue);
        this.fields.preview.update(newValue);
      }
      this.note = undefined;

      // There was a server update (e.g. other user added a note) while the
      // editor was open
      if (this.dirtyView) {
        this.onRefresh();
        this.dirtyView = false;
      }
    }, this);

    this.editor.on('cancel', function(){
      // There was a server update (e.g. other user added a note) while the
      // editor was open
      if (this.dirtyView) {
        this.onRefresh();
        this.dirtyView = false;
      }
    }, this)
    this.editor.on('hide', function(){
      // There was a server update (e.g. other user added a note) while the
      // editor was open
      if (this.dirtyView) {
        this.onRefresh();
        this.dirtyView = false;
      }
    }, this)

    //------------------------------------------------------- categories events
    this.categories.on('refresh', function(){ 
      this.fields.grid.load(this.selectedNode);
      this.fields.grid.updateContextMenu();
      this.fields.preview.clear();
    }, this);
  },

  // Toolbar button handlers
  onAddNote: function(){
      this.note = undefined;
      this.editor.show();
      this.editor.clear();
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
  },

  // When the poller detects there are some updates in the server for the
  // current node it invokes this function.
  markDirty: function() {
    if (this.editor.isVisible()){
      // we have to wait until the editor is done, set the dirty flag
      this.dirtyView = true;
    } else {
      // TODO: maybe in the future make onRefresh() take into account current
      // selections / state of the preview pane
      this.onRefresh();
    }
  }
});



Ext.reg('notespanel', dradis.notes.NotesBrowserPanel); 
