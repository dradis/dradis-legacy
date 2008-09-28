class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    nodes = Node.find(:all, :conditions => {:parent_id => nil})
    puts nodes.to_json; 
    render :text => nodes.to_json
  end
end
