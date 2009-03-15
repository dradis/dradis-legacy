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

# The ImportContoller will be the centralised point from which all the 
# functionality exposed by plugins is made available to the user.
class ImportController < ApplicationController
  include Plugins::Import
  before_filter :login_required
  before_filter :validate_source, :only => [:filters, :query]
  before_filter :validate_filter, :only => :query

  private

  def validate_source()
    valid_sources = Plugins::Import::included_modules.collect do |m| m.name; end
    if (params.key?(:scope) && valid_sources.include?(params[:scope])) 
      @source = params[:scope].constantize
    else
      redirect_to '/'
    end
  end

  def validate_filter()
    if (params.key?(:filter) && @source::Filters::constants.include?(params[:filter]))
      @filter = "#{@source.name}::Filters::#{params[:filter]}".constantize
    else
      redirect_to '/'
    end
  end

  public

  def sources
    respond_to do |format|
      format.html{ redirect_to '/' }
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

  def filters
    respond_to do |format|
      format.html{ redirect_to '/' }
      format.json{
        list = [
          {
            :display => 'This source does not define any filter',
            :value => 'invalid'
          }
        ]
        if (@source.constants.include?('Filters'))
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

  def query
  end
end
