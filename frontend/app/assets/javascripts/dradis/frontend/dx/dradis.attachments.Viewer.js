// From: http://extjs.com/learn/Tutorial:Extending_Ext2_Class

Ext.ns('dradis.attachments');

dradis.attachments.Viewer = Ext.extend(Ext.Panel, {
  //props (overridable by caller)
  autoScroll: true,
  border: true,

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      contentEl: 'jquery-upload'
    }
    
    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);
    // Before parent code

    // Call parent (required)
    dradis.attachments.Viewer.superclass.initComponent.apply(this, arguments);
     
    // After parent code
    // e.g. install event handlers on rendered component
    // this.addEvents('refresh');
    // 
    // this.store.on('datachanged', this.onDataChanged, this);
    // this.store.on('add', this.added, this)
  },

  // other methods/actions
  load: function(node_id){ 
    $('#fileupload').attr('action', 'nodes/' + node_id + '/attachments.json');
    $('#fileupload .files').empty();

    var files = [];
    var file;
    attachments.dataStore.each(function(record){
      file = { 
        'name': record.get('filename'),
        'size': record.get('size'),
        'url': 'nodes/' + node_id + '/attachments/' + record.get('filename'),
        'delete_url': 'nodes/' + node_id + '/attachments/' + record.get('filename'),
        'delete_type': 'DELETE'
      };
      if (/\.(gif|png|jpg|jpeg)$/.test(file.name)) {
        file.thumbnail_url = 'nodes/' + node_id + '/attachments/' + record.get('filename');
      }
      files.push(file);
    });
    
    var fu = $('#fileupload').data('fileupload'), template;
    fu._adjustMaxNumberOfFiles(-attachments.dataStore.getCount());
    template = fu._renderDownload(files)
      .appendTo($('#fileupload .files'));
    // Force reflow:
    fu._reflow = fu._transition && template.length &&
      template[0].offsetWidth;
    template.addClass('in');    
  }

});