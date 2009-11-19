# This controller provides the different RSS feeds that the framework makes
# available to the users.
class FeedsController < ApplicationController
  before_filter :login_required

  # The general feed contains items for every object that has been created,
  # updated or destroyed.
  def index
    @feeds = Feed.find(:all, :limit => 20, :order => "updated_at DESC")
    
    respond_to do |format|
      format.html {
        response.headers['Content-Type'] = 'application/rss+xml'
        render :action => 'index', :layout => false
      }
      format.xml { render :xml => @feeds.to_xml }
      format.json { render :json => @feeds.to_json(:methods => [:title, :stamp]) }
    end
    
  end

end
