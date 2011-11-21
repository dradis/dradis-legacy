module WxfUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)

    @@logger.info{ 'Parsing wXf output...' }
    wxftext = Wxf::Parser.parsestring( file_content )
    @@logger.info{ 'Done.' }

    category = Category.find_or_create_by_name(Configuration.category)

    scan_node = Node.create( :label => Configuration.node_label )
 
    wxf_name = {} 
    
      wxftext.contentdata.each do |cdata|
      @@logger.info{ "Adding #{cdata.name[:text]}" }
     
        wxfName = cdata.name[:text]
        
        if !wxf_name.key?( wxfName)
        wxf_name[ wxfName ] =Node.create( :label => cdata.name[:text], :parent => scan_node)
        type_processed = false

        content_data = "#[Name]#\n"
        content_data << cdata.name[:text] if cdata.name
        
        end
    

       
        content = "#[Time]#\n"
        content << cdata.time[:text] if cdata.time
        content << "\n\n#[Headers]#\n"
        content << cdata.headers[:text] if cdata.headers
        content << "\n\n#[Request]#\n"
        content << cdata.request[:text] if cdata.request
        content << "\n\n#[Response Body]#\n"
        content << cdata.bodyofmessage[:text] if cdata.bodyofmessage
     
      Note.create(
        :node => wxf_name[wxfName],
        :author => Configuration.author,
        :category => category,
        :text => content
      )
    end

    @@logger.info{ 'wXf results/output successfully imported' }

    return true

  end
end

