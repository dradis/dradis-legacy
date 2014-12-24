module Dradis
  module Frontend
    class IssuesController < Dradis::Frontend::AuthenticatedController
      before_filter :find_issuelib
      before_filter :find_issues

      before_filter :find_or_initialize_issue, except: [:index, :new]

      after_filter :update_revision_if_modified, except: [:index ,:show]

      layout 'dradis/themes/snowcrash'

      def index
      end

      def show
      end

      def new
        @issue = Dradis::Core::Issue.new
      end

      def create
        @issue.author = current_user unless @issue.author

        respond_to do |format|
          if @issue.save
            @modified = true
            format.html { redirect_to @issue, notice: 'Issue added.' }
            format.js
          else
            format.html { render 'new', alert: "Issue couldn't be added." }
            format.js
          end
        end
      end

      def edit
      end

      def update
        respond_to do |format|
          if @issue.update_attributes(issue_params)
            @modified = true
          end

          format.html{ redirect_to @issue, notice: 'Issue updated.' }
          format.js
          format.json
        end
      end

      def destroy
        respond_to do |format|
          if @issue.destroy
            format.html { redirect_to issues_url, notice: "Issue [#{@issue.title}] deleted." }
            format.js

            # Issue table in Issues#index
            format.json
          else
            format.html { redirect_to issues_url, notice: "Error while deleting issue: #{@issue.errors}" }
            format.js

            # Issue table in Issues#index
            format.json
          end
        end
      end


      # def import
      #   importer = IssueImporter.new(params)
      #   @results = importer.query()
      #   @plugin = params[:scope]
      #   @filter = params[:filter]
      #   @query = params[:query]
      # end

      private
      def find_issues
        # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
        # We need a transaction because multiple DELETE calls can be issued from
        # index and a TOCTOR can appear between the Note read and the Issue.find
        Note.transaction do
          @issues = Dradis::Core::Issue.find( Dradis::Core::Node.issue_library.notes.pluck('`dradis_notes`.`id`') ).sort
        end

        @nodes = Dradis::Core::Node.in_tree

        @new_node = Dradis::Core::Node.new
      end

      def find_issuelib
        @issuelib = Dradis::Core::Node.issue_library
      end

      # Once a valid @issuelib is set by the previous filter we look for the Issue we
      # are going to be working with based on the :id passed by the user.
      def find_or_initialize_issue
        if params[:id]
          @issue = Dradis::Core::Issue.find_by(id: params[:id].to_i)
        else
          @issue = Dradis::Core::Issue.new(issue_params) do |i|
            i.node = @issuelib
            i.category = Dradis::Core::Category.issue
          end
        end
        @issue.updated_by = current_user
      end

      def issue_params
        params.require(:issue).permit(:text)
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