module Dradis
  module Frontend

    class ExportController < Dradis::Frontend::AuthenticatedController
      before_filter :find_nodes
      before_filter :find_plugins
      # before_filter :find_uploads_node, only: [:create, :parse]
      before_filter :validate_exporter, only: [:create]
      before_filter :validate_template, only: [:create]

      layout 'dradis/themes/snowcrash'

      def index
        @plugin_info = @plugins.map do |plugin|
          {
                 engine: plugin::Engine,
            description: plugin::Engine::plugin_description,
                   name: plugin::Engine.plugin_name,
                 routes: plugin::Engine.routes.named_routes,
              templates: templates_for(plugin: plugin).collect{|file| File.basename(file)},
          templates_dir: templates_dir_for(plugin: plugin)[Rails.root.to_s.length..-1]
          }
        end
      end

      def create
        # We need to pass some params to the plugin's controller. But we're
        # redirecting, so we'll put them in the session.
        # *Warning* can't store too much data here.
        session[:export_manager] = {template: @template_file}

        # FIXME: check the Routing guide to find a better way.
        action_path = "#{params[:route]}_path"
        redirect_to eval(@exporter::Engine::engine_name).send(action_path)
      end

      private

      # There should be a better way of handling this.
      def find_nodes
        @nodes = Dradis::Core::Node.includes(:children).all
        @new_node = Dradis::Core::Node.new
      end

      # The list of available Export plugins. See the dradis_plugins gem.
      def find_plugins
        @plugins = Dradis::Plugins::with_feature(:export).collect do |plugin|
          path = plugin.to_s
          path[0..path.rindex('::')-1].constantize
        end.sort{|a,b| a.name <=> b.name }
      end

      # In case something goes wrong with the export, fail graciously instead of
      # presenting the obscure Error 500 default page of Rails.
      def rescue_action(exception)
        flash[:error] = exception.message
        redirect_to upload_manager_path()
      end

      def templates_dir_for(args={})
        plugin = args[:plugin]
        File.join(Dradis::Core::Configuration::paths_templates_reports, plugin::Engine.plugin_name.to_s)
      end

      def templates_for(args={})
        Dir["%s/*" % templates_dir_for(args)]
      end

      # Ensure that the requested :uploader is valid
      def validate_exporter()
        valid_exporters = {}
        @plugins.each do |plugin|
          valid_exporters[plugin::Engine::plugin_name] = plugin
        end

        if (params.key?(:plugin) && valid_exporters.keys.include?(params[:plugin].to_sym))
          @exporter = valid_exporters[params[:plugin].to_sym]
        else
          redirect_to export_manager_path, alert: 'Something fishy is going on...'
        end
      end

      def validate_template
        if params.key?(:template)
          template_name = params[:template]
          templates_dir = templates_dir_for(plugin: @exporter)
          @template_file = File.expand_path(File.join(templates_dir, template_name))
          @template_file.starts_with?(templates_dir) && File.exists?(@template_file)
        end
      end
    end

  end
end