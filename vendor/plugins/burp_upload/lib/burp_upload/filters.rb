module BurpUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file].fullpath )
    @@logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)

    # TODO: do something with the contents of the file!
  end
end
