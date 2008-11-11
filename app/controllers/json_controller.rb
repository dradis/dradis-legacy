class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    nodes = Node.find(:all, :conditions => {:parent_id => nil})
    render :text => nodes.to_json
  end

  def note  
    # TODO: validation!!
    Note.new( 
      :text => params[:text],
      :author => params[:author],
      :node_id => params[:node],
      :category_id => params[:category] 
    ).save
    render :text => 'noerror'
  end

end
