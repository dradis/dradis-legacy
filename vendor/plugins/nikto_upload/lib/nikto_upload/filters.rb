module NiktoUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)

    @@logger.info{ 'Parsing Nikto output...' }
    niktoscan = Nikto::Parser.parsestring( file_content )
    @@logger.info{ 'Done.' }

    category = Category.find_by_name( Configuration.category )

    niktoscan.scans.each do |scan|
      scan_node = Node.create( :label => "#{scan.siteip} - Nikto scan" )    
      @@logger.info{ "Adding #{scan_node.label}" }
      Note.create( 
        :node => scan_node,
        :author => Configuration.author,
        :category => category,
        :text => scan.to_s
      )
    end

    @@logger.info{ 'Nikto scan successfully imported' }

    return true
  end
end
