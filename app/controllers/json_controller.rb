# This soon-to-be-depreacted controller exposes a series of functions to
# operate with different models using JSON.
#
# It was created before proper REST controllers were implemented for the
# majority of the models and as such it duplicates funcionality that should
# be implemented in them.
#
# This controller will be removed in Dradis 3.0
class JsonController < ApplicationController
  before_filter :login_required

  # Create a new Node from its :label and :parent_id
  def node_create
    node = Node.new({
      :label => params[:label],
      :parent_id => params[:parent_id]
    })
    node.save
    render :text => node.id
  end

  # Update the attributes of a Node from the values submitted in a non-standard
  # POST request
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
    render :text => 'noerror'
  end

  # Delete a Node given its :id
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
