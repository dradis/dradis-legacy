class FeedsController < ApplicationController
  before_filter :login_required

  def index
    @feeds = Feed.find(:all, :limit => 20)

    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'index', :layout => false
  end

end
