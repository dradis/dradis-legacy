module W3afUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    plugin_author_name = Configuration.author

    category = Category.find_or_create_by_name(Configuration.category)

    w3af_node = Node.create(:label => Configuration.node_label)

    @@logger = params.fetch(:logger, Rails.logger)
    @@logger.info('Started Logging')

    file_content = File.read( params[:file] )

    doc = Nokogiri::XML(file_content)

    if doc.root.name == 'w3afrun'
      host = W3af::Parser.parse_w3af_xml(doc)
    else
      error_note = Note.create(
      :node => w3af_node,
      :author => plugin_author_name,
      :category => category,
      :text => "Document doesn't seem to be a W3AF XML Report"
      )
      return
    end

    #create_node for the target host
    host_node = Node.create(:label => host['target'], :parent => w3af_node )

    #Create Nodes for each severity
    host['vulns'].each do |sev, vuln|
      severity_node = Node.create(:label => sev, :parent => host_node)
      vuln.each do |name, detail|
        category_node = Node.create(:label => name, :parent => severity_node)
        detail.each do |url, desc|
          Note.create(
              :node => category_node,
              :author => plugin_author_name,
              :category => category,
              :text => desc.join("\n--------------\n")
          )
        end
      end

    end

  end

end
