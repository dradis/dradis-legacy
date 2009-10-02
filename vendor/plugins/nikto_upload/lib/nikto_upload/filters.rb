module NiktoUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file].fullpath )
    @@logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)

    @@logger.debug{ 'Parsing Nikto output...' }
    niktoscan = Nikto::Parser.parsestring( file_content )
    @@logger.debug{ 'Done.' }

    category = Category.find_or_create_by_name('Nikto output')

    scan_node = Node.create( :label => "#{niktoscan.siteip} - Nikto scan" )    
    Note.create( 
      :node => scan_node,
      :author => 'Nikto',
      :category => category,
      :text => niktoscan.to_s
    )
    @@logger.debug{ 'Nikto scan successfully imported' }

    return true
  end
end
