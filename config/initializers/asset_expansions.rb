
# JavaScript assets
{

  :extjs_base => [
    'adapter/ext/ext-base', 
    'ext-all'
  ],
  :extjs_3rdparty => [
    'ux/Ext.ux.StatusBar', 
    'ux/Ext.ux.grid.RowExpander', 
    'data-view-plugins', 
    'ux/Ext.ux.form.BrowseButton',
    'ux/Ext.ux.form.FileUploadField',
    'ux/Ext.ux.FileUploader',
    'ux/Ext.ux.UploadPanel'
  ],
  :extjs_dradis => [
    'dx/dradis.plugins.PluginManager', 
    'dx/dradis.plugins.UploadFormPanel', 
    'dx/dradis.notes.NotePreviewPanel', 
    'dx/dradis.notes.NoteEditorWindow', 
    'dx/dradis.notes.NotesBrowserPanel',
    'dx/dradis.feeds.FeedsWindow'
  ],
  :legacy => [
    'thebrain', 
    'nodestree', 
    'importer', 
    'attachmentsviewer', 
    'interface'
  ]

}.each do |name, list|
  ActionView::Helpers::AssetTagHelper.register_javascript_expansion name => list
end

# CSS assets
{

  :extjs => ['ext-all', 'xtheme-blue', 'attachments', 'icons', 'filetype', 'file-upload'],
  :base => ['dradis', 'textile']

}.each do |name, list|
  ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion name => list
end
