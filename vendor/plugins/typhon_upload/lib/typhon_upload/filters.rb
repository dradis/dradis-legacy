module TyphonUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)

    # TODO: do something with the contents of the file!
  end
end
