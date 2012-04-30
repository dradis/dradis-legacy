// require adapter/ext/ext-base
//= require jquery
//= require jquery-fileupload/index

//= require adapter/jquery/ext-jquery-adapter
//= require ext-all

//= require ux/Ext.ux.StatusBar
//= require ux/Ext.ux.grid.RowExpander
//= require data-view-plugins
//= require ux/Ext.ux.form.BrowseButton
//= require ux/Ext.ux.form.FileUploadField
//= require ux/Ext.ux.FileUploader
//= require ux/Ext.ux.UploadPanel

//= require dx/dradis.attachments.Viewer
//= require dx/dradis.plugins.PluginManager
//= require dx/dradis.plugins.UploadFormPanel
//= require dx/dradis.notes.NotePreviewPanel
//= require dx/dradis.notes.NoteEditorWindow
//= require dx/dradis.notes.NotesBrowserPanel
//= require dx/dradis.feeds.FeedsWindow

//= require thebrain
//= require nodestree
//= require importer
//= require attachmentsviewer
//= require interface

//= require_self


// require jquery
// require jquery_ujs
// require_tree .

/* 
 * from the meta-server project browser: 
 * https://dradis.svn.sourceforge.net/svnroot/dradis/meta-server/trunk/public/javascripts/application.js
 */
function collapseProject(id) {
  var els = document.getElementsByClassName(id, 'browser');
  for (var i = 0; i < els.length; i++) {
    Element.hide(els[i]);
  }
  $(id).removeClassName('open');
}

function expandProject(id) {
  var els = document.getElementsByClassName(id, 'browser');
  for (var i = 0; i < els.length; i++) {
    Element.show(els[i]);
  }
  $(id).addClassName('open');
}

function projectClick(id) {
    var el = $(id);
    if (el.hasClassName('open')) {
        collapseProject(id);
        el.addClassName('collapsed');
        return false;
    //} else if (el.hasClassName('loaded')) {
    } else if (el.hasClassName('collapsed')) {
        expandProject(id);
        el.removeClassName('collapsed');
        return false;
    }
    /* no Ajax yet
    if (el.hasClassName('loading')) {
        return false;
    }
    el.addClassName('loading');
    return true;
    */
}

function revisionClick(id){
  var rev = $('revision');
  rev.value = id;
}
