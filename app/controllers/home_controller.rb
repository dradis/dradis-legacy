class HomeController < ApplicationController
  layout 'postauth'
  before_filter :login_required
  
  def index
  end

  def rss
    # this contains the list of items to be displayed in rss
    # TODO: where do we get this from, yes the revision 
    @items = []
    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'rss', :layout => false
  end
end
