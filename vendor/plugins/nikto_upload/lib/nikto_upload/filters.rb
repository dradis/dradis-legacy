module NiktoUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)

    @@logger.debug{ 'Parsing Nikto output...' }
    niktoscan = Nikto::Parser.parsestring( file_content )
    @@logger.debug{ 'Done.' }

    category = Category.find_by_name( Configuration.category )

    niktoscan.scans.each do |scan|
      scan_node = Node.create( :label => "#{scan.siteip} - Nikto scan" )    
      @@logger.debug{ "Adding #{scan_node.label}" }
      Note.create( 
        :node => scan_node,
        :author => Configuration.author,
        :category => category,
        :text => scan.to_s
      )
    end

    @@logger.debug{ 'Nikto scan successfully imported' }

    return true
  end
end
