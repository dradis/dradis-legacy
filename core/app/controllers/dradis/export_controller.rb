module Dradis
  class ExportController < AuthenticatedController
    def list
      plugin_list = Dradis::Core::Plugins::with_feature(:export)
      export_menu = []
      plugin_list.each do |plugin|
        export_menu << {
          name: plugin.plugin_name,
          actions: [ plugin.name.split('::')[1].underscore.humanize.split(' ')[0].downcase ]
        }
      end

      # maybe we could improve this by only doing the processing in :json format
      # however, it's not a lot of processing and hopefully in the future we'll
      # also support :html format
      respond_to do |format|
        format.html{ redirect_to root_path }
        format.json { render json: export_menu }
      end
    end

    # TODO
    # protected
    # # In case something goes wrong with the export, fail graciously instead of
    # # presenting the obscure Error 500 default page of Rails.
    # # TODO: handle this error in the client side and present an ExtJS window
    # # similar to the one shown on upload errors
    # def rescue_action(exception)
    #   flash[:error] = exception.message
    #   redirect_to root_path
    # end
  end
end