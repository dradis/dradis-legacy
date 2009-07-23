module <%= class_name %>  
  private
  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file].fullpath )

    # TODO: do something with the contents of the file!
  end
end
