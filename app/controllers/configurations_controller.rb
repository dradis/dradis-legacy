class ConfigurationsController < ApplicationController
  before_filter :find_or_initialize_config, :except => [ :index ]

  # GET /nodes
  # Formats: xml
  def index
    @configs = Configuration.find(:all)
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      format.xml { render :xml => @configs.to_xml}
    end
  end

  # POST /nodes
  # Formats: xml
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
  
  # GET /node/<id>
  # Formats: xml
  def show
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml { render :xml => @config.to_xml }
    end
  end
  
  # PUT /node/<id>
  # Formats: xml
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @node.update_attributes(params[:node])
        format.xml { render :xml => @config.to_xml }
      else
        format.xml { render :xml => @config.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /nodes/<id>
  # Formats: xml
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
