module Dradis
  class NodesController < AuthenticatedController

    before_filter :find_or_initialize_node, :except => [ :index, :sort ]

    respond_to :html, :json

    # GET /nodes
    def index
      parent_id = params[:node] == 'root-node' ? nil : params[:node].to_i
      @nodes = Node.where(:parent_id => parent_id )
      respond_with(@nodes)
    end

    # GET /node/<id>/edit
    def edit
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
      @nodes = Node.all
      @categories = @node.notes.map(&:category).uniq
      respond_with(@node)
    end

    # POST /nodes/sort
    def sort
      params[:nodes].each_with_index do |id, index|
        Node.update_all({:position => index+1}, {:id => id})
      end
      render :nothing => true
    end

    # PUT /node/<id>
    def update
      if @node.update_attributes( params[:node] || ActiveSupport::JSON.decode(params[:data]) )
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
        if params[:id]
          unless @node = Node.find_by_id(params[:id])
            # FIXME this is no longer supported in Rails 3
            render_optional_error_file :not_found
          end
        else
          @node = Node.new(params[:node] || ActiveSupport::JSON.decode(params[:data]))
        end
        # TODO
        # @node.updated_by = current_user
      end
  end
end