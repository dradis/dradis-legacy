# Internal application Configuration settings are handled through this 
# REST-enabled controller.
class ConfigurationsController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize_config, :except => [ :index ]

  # Get all the Configuration objects. It only supports XML format. Sample 
  # request:
  # https://localhost:3004/configurations.xml
  def index
    @configs = Configuration.find(:all)
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      format.xml { render :xml => @configs.to_xml}
    end
  end

  # Create a new Configuration object and store it in the database. Only
  # supports XML format.
  def create
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @config.save
        format.xml { 
          headers['Location'] = configuration_url(@config)
          render :xml => @config.to_xml, :status => :created 
        }
      else
        format.xml { 
          render :xml => @config.errors.to_xml, 
          :status => :unprocessable_entity 
        }
      end
    end
  end
  
  # Retrieve a  Configuration object. Only supports XML format.
  def show
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml { render :xml => @config.to_xml }
    end
  end
  
  # Update the attributes (name, value) of a Configurarion object. Only
  # supports XML format.
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @config.update_attributes(params[:config])
        format.xml { render :xml => @config.to_xml }
      else
        format.xml { render :xml => @config.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  # Delete a give configuration from the back-end dabatase. Only
  # supports XML format.
  def destroy
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @config.destroy
        format.xml { head :ok }
      else
        format.xml { render :xml => @config.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  private
  # This filter locates a Configuration object based on the :id passed as a
  # parameter in the request. If the :id is invalid an error page is rendered.
  def find_or_initialize_config
    if params[:id]
      unless @config = Configuration.find_by_id(params[:id])
        render_optional_error_file :not_found
      end
    else
      @config = Configuration.new(params[:config])
      
    end
  end
  
end
