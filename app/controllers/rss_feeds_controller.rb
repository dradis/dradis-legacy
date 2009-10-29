class RssFeedsController < ApplicationController

  def index
    @rss_feeds = RssFeed.find(:all, :limit => 20)

    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'index', :layout => false
  end

end
