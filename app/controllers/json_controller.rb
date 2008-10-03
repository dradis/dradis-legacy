class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    nodes = Node.find(:all, :conditions => {:parent_id => nil})
    render :text => nodes.to_json
  end
end
