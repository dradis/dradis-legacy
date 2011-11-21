module OpenvasUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})

    #Set an author name for the notes.
    @plugin_author_name = Configuration.author

    @category = Category.find_or_create_by_name(Configuration.category)

    #Create a parent node for the OpenVAS output
    @openvas_node = Node.create(:label => Configuration.node_label)

    @@logger = params.fetch(:logger, Rails.logger)
    @@logger.info('started debugging')

    file_content = File.read( params[:file] )

    doc = Nokogiri::XML(file_content)

    if doc.root.name == 'openvas-report'
      @hosts = parse_openvas_xml(doc)
    else
      error_note = Note.create(
        :node => @openvas_node,
        :author => @plugin_author_name,
        :category => @category,
        :text => "Document doesn't seem to be an OpenVAS report"
      )
      return
    end

    @hosts.each do |host|
      host_node = Node.create(:label => host['name'], :parent_id => @openvas_node.id)
      host_info_note = Note.create(
          :node => host_node,
          :author => @plugin_author_name,
          :category => @category,
          :text => "OpenVAS Host Results\nIP Address: #{host['ip']}\nScan Started: #{host['start_time']}
          \nScan Finished: #{host['end_time']}"
      )
      host['ports'].each do |port_label, findings|
        port_node = Node.create(:label => port_label, :parent_id => host_node.id)
        findings.each do |severity, finding|
          severity_node = Node.create(:label => severity, :parent_id => port_node.id)
          finding.each do |find|
            Note.create(
                :node => severity_node,
                :author => @plugin_author_name,
                :category => @category,
                :text => find
            )
          end
        end
      end
    end

  end

  def self.parse_openvas_xml(doc)
    results = doc.search('results')

    hosts = Array.new
    results.search('result').each do |host|
      current_host = Hash.new
      current_host['name'] = host.search('host')[0]['name']
      current_host['ip'] = host.search('host')[0]['ip']
      current_host['start_time'] = host.search('start').text
      current_host['end_time'] = host.search('end').text
      current_host['ports'] = Hash.new

      host.search('port').each do |port|
        protocol = port['protocol']
        portid = port['portid']

        #Handle the case where OpenVAS has a port with no protocol or portid
        if protocol.length == 0 || portid.length == 0
          protocol = "Generic"
          portid = "Information"
        end

        port_label = protocol + '-' + portid

        current_host['ports'][port_label] = Hash.new

        port.search('information').each do |finding|
          unless current_host['ports'][port_label][finding.search('severity').text]
            current_host['ports'][port_label][finding.search('severity').text] = Array.new
          end
          current_host['ports'][port_label][finding.search('severity').text] << finding.search('data').text
        end

      end
      hosts << current_host
    end
    return hosts
  end


end
