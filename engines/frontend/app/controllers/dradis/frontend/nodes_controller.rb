# This controller exposes the REST operations required to manage the Node
# resource.
#

module Dradis
  module Frontend
    class NodesController < Dradis::Frontend::AuthenticatedController
      # before_filter :find_or_initialize_node, :except => [ :index, :sort ]

      layout 'dradis/themes/snowcrash'
      respond_to :html, :json

      # POST /nodes
      def create
        @node = Dradis::Core::Node.new(node_params)
        respond_to do |format|
          if @node.save
            format.html { redirect_to @node, notice: "Node [#{@node.label}] created." }
            # format.json { render json: @dessert, status: :created, location: @dessert }
          else
            format.html { render action: 'new' }
            # format.json { render json: @dessert.errors, status: :unprocessable_entity }
          end
        end
      end

      # GET /nodes/<id>
      def show
        @node = Dradis::Core::Node.find_by_id(params[:id].to_i)

        # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
        # @issues = Issue.find( Node.issue_library.notes.pluck('`notes`.`id`'), include: :tags ).sort
        @issues = Dradis::Core::Issue.find( Dradis::Core::Node.issue_library.notes.pluck('`dradis_notes`.`id`') ).sort
        @nodes = Dradis::Core::Node.includes(:children).all

        @sorted_notes = @node.notes.sort
        @sorted_evidence = @node.evidence.sort

        # This is required for the forms in the view, to avoid hard-coding the name of the classes
        @categories   = Dradis::Core::Category.all

        @new_evidence = Dradis::Core::Evidence.new
        @new_child    = Dradis::Core::Node.new(parent_id: @node.id)
        @new_node     = Dradis::Core::Node.new
        @new_note     = Dradis::Core::Note.new

        respond_with(@node)
      end

      # POST /nodes/sort
      # def sort
      #   params[:nodes].each_with_index do |id, index|
      #     Node.update_all({:position => index+1}, {:id => id})
      #   end
      #   render :nothing => true
      # end

      # PUT /node/<id>
      # def update
      #   if @node.update_attributes( params[:node] || ActiveSupport::JSON.decode(params[:data]) )
      #     flash[:notice] = 'Successfully updated node.'
      #   else
      #     flash[:alert] = @node.errors.full_messages.join(';')
      #   end
      #   respond_with(@node)
      # end

      # DELETE /nodes/<id>
      # def destroy
      #   @node.destroy
      #   if @node.parent
      #     respond_with(@node.parent)
      #   else
      #     redirect_to root_path
      #   end
      # end

      protected
      # def find_or_initialize_node
      #   if params[:id]
      #     unless @node = Node.find_by_id(params[:id])
      #       render_optional_error_file :not_found
      #     end
      #   else
      #     @node = Dradis::Core::Node.new(node_params)
      #   end
      #   @node.updated_by = current_user
      # end

      def node_params
        params.require(:node).permit(:label, :parent_id, :position, :type_id)
      end
    end
  end
end
