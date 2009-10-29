class HomeController < ApplicationController
  layout 'postauth'
  before_filter :login_required
  
  def index
  end

  def rss
    observed_models = [:node, :note, :category]
    # this contains the list of items to be displayed in rss 
    @items = []
    observed_models.each do |model|
      elements = model.to_s.classify.constantize.find(:all, :order => "updated_at DESC", :limit => 10)
      elements.each do |element|
        title = element.updated_at == element.created_at ? "Created #{model.to_s}" : "Update #{model.to_s}"
        title << " on #{element.updated_at}"
        @items << {:date => element.updated_at,
          :title => title
        }
      end
    end
    @items.sort {|a,b| a[:date] <=> b[:date]}
    @items = @items[0..9]

    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'rss', :layout => false
  end
end
