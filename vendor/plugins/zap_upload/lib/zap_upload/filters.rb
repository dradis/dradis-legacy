module ZapUpload  
  private
  @@logger=nil

  public

  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)

    # create the parent node early so we can use it to provide feedback on errors
    parent = Node.find_or_create_by_label( Configuration.parent_node)
    # every note we create will be assigned to this author
    author = Configuration.author
    # get the note category instance or create it if it does not exist
    category = Category.find_or_create_by_name( Configuration.category )

    @@logger.info{ 'Parsing ZAP output...' }
    doc = Nokogiri::XML(file_content)
    @@logger.info{ 'Done.' }

    # Add a note to the plugin root folder with the file name and report date
    file_name = File.basename(params[:file])
    report_date = doc.root.children.first.text
    parent.notes.create(
      :author => author,
      :category => category,
      :text => "#[Title]#\nZAP upload: #{file_name}\n\n#[Report_date]##{report_date}")

    # Depending on Zap version, XML structure is different. 
    # Detect version and then use appropriate xpath:
    if( doc.xpath( '/OWASPZAPReport' ).count > 0 )
      report_path = '/OWASPZAPReport/site/alerts/alertitem'
    else
      report_path = '/report/alertitem'
    end

    doc.xpath(report_path).each do |alert|
      alert_name = alert.xpath('alert').text
      alert_text = alert.elements.collect{ |attribute|
        "#[#{attribute.name.capitalize}]#\n#{attribute.text}\n\n"
      }.join("\n")
      
      @@logger.info{ "Parsing alert item: #{alert_name}" }
      
      alert_node = parent.children.find_or_create_by_label(alert_name)
      alert_node.notes.create(
        :author => author,
        :category => category,
        :text => alert_text)
    end
  end
end
