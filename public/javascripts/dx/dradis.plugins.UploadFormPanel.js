Ext.ns('dradis');
Ext.ns('dradis.plugins');

dradis.plugins.UploadFormPanel=Ext.extend(Ext.FormPanel, {
  //props (overridable by caller)
  frame: true,
  labelWidth: 75,

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      width: 250,
      height: 185,

      //bodyStyle: 'padding:0 10px 0;',
      items:[ 
        {
          xtype: 'fieldset',
          title: 'Available formats',
          height: 100,
          autoWidth: true,
          //autoHeight: true,
          items: {
            xtype: 'radiogroup',
            hideLabel: true,
            columns: 3,
            vertical: true,
            items: [
              {boxLabel: 'Item 1', name: 'cb-format'},
              {boxLabel: 'Item 2', name: 'cb-format', checked: true},
              {boxLabel: 'Item 3', name: 'cb-format'},
              {boxLabel: 'Item 4', name: 'cb-format'},
              {boxLabel: 'Item 5', name: 'cb-format'}
            ]
          }
        },
        {
          fieldLabel: 'Select a file',
          xtype: 'textfield',
          anchor: '100%'
        }
      ],
      buttons:[
        {text:'Upload'},
        {text:'Cancel'}
      ]
    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config); 
        
    // Before parent code
 
    // Call parent (required)
    dradis.plugins.UploadFormPanel.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
  }

  // other methods/actions
});
