# This controller exposes the REST operations required to manage the Node 
# resource.
class NodesController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize_node, :except => [ :index ]

  respond_to :json

  # GET /nodes
  def index
    parent_id = params[:node] == 'root-node' ? nil : params[:node].to_i
    @nodes = Node.where(:parent_id => parent_id )
    respond_with(@nodes)
  end        

  # POST /nodes
  def create
    if @node.save
      flash[:notice] = 'Successfully created node.'
    end
    respond_with(@node)
  end

  # GET /nodes/<id>
  def show
    respond_with(@node)
  end

  # PUT /node/<id>
  def update
    if @node.update_attributes( params[:node] )
      flash[:notice] = 'Successfully updated node.' 
    end
    respond_with(@node)
  end

  # DELETE /nodes/<id>
  def destroy
    @node.destroy
    respond_with(@node)
  end

  protected
    def find_or_initialize_node
      if params[:node_id]
        unless @node = Node.find_by_id(params[:node_id])
          render_optional_error_file :not_found
        end
      else
        @node = Node.new(params[:node])
      end
    end        

end
