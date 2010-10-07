/*
 * dradis.nodes.NodesTreePanel.js
 * 7 / OCT / 2010
 *
 * This file contains the class definition of tthe dradis.nodes.NodesTreePanel()
 * widget which is used to represent the hierarchy of nodes stored in the 
 * database. It communicates with the server's NodesController using Ajax and JSON.
 */

// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.nodes');

dradis.nodes.NodesTreePanel=Ext.extend(Ext.tree.TreePanel, {
  //props (overridable by caller)
  region: 'west',
  width: 200,
  autoScroll: true,
  split: true,
  useArrows:true,
  animate:true,


  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      root: new Ext.tree.TreeNode({text: 'root-node'})
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.nodes.NodesTreePanel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
  }

  // other methods/actions
});

Ext.reg('nodestreex', dradis.nodes.NodesTreePanel); 
