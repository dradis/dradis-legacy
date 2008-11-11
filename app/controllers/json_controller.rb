class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    nodes = Node.find(:all, :conditions => {:parent_id => nil})
    render :text => nodes.to_json
  end

  def note_create  
    # TODO: validation!!
    Note.new( 
      :text => params[:text],
      :author => params[:author],
      :node_id => params[:node],
      :category_id => params[:category] 
    ).save
    render :text => 'noerror'
  end

  def note_update
    begin
      note = Note.find(params[:id].to_i)
   rescue
      render :text => 'note not found' 
      return
    end

    note.update_attributes({
      :text => params[:text],
      :author => params[:author],
      :node_id => params[:node],
      :category_id => params[:category] 
    })
    note.save
    render :text => 'noerror'
  end

end
