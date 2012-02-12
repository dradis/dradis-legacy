/*
 * nodestree.js
 * 4 / NOV / 2008
 *
 * This file contains the class definition of tthe dradis.NodesTree() object
 * used to represent the hierarchy of nodes stored in the database.
 */
Ext.ns('dradis');

dradis.NodesTree = Ext.extend(Ext.tree.TreePanel, {
  //props (overridable by caller)
  region: 'west',
  width: 200,
  autoScroll: true,
  //border: false,
  split: true,
  useArrows:true,
  animate:true,

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      //------------------------------------------- standard TreePanel properties
      root: new Ext.tree.AsyncTreeNode({
        id: 'root-node',
        expanded: true
      }),
      rootVisible: false,
      enableDD:true,
      ddGroup: 'gridDDGroup',
      stateful:true,
      loader: new Ext.tree.TreeLoader({
        url: 'nodes.json',
        requestMethod: 'GET',
  	    createNode : function(attr){
          attr.text = Ext.util.Format.htmlEncode(attr.text);
          attr.iconCls = 'icon-node-'+ ['default','host'][attr.type];
          return Ext.tree.TreeLoader.prototype.createNode.call(this, attr);
        }
      }),

      tbar: [
        {
          text: 'add branch', 
          iconCls:'icon-folder-add',
          scope: this,
          handler: function() {
            var root = this.getRootNode();
            var label = 'branch #' + (root.childNodes.length +1);
            this.createNode(root, 0, label);
          }
        },    
        '-',
        {
          tooltip: 'Refresh the tree',
          iconCls:'x-tbar-loading',
          scope: this,
          handler: function(){ 
            this.refresh(); 
          }
        },
        {
          tooltip: 'Expand all',
          iconCls:'icon-expand-all',
          scope: this,
          handler: function(){ 
            this.expandAll(); 
          }
        },
        {
          tooltip: 'Collapse all',
          iconCls:'icon-collapse-all',
          scope: this,
          handler: function(){ 
            this.collapseAll(); 
          }
        }
      ],
      bbar: [],      
      //------------------------------------------- /standard TreePanel properties

      //------------------------------------------- custom NodesTree properties
      itemMenu: new Ext.menu.Menu({
        contextNode: null, // this will contain a reference to the right-clicked node
        items:[ 
        { 
          text: 'add child', 
          iconCls: 'add', 
          menu: {
            items: [
              {
                text: 'Default',
                iconCls: 'icon-node-default',
                scope: this,
                handler: function(){ this.createNode( this.itemMenu.contextNode, 0) }
              },
              {
                text: 'Host',
                iconCls: 'icon-node-host',
                scope: this,
                handler: function(){ this.createNode( this.itemMenu.contextNode, 1) }
              }

            ]
          }
        },
        { 
          text: 'delete node', 
          iconCls: 'del',
          scope: this,
          handler: function(){ this.deleteNode(this.itemMenu.contextNode); }
        },
        '-',
        {
          text: 'Type',
          menu: {
            items: [
              { 
                text: 'Default', 
                iconCls: 'icon-node-default', 
                scope: this,
                handler:function(){ this.changeNodeType(this.itemMenu.contextNode, 0) }
              },
              { 
                text: 'Host', 
                iconCls: 'icon-node-host',
                scope: this,
                handler:function(){ this.changeNodeType(this.itemMenu.contextNode, 1) }
              }
            ]
          }
        },
        '-',
        { 
          text: 'expand node', 
          iconCls: 'icon-expand-all',
          handler: function(){
            this.parentMenu.contextNode.expand(true);
          }
        },
        { 
          text: 'collapse node', 
          iconCls: 'icon-collapse-all',
          handler: function(){
            this.parentMenu.contextNode.collapse(true);
          }
        }
        ]
      }),
      hiddenNodes: []
      //------------------------------------------- /custom NodesTree properties


    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);

    // Before parent code

    // Call parent (required)
    dradis.NodesTree.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    // event definition for
    //  - node click: so we can refresh the list of notes
    //  - notes drop: so we can re-assign notes to a new neod
    this.addEvents('nodeclick', 'notesdrop');

    // Inline editor for the node labels
    this.editor = new Ext.tree.TreeEditor(this, {}, {
      cancelOnEsc: true,
      completeOnEnter: true,
      ignoreNoChange: true,
      selectOnFocus: true
    });

    // Filter text field that will be added to the Tool bar and perform the
    // filtering in the tree of nodes
    this.filterField = new Ext.form.TextField({
      width: 193,
      emptyText:'Find a Node',
      tree: this,
      listeners:{
        render: function(f){
            f.el.on('keydown', function(ev){
              this.tree.filterNodes(this.getValue());
            }, this, {buffer: 350});
        }
      }
    });
    // add the text field to the toolbar
    this.getBottomToolbar().add( this.filterField );

    // ==================================================== event handlers

    // Handle the context menu
    this.on('contextmenu', function(node, ev){
      // Register the context node with the menu so that a Menu Item's handler 
      // function can access it via its parentMenu property.
      node.select();
      node.expand();

      var contextMenu = this.itemMenu;
      contextMenu.contextNode = node;
      contextMenu.showAt(ev.getXY());
      ev.stopEvent();
    }, this);

    // Handle node click and selection change
    this.getSelectionModel().on('selectionchange', function(tree,node) {
      if (node) {
        this.fireEvent('nodeclick', node.id);
      }
    }, this);

    // Handle label edits
    this.on('textchange', function(node, new_text, old_text){
      this.updateNode(node, {label: new_text});
    });

    // Handle node drops (drag'n'drop)
    this.on('beforenodedrop', function(ev){

      // this is null only if we are dropping notes. Nodes would have a non
      // null value and the remaining code will never be executed.
      if ( ev.dropNode === null ){

        // we only support "append" drops for notes (no 'before'/'after' mode).
        if ( ev.point != 'append' ) { 
          dradisstatus.setStatus({ 
            text: 'Drop your notes inside a node.',
            iconCls: 'error'
          }); 
          return false; 
        }
 
        // fire the 'notesdrop' even so someone can move the notes to their new
        // node
        this.fireEvent('notesdrop', ev);
      }
    });

    this.on('nodedrop', function(ev) {
      var point = ev.point;
      var node = ev.dropNode;
      var p = { parent_id: null };
      if ( point == 'append') {
        p.parent_id = ev.target.id;
      } else {
        var parent = ev.target.parentNode;
        if (parent.id !== 'root-node') {
          p.parent_id = parent.id;
        }
      }
      // only update the parent if it changed, if parent didn't change it means
      // we are just sorting nodes.
      if (p.parent_id != node.attributes['parent_id'])
      {
        this.updateNode(node, p)
      }
      // sorting
      var params = "";
      Ext.each(node.parentNode.childNodes, function(node){
        params = params + "nodes[]=" + node.id + "&";
      });
      Ext.Ajax.request({
        url: 'nodes/sort.json',
        method: 'post',
        params: params,
        success: function(response, options) {
          dradisstatus.setStatus({text: 'New position saved', clear: 5000 });
        },
        failure: function(response, options) {
          dradisstatus.setStatus({text: 'Ajax error', iconCls: 'error', clear: 5000 });
        }
      });
    });

    // ==================================================== /event handlers
  },
  createNode: function(parent, type, label){
    var node_label = 'child node #' + (parent.childNodes.length+1)
    if (label) {
      node_label = label;
    }

    var node = new Ext.tree.AsyncTreeNode({
      text: node_label,
      iconCls: 'icon-node-' + ['default','host'][type]
    });
    parent.appendChild(node);

    var params = {
      label: node.text,
      type_id: type,
      position: parent.childNodes.indexOf(node)
    };
    if (parent.id != 'root-node') {
      params.parent_id = parent.id;
    }

    Ext.Ajax.request({
      url: 'nodes.json',
      method: 'post',
      params: {
        data: Ext.util.JSON.encode( params )
      },
      success: function(response, options) {
        dradisstatus.setStatus({text: 'Node created', clear: 5000 });
        node.setId(Ext.util.JSON.decode(response.responseText).id);
      },
      failure: function(response, options) {
        dradisstatus.setStatus({text: 'Ajax error', iconCls: 'error', clear: 5000 });
      }
    });
    node.getOwnerTree().editor.triggerEdit(node,false);

  },  
  updateNode: function(node, params){
    Ext.Ajax.request({
      url: 'nodes/' + node.id + '.json',
      method: 'put',
      params: {
        data: Ext.util.JSON.encode(params)
      },
      success: function(response, options) {
        dradisstatus.setStatus({text: 'Node updated', clear: 5000 });
      },
      failure: function(response, options) {
        dradisstatus.setStatus({text: 'Ajax error', iconCls: 'error', clear: 5000 });
        node.text = old_text;
      }
    });
  },
  changeNodeType: function(node, type) {
    node.setIconCls('icon-node-'+ ['default','host'][type]);
    this.updateNode(node, {type_id: type})
  },
  deleteNode: function(node){
    Ext.Ajax.request({
      url: 'nodes/' + node.id + '.json',
      method: 'delete',
      success: function() {
        dradisstatus.setStatus({text: 'Node removed from the server',clear: 5000});
        node.remove();
      },
      failure: function() {
        dradisstatus.setStatus({text: 'Ajax error', iconCls: 'error', clear: 5000});
      }
    });
  },

  // other methods/actions
  filterNodes: function(pattern){

    // un-hide the nodes that were filtered last time
    Ext.each(this.hiddenNodes, function(n){
      n.ui.show();
 		});

    if(!pattern){
      // no pattern -> nothing to be done
 			return;
 		}
    
    this.expandAll();
		
    var re = new RegExp('^.*' + Ext.escapeRe(pattern) + '.*', 'i');

    this.root.cascade( function(n){
      if (re.test(n.text)) {
        n.ui.show();
        n.bubble(function(){ this.ui.show(); });
      } else {
        n.ui.hide();
        this.hiddenNodes.push(n);
      }
    }, this);
  },

  refresh:function(){
    this.loader.load( this.getRootNode() );
  }

});


Ext.reg('nodestree', dradis.NodesTree);

