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
