module Plugins
  # The Plugins::Export module will be filled in with functionality by the 
  # different export plugins installed in this dradis instance. The 
  # ExportController will expose this functionality through an standarised
  # interface.
  module Export
    # When this module is included in the ExportController, walk through all the
    # defined plugins to see if they define an Actions submodule. If they do
    # include the actions in the controller.
    def self.included(base)
      self.included_modules.each do |plugin|
        if (plugin.constants.include?('Actions'))
          base.class_eval %( include #{plugin.name}::Actions )
        end
      end
    end
  end
end

# The ExportController provides access to the different export plugins that 
# have been deployed in the dradis server.
#
# Each export plugin will include itself in the Plugins::Export module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# A convenience list method is provided that will return all the currently
# loaded plugins.
class ExportController < ApplicationController
  include Plugins::Export
  before_filter :login_required
  before_filter :prepare_params, :except => [:list]

  # This method provides a list of all the available export options. It 
  # assumes that each export plugin includes sub-modules in the  
  # Plugins::Export mixing.
  def list
    respond_to do |format|
      format.html{ redirect_to '/' }
      format.json{ 
        list = []
        Plugins::Export.included_modules.each do |plugin|
          list << { :name => plugin.name.underscore.humanize.gsub(/\//,' - '), :actions => [] }
          if (plugin.constants.include?('Actions'))
             list.last[:actions] = plugin::Actions.instance_methods.sort
          end
        end

        render :json => list
      }
    end
  end

  private
  def prepare_params
  end

  protected
    # In case something goes wrong with the export, fail graciously instead of
    # presenting the obscure Error 500 default page of Rails.
    # TODO: handle this error in the client side and present an ExtJS window 
    # similar to the one shown on upload errors
    def rescue_action(exception)
      flash[:error] = exception.message
      redirect_to root_path
    end
end
