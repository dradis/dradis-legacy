# This controller exposes the REST operations required to manage the Node
# resource.
#

module Dradis
  module Frontend
    class NodesController < Dradis::Frontend::AuthenticatedController
      before_filter :find_or_initialize_node, :except => [ :index, :sort ]

      respond_to :html, :json

      # POST /nodes
      def create
        if @node.save
          flash[:notice] = "Node [#{@node.label}] created"
        end
        respond_with(@node)
      end

      # GET /nodes/<id>
      def show
        @issues = Dradis::Core::Issue.find(
        # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
          Dradis::Core::Note.where(node_id: Dradis::Core::Node.issue_library).pluck(`dradis_notes`.`id`)
        )

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
        else
          flash[:alert] = @node.errors.full_messages.join(';')
        end
        respond_with(@node)
      end

      # DELETE /nodes/<id>
      def destroy
        @node.destroy
        if @node.parent
          respond_with(@node.parent)
        else
          redirect_to root_path
        end
      end

      protected
        def find_or_initialize_node
          if params[:id]
            unless @node = Node.find_by_id(params[:id])
              render_optional_error_file :not_found
            end
          else
            @node = Node.new(params[:node] || ActiveSupport::JSON.decode(params[:data]))
          end
          @node.updated_by = current_user
        end
    end
  end
end