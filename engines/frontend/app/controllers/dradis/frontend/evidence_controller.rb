module Dradis
  module Frontend

    class EvidenceController < Dradis::Frontend::AuthenticatedController
      before_filter :find_node
      before_filter :find_or_initialize_evidence

      after_filter :update_revision_if_modified, except: [:show]

      def create
        @evidence.author = current_user unless @evidence.author
        @evidence.issue = initialize_issue if params[:evidence][:issue_id] == 'new'

        respond_to do |format|
          if @evidence.save
            @modified = true
          else
            # We need the @issues to re-display the form
            # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
            # @issues = Dradis::Core::Issue.find( Note.where(:node_id => Node.issue_library).pluck('`notes`.`id`') ).sort
            @issues = Dradis::Core::Issue.find( Dradis::Core::Node.issue_library.notes.pluck('`dradis_notes`.`id`') ).sort
          end
          format.js
        end
      end

      def update
        respond_to do |format|
          if @evidence.update_attributes(evidence_params)
            @modified = true
          else
            # We need the @issues to re-display the form
            # We need the @issues to re-display the form
            # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
            # @issues = Issue.find( Note.where(:node_id => Node.issue_library).pluck('`notes`.`id`') ).sort
            @issues = Dradis::Core::Issue.find( Dradis::Core::Node.issue_library.notes.pluck('`dradis_notes`.`id`') ).sort
          end
          format.js
        end
      end

      def destroy
        respond_to do |format|
          if @evidence.destroy
            format.html { redirect_to @node, notice: "Successfully deleted evidence for '#{@evidence.issue.title}.'" }
            format.js
          else
            format.html { redirect_to [@node,@evidence], notice: "Error while deleting evidence: #{@evidence.errors}" }
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
        redirect_to root_path, alert: 'Node not found' unless @node
      end

      # Look for the Evidence we are going to be working with based on the :id
      # passed by the user.
      def find_or_initialize_evidence
        if params[:id]
          @evidence = Dradis::Core::Evidence.find_by(id: params[:id].to_i)
        else
          @evidence = Dradis::Core::Evidence.new(evidence_params) do |e|
            e.node = @node
          end
        end
        @evidence.updated_by = current_user
      end

      def evidence_params
        params.require(:evidence).permit(:content, :issue_id)
      end


      # If the user selects "Add new issue" in the Evidence editor, we create an empty skeleton
      def initialize_issue
        Dradis::Core::Issue.create do |issue|
          issue.text = "#[Title]#\nNew issue auto-created for node [#{@node.label}]."
          issue.node = Dradis::Core::Node.issue_library
          issue.author = current_user
        end
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