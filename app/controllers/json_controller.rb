class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    parent_id = params[:node] == 'root-node' ? nil : params[:node].to_i
    nodes = Node.find(:all, :conditions => {:parent_id => parent_id})
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


  def node_create
    Node.new({
      :label => params[:label],
      :parent_id => params[:parent_id]
    }).save
    render :text => 'noerror'
  end
  def node_update
    begin
      node = Node.find(params[:id].to_i)
    rescue
      render :text => 'node not found'
      return
    end
    node.update_attributes({
      :label => params[:label],
      :parent_id => params[:parent_id]
    })
    node.save
    render :text => 'noerror'
  end

  def node_delete
    begin
      node = Node.find(params[:id].to_i)
      node.destroy
      render :text => 'noerror'
    rescue
      render :text => 'node not found'
      return
    end
  end

end
