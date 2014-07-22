module Dradis
  module Frontend
    class HomeController < Dradis::Frontend::AuthenticatedController
      def index
        # We need to extract all the users that have participated in the project so far.
        @authors = [current_user]

        # FIXME: this hard-coding of the table name is problematic, it would be better to use Note.table_name
        # @issues = Issue.find( Node.issue_library.notes.pluck('`notes`.`id`'), include: :tags ).sort
        @issues = Dradis::Core::Issue.find( Dradis::Core::Node.issue_library.notes.pluck('`dradis_notes`.`id`') ).sort

        @nodes = Dradis::Core::Node.includes(:children).all

        # This is required for the forms in the view, to avoid hard-coding the name of the classes
        @categories   = Dradis::Core::Category.all

        @new_evidence = Dradis::Core::Evidence.new
        @new_child    = Dradis::Core::Node.new(parent_id: @node.id)
        @new_node     = Dradis::Core::Node.new
        @new_note     = Dradis::Core::Note.new

        # FIXME: HARD-CODING WARNING #2
        # A little bit of hard-coding the theme never hurts!
        # This layout is provided by dradis-theme_snowcrash
        render layout: 'dradis/themes/snowcrash'
      end

      def info
        # @last_audit = 0
        # if Log.where(:uid=>0).count > 0
        #   @last_audit = Log.where(:uid => 0).order('created_at desc').limit(1)[0].id
        # end
        @plugins = {
          addon: [],
          export: [],
          import: [],
          upload: [],
          theme: []
        }
        Dradis::Plugins.list.each do |plugin|
          @plugins.keys.each do |feature|
            @plugins[feature] << plugin if plugin.provides?(feature)
          end
        end
      end

      # Returns the markup cheatsheet that is used by the jQuery.Textile plugin Help
      # button.
      def markup
        render layout: false
      end

      # Returns the Textile version of a text passed as parameter
      def textilize
        respond_to do |format|
          format.html { head :method_not_allowed }
          format.json {
            # gracefully handle RedCloth absence
            output = ''
            begin
              output = params[:text]
              Hash[ *params[:text].scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect{ |str| str.strip } ].keys.each do |field|
                output.gsub!(/#\[#{Regexp.escape(field)}\]#[\r|\n]/, "h1. #{field}\n\n")
              end

              output = RedCloth.new(output, [:filter_html]).to_html
            rescue Exception
              output = "<pre style=\"background-color: #fff;\">#{ CGI::escapeHTML(params[:text]) }</pre>"
            end

            render json: { html: output }
          }
        end
      end
    end
  end
end