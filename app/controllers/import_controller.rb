module Plugins
  # The Plugins::Import module will be filled in with functionality by the 
  # different import plugins installed in this dradis instance. The 
  # ImportController will expose this functionality through an standarised
  # interface.
  module Import
    module Filters
    end
  end
end

# The ImportController provides access to the different import plugins that 
# have been deployed in the dradis server.
#
# Each import plugin will include itself in the Plugins::Import module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# For more information on import plugins see:
# http://dradisframework.org/import_plugins.html
class ImportController < Dradis::Frontend::ApplicationController
  include Plugins::Import
  before_filter :login_required
  before_filter :validate_source, :only => [:filters, :query]
  before_filter :validate_filter, :only => :query

  private
  # Ensure that the data source requested is valid.
  def validate_source()
    valid_sources = Plugins::Import::included_modules.collect(&:name)
    if (params.key?(:scope) && valid_sources.include?(params[:scope])) 
      @source = params[:scope].constantize
    else
      redirect_to root_path
    end
  end

  # If the source is valid, ensure that it defines the requested filter.
  def validate_filter()
    filter_module = (RUBY_VERSION < '1.9') ? params[:filter] : params[:filter].to_sym
    if (params.key?(:filter) && @source::Filters::constants.include?(filter_module))
      @filter = "#{@source.name}::Filters::#{params[:filter]}".constantize
    else
      redirect_to root_path
    end
  end

  public
  # Provide a list of the available remote data sources as configured by the
  # different import plugins. Only supports JSON format.
  def sources
    respond_to do |format|
      format.html{ redirect_to root_path }
      format.json{
        list = []
        Plugins::Import.included_modules.each do |plugin|
          list << { 
                    :display => "#{plugin::Meta::NAME} (#{plugin.name} #{plugin::Meta::VERSION::STRING})",
                    :value => plugin.name
                  }
        end
        render :json => list
      }
    end
  end

  # For a given data source, list all the Filters exposed by the corresponding
  # import plugin.
  # Only supports JSON format.
  def filters
    respond_to do |format|
      format.html{ redirect_to root_path }
      format.json{
        list = [
          {
            :display => 'This source does not define any filter',
            :value => 'invalid'
          }
        ]
        filters_module = (RUBY_VERSION < '1.9') ? 'Filters' : :Filters
        if (@source.constants.include?(filters_module))
          list.clear
          @source::Filters.constants.each do |filter_name|
            filter = "#{@source.name}::Filters::#{filter_name}".constantize 
            list << { 
              :display => "#{filter_name}: #{filter::NAME}", 
              :value => filter_name 
            }
          end
        end
        
        render :json => list
      }
    end
  end

  # Run a query against the remote data source using a given filter.
  # Only supports JSON format.
  def query
    respond_to do |format|
      format.html{ redirect_to root_path }
      format.json{
        render :json => @filter.run(params)
      }
    end
  end
end
