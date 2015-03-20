module Dradis
  module Frontend
    # Internal application Configuration settings are handled through this
    # REST-enabled controller.
    class ConfigurationsController < Dradis::Frontend::AuthenticatedController
      before_filter :find_plugin, except: [ :index ]

      layout 'dradis/themes/snowcrash'

      # Get all the Configuration objects.
      def index
        @configs = all_configurations
        respond_to do |format|
          format.html # index.html.erb
        end
        if params[:mint_creek]
          render 'mc_index', layout: 'styles'
        end
      end

      # Update the value of a Configuration object or gemified plugin setting.
      def update
        respond_to do |format|
          format.html { head :method_not_allowed }
          if @plugin
            @plugin.settings.update_settings(params[:setting])
            @is_default = @plugin.settings.is_default?(params[:setting].keys.first, params[:setting].values.first)
            format.js { render json: { setting_is_default: @is_default }.to_json }
          else
            format.js { render json: @config.errors.to_json, status: :unprocessable_entity }
          end
        end
      end

      private
      def all_configurations
        configurations = Dradis::Plugins.list.map do |plugin|
          {
            klass:    plugin.name.to_s,
            name:     plugin.name.gsub(/^Dradis::Plugins::/, '').gsub(/::Engine$/, ''),
            type:     'gemified',
            settings: plugin.settings.all
          }
        end.reject{ |c| c[:settings].blank? }.sort_by{ |c| c[:name] }
      end

      # This filter locates the Dradis::Plugins subclass
      # for which we're updating the settings using the :id param.
      # If no plugin is found, an error page is rendered.
      def find_plugin
        if params[:id]
          class_name = "Dradis::Plugins::#{ params[:id].camelcase }::Engine"
          @plugin = class_name.constantize if all_configurations.map{ |c| c[:klass] }.include?(class_name)
        end
        if @plugin.nil?
          render_optional_error_file :not_found
        else
          return true
        end
      end

    end
  end
end
