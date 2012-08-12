module Dradis
  class NotesController < AuthenticatedController
    before_filter :find_or_initialize_node
    before_filter :find_or_initialize_note, :except => [ :index ]
    private

    # TODO - implement CRUD actions

    # For most of the operations of this controller we need to identify the Node
    # we are working with. This filter sets the @node instance variable if the 
    # give :node_id is valid.
    def find_or_initialize_node
      begin 
        @node = Node.find(params[:node_id])
      rescue
        flash[:error] = 'Node not found'
        redirect_to root_path
      end
    end

    # Once a valid @node is set by the previous filter we look for the Note we
    # are going to be working with based on the :id passed by the user.
    def find_or_initialize_note
      if params[:id]
        unless @note = Note.find(params[:id])
          render_optional_error_file :not_found
        end
      else
        @note = Note.new(params[:note] || ActiveSupport::JSON.decode(params[:data]))
        @note.node = @node
      end
      @note.updated_by = current_user
    end    
  end
end