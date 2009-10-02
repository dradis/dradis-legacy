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

    niktoscan.scans.each do |scan|
      scan_node = Node.create( :label => "#{scan.siteip} - Nikto scan" )    
      @@logger.debug{ "Adding #{scan_node.label}" }
      Note.create( 
        :node => scan_node,
        :author => 'Nikto',
        :category => category,
        :text => scan.to_s
      )
    end

    @@logger.debug{ 'Nikto scan successfully imported' }

    return true
  end
end
