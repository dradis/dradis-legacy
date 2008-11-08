/*
 * nodestree.js
 * 4 / NOV / 2008
 *
 * This file contains the class definition of tthe dradis.NodesTree() object
 * used to represent the hierarchy of nodes stored in the database.
 */
Ext.ns('dradis');

// ----------------------------------------- tree

var tree = new Ext.tree.TreePanel({
    //width: 200,
    border: false,
    autoScroll: true,
    split: true,
    useArrows:true,
    autoScroll:true,
    animate:true,
    enableDD:true,
    loader: new Ext.tree.TreeLoader({
      url: 'json/nodes',
      requestMethod: 'GET'
    }),
    root: new Ext.tree.AsyncTreeNode({
      expanded: true,
    }),
    rootVisible: false,
    contextMenu: new Ext.menu.Menu({
      items: [
        { id: 'add-node', text: 'Add child', iconCls: 'add' },
        { id: 'delete-node', text: 'Delete Node', iconCls: 'del' }
      ],
      listeners: {
        itemclick: function(item) {
          switch (item.id) {
            case 'add-node':
              var root = item.parentMenu.contextNode;
              var node = root.appendChild(new Ext.tree.TreeNode({ text:'child node #' + (root.childNodes.length+1) }));
              //node.select();
              editor.triggerEdit(node,false);
              break;
            case 'delete-node':
              var n = item.parentMenu.contextNode;
              if (n.parentNode) {
                n.remove();
              }
              break;
          }
        }
      }
    }),  
    listeners: {
      click: function(n) {
        notesbrowser.updateNotes(n.attributes.id); 
        if (dradistabs.getActiveTab() == null) {
          dradistabs.setActiveTab(0);
        }
      },
      contextmenu: function(node, e) {
        //          Register the context node with the menu so that a Menu Item's handler function can access
        //           it via its parentMenu property.
        node.select();
        node.expand();
        var c = node.getOwnerTree().contextMenu;
        c.contextNode = node;
        c.showAt(e.getXY());
      }
    }

});

var editor = new Ext.tree.TreeEditor(tree, {}, {
  cancelOnEsc: true,
  completeOnEnter: true,
  ignoreNoChange: true,
  revertInvalid: true,
  selectOnFocus: true
});

dradis.NodesTree = function(config) {

  Ext.apply(this,{ 
    region: 'west',
    width: 300,
    tbar: [
      { 
        text: 'add branch',
        iconCls: 'add',
        handler: function() {
          var root = tree.getRootNode();
          var node = root.appendChild(new Ext.tree.TreeNode({ text:'branch #' + (root.childNodes.length +1) }));
          //node.select();
          editor.triggerEdit(node,false);
        }
      }
    ],
    items: [ tree ]
  });

  dradis.NodesTree.superclass.constructor.apply(this, arguments);
};

Ext.extend(dradis.NodesTree, Ext.Panel, {});


Ext.reg('nodestree', dradis.NodesTree);

