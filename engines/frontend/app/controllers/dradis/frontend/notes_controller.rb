module Dradis
  module Frontend
    class NotesController < Dradis::Frontend::AuthenticatedController
      before_filter :find_node
      before_filter :find_or_initialize_note

      after_filter :update_revision_if_modified, except: [:show]

      # Create a new Note for the associated Node.
      def create
        @note.author = current_user unless @note.author

        respond_to do |format|
          if @note.save
            @modified = true
            format.html { redirect_to @node, notice: "Note [#{@note.title}] added." }
            format.js
          else
            format.html { redirect_to @node, alert: "Note couldn't be added." }
            format.js
          end
        end
      end

      # Update the attributes of a Note
      def update
        respond_to do |format|
          if @note.update_attributes(note_params)
            @modified = true
          end

          format.html{ redirect_to @node, notice: "Note [#{@note.title}] updated." }
          format.js
          format.json
        end
      end

      # Remove a Note from the back-end database.
      # Formats supported: XML
      def destroy
        respond_to do |format|
          format.html { head :method_not_allowed }

          if @note.destroy
            @modified = true
            format.xml { head :ok }
            format.json{ render :json => {:success => true} }
          else
            format.xml { render :xml => @note.errors.to_xml, :status => :unprocessable_entity }
            format.json{ render :json => { :success => false, :errors => @note.errors } }
          end
        end
      end

      def destroy
        respond_to do |format|
          if @note.destroy
            format.html { redirect_to @node, notice: "Node [#{@note.title}] deleted." }
            format.js
          else
            format.html { redirect_to @node, notice: "Error while deleting note: #{@note.errors}" }
            format.js
          end
        end
      end

      private
      # For most of the operations of this controller we need to identify the Node
      # we are working with. This filter sets the @node instance variable if the
      # give :node_id is valid.
      def find_node
        @node = Dradis::Core::Node.find_by(id: params[:node_id].to_i)
        redirect_to root_path unless @node
      end

      # Once a valid @node is set by the previous filter we look for the Note we
      # are going to be working with based on the :id passed by the user.
      def find_or_initialize_note
        if params[:id]
          @note = @node.notes.find_by(id: params[:id].to_i)
        else
          @note = Dradis::Core::Note.new(note_params) do |i|
            i.node = @node
          end
        end
        @note.updated_by = current_user
      end

      def note_params
        params.require(:note).permit(:category_id, :text)
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