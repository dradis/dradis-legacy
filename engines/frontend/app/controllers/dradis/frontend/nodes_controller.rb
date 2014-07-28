# This controller exposes the REST operations required to manage the Node
# resource.
#

module Dradis
  module Frontend
    class NodesController < Dradis::Frontend::AuthenticatedController
      before_filter :find_or_initialize_node, except: [:index, :sort]

      after_filter :update_revision_if_modified, except: [:index , :show]

      layout 'dradis/themes/snowcrash'
      respond_to :html, :json

      # POST /nodes
      def create

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
        # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
        # @issues = Issue.find( Node.issue_library.notes.pluck('`notes`.`id`') ).sort
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
      def update
        respond_to do |format|
          if @node.update_attributes(node_params)
            format.html { redirect_to @node, notice: "Node [#{@node.label}] updated." }
          else
            format.html { render action: 'new' }
          end
        end
      end

      # DELETE /nodes/<id>
      def destroy
        @node.destroy
        if @node.parent
          redirect_to @node.parent, notice: "Child node [#{@node.label}] deleted."
        else
          redirect_to root_path, notice: "Top-level node [#{@node.label}] deleted."
        end
      end

      protected
      def find_or_initialize_node
        if params[:id]
          unless @node = Dradis::Core::Node.find_by_id(params[:id].to_i)
            render_optional_error_file :not_found
          end
        else
          @node = Dradis::Core::Node.new(node_params)
        end
        @node.updated_by = current_user
      end

      def node_params
        params.require(:node).permit(:label, :parent_id, :position, :type_id)
      end

      # This is an after_filter that increments the current revision if a note was
      # modified as a result of any of the operations exposed by this controller.
      def update_revision_if_modified
        return unless @modified
        ::Dradis::Core::Configuration.increment_revision
      end
    end
  end
end
